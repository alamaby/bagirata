import 'dart:async';

import '../utils/app_logger.dart';

/// Outcome channel for a single banner load attempt. The platform layer
/// invokes at most one of [onLoaded] / [onFailed] per attempt — or **neither
/// at all**. The "neither" case (silent drop, observed when a load is issued
/// before the MobileAds SDK finished initializing) is exactly what
/// [BannerAdController] guards against with its watchdog.
class BannerAdCallbacks {
  const BannerAdCallbacks({
    required this.onLoaded,
    required this.onFailed,
  });

  final void Function() onLoaded;
  final void Function(int code, String message) onFailed;
}

/// Abstraction over the AdMob SDK so [BannerAdController] stays pure Dart
/// and unit-testable without platform channels.
abstract class BannerAdSource {
  /// Consent / gate check. `false` means "not ready yet — try again later".
  Future<bool> canRequestAds();

  /// Completes when the MobileAds SDK is ready to serve requests. The
  /// controller applies its own timeout on top; a hung future must never
  /// block a banner forever.
  Future<void> waitForSdkReady();

  /// Start loading a banner. Must not throw; outcomes arrive via
  /// [callbacks] — possibly never (see [BannerAdCallbacks]).
  void load(BannerAdCallbacks callbacks);

  /// Dispose the current ad instance, if any. Must be idempotent.
  void disposeCurrent();
}

enum BannerAdStatus { waiting, loading, loaded, hidden }

typedef BannerAdStatusChanged = void Function(BannerAdStatus status);

/// Cancel handle returned by a [TimerFactory].
typedef TimerHandle = void Function();

/// Timer seam so the controller's state machine can be tested with manual
/// (fake) timers in pure Dart tests.
typedef TimerFactory = TimerHandle Function(Duration delay, void Function() onFire);

/// Owns the retry / watchdog state machine for a single banner placement.
///
/// Sequence per attempt: consent gate → SDK readiness gate (bounded by
/// [sdkReadyTimeout]) → load. Every failure mode — consent pending, load
/// error, or a load that never calls back (silent drop) — schedules a retry
/// with backoff [retryDelays], then a slow [slowRetryDelay] retry up to
/// [maxSlowRetries] times, and only then gives up for the session
/// ([BannerAdStatus.hidden]). Nothing fails silently and permanently: every
/// terminal state is observable via [status], and [appResumed] re-triggers
/// the sequence whenever the app returns to the foreground.
class BannerAdController {
  BannerAdController({
    required BannerAdSource source,
    required String tag,
    required BannerAdStatusChanged onStatusChanged,
    this.sdkReadyTimeout = const Duration(seconds: 30),
    this.watchdogTimeout = const Duration(seconds: 20),
    this.retryDelays = const <Duration>[
      Duration(seconds: 2),
      Duration(seconds: 8),
      Duration(seconds: 30),
      Duration(seconds: 60),
      Duration(seconds: 120),
    ],
    this.slowRetryDelay = const Duration(seconds: 60),
    this.maxSlowRetries = 10,
    TimerFactory? timerFactory,
  }) : _source = source,
       _tag = tag,
       _onStatusChanged = onStatusChanged,
       _createTimer = timerFactory ?? _createRealTimer;

  final BannerAdSource _source;
  final String _tag;
  final BannerAdStatusChanged _onStatusChanged;
  final Duration sdkReadyTimeout;
  final Duration watchdogTimeout;
  final List<Duration> retryDelays;
  final Duration slowRetryDelay;
  final int maxSlowRetries;
  final TimerFactory _createTimer;

  TimerHandle? _retryHandle;
  TimerHandle? _watchdogHandle;
  bool _disposed = false;
  BannerAdStatus _status = BannerAdStatus.hidden;
  int _fastRetriesUsed = 0;
  int _slowRetriesUsed = 0;
  int _loadAttempts = 0;
  int _generation = 0;

  BannerAdStatus get status => _status;

  int get loadAttempts => _loadAttempts;

  /// Start the load sequence. Call once after construction.
  void start() {
    if (_disposed) return;
    _beginAttempt();
  }

  /// Re-run the whole sequence with fresh retry counters (e.g. after the
  /// user's minor/adult status changes so a consent-configured request is
  /// re-issued).
  void reset() {
    if (_disposed) return;
    _generation++;
    _cancelTimers();
    _source.disposeCurrent();
    _fastRetriesUsed = 0;
    _slowRetriesUsed = 0;
    _loadAttempts = 0;
    _beginAttempt();
  }

  /// Retry immediately when the app returns to the foreground and the
  /// banner has not loaded yet.
  void appResumed() {
    if (_disposed) return;
    if (_status == BannerAdStatus.loaded || _status == BannerAdStatus.hidden) {
      return;
    }
    _generation++;
    _cancelTimers();
    _beginAttempt();
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _generation++;
    _cancelTimers();
    _source.disposeCurrent();
  }

  void _setStatus(BannerAdStatus next) {
    if (_disposed || _status == next) return;
    _status = next;
    _onStatusChanged(next);
  }

  Future<void> _beginAttempt() async {
    final generation = _generation;
    _setStatus(BannerAdStatus.waiting);
    try {
      final canRequest = await _source.canRequestAds();
      if (generation != _generation || _disposed) return;
      if (!canRequest) {
        AppLogger.log(
          'BannerAd waiting for consent/ad readiness tag=$_tag '
          'attempt=$_loadAttempts',
        );
        _scheduleRetry();
        return;
      }
      try {
        await _source.waitForSdkReady().timeout(
          sdkReadyTimeout,
          onTimeout: () {
            AppLogger.warn(
              'BannerAd SDK readiness timeout (${sdkReadyTimeout.inSeconds}s) '
              'tag=$_tag — proceeding, SDK may self-init',
            );
          },
        );
      } catch (e) {
        if (generation != _generation || _disposed) return;
        AppLogger.warn(
          'BannerAd SDK readiness check failed tag=$_tag error=$e',
        );
        _scheduleRetry();
        return;
      }
      if (generation != _generation || _disposed) return;
      _issueLoad();
    } catch (e) {
      if (generation != _generation || _disposed) return;
      AppLogger.warn(
        'BannerAd pre-load check failed tag=$_tag attempt=$_loadAttempts '
        'error=$e',
      );
      _scheduleRetry();
    }
  }

  void _issueLoad() {
    final generation = _generation;
    _source.disposeCurrent();
    _setStatus(BannerAdStatus.loading);
    _loadAttempts++;
    _source.load(
      BannerAdCallbacks(
        onLoaded: () {
          if (_disposed || generation != _generation) return;
          _cancelTimers();
          _setStatus(BannerAdStatus.loaded);
        },
        onFailed: (code, message) {
          if (_disposed || generation != _generation) return;
          AppLogger.warn(
            'BannerAd load failed tag=$_tag attempt=$_loadAttempts '
            'code=$code message=$message',
          );
          _scheduleRetry();
        },
      ),
    );
    _watchdogHandle = _createTimer(
      watchdogTimeout,
      () {
        if (_disposed || _status != BannerAdStatus.loading) return;
        AppLogger.warn(
          'BannerAd silent-drop watchdog fired tag=$_tag '
          'attempt=$_loadAttempts (no callback within '
          '${watchdogTimeout.inSeconds}s) — retrying',
        );
        _scheduleRetry();
      },
    );
  }

  void _scheduleRetry() {
    _cancelTimers();
    if (_fastRetriesUsed < retryDelays.length) {
      final delay = retryDelays[_fastRetriesUsed];
      _fastRetriesUsed++;
      _setStatus(BannerAdStatus.waiting);
      _retryHandle = _createTimer(delay, () {
        if (_disposed) return;
        _beginAttempt();
      });
      return;
    }
    if (_slowRetriesUsed >= maxSlowRetries) {
      AppLogger.warn(
        'BannerAd giving up tag=$_tag after $_loadAttempts load attempts '
        'and $_slowRetriesUsed slow retries — banner hidden for this '
        'session',
      );
      _setStatus(BannerAdStatus.hidden);
      return;
    }
    _slowRetriesUsed++;
    _setStatus(BannerAdStatus.waiting);
    _retryHandle = _createTimer(slowRetryDelay, () {
      if (_disposed) return;
      _beginAttempt();
    });
  }

  void _cancelTimers() {
    _retryHandle?.call();
    _retryHandle = null;
    _watchdogHandle?.call();
    _watchdogHandle = null;
  }

  static TimerHandle _createRealTimer(Duration delay, void Function() onFire) {
    final timer = Timer(delay, onFire);
    return timer.cancel;
  }
}
