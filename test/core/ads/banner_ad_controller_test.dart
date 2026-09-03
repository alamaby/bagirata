import 'dart:async';

import 'package:bagistruk/core/ads/banner_ad_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _PendingTimer {
  _PendingTimer(this.delay, this._onFire);

  final Duration delay;
  final void Function() _onFire;
  bool cancelled = false;

  void cancel() => cancelled = true;

  void fire() => _onFire();
}

/// Manual (fake) timers for [BannerAdController]: records every scheduled
/// timer so tests can assert its delay and fire it explicitly.
class ManualTimers {
  final List<_PendingTimer> _pending = <_PendingTimer>[];

  TimerFactory get factory => create;

  TimerHandle create(Duration delay, void Function() onFire) {
    final timer = _PendingTimer(delay, onFire);
    _pending.add(timer);
    return timer.cancel;
  }

  List<Duration> get activeDelays =>
      _pending
          .where((_PendingTimer t) => !t.cancelled)
          .map((t) => t.delay)
          .toList();

  /// Removes and fires the first non-cancelled timer, if any.
  void fireFirst() {
    var i = 0;
    while (i < _pending.length) {
      final timer = _pending[i];
      _pending.removeAt(i);
      if (!timer.cancelled) {
        timer.fire();
        return;
      }
    }
  }
}

class FakeAdSource implements BannerAdSource {
  bool canRequestAdsResult = true;
  Object? canRequestAdsError;
  Completer<void>? _readyCompleter;
  int loadCount = 0;
  int disposeCount = 0;
  BannerAdCallbacks? lastCallbacks;

  void holdSdkReady() {
    _readyCompleter = Completer<void>();
  }

  void releaseSdkReady() {
    _readyCompleter?.complete();
  }

  @override
  Future<bool> canRequestAds() async {
    final error = canRequestAdsError;
    if (error != null) throw error;
    return canRequestAdsResult;
  }

  @override
  Future<void> waitForSdkReady() =>
      _readyCompleter?.future ?? Future<void>.value();

  @override
  void load(BannerAdCallbacks callbacks) {
    loadCount++;
    lastCallbacks = callbacks;
  }

  @override
  void disposeCurrent() {
    disposeCount++;
  }
}

class _Harness {
  _Harness._(this.controller, this.timers, this.src);

  factory _Harness() {
    final src = FakeAdSource();
    final timers = ManualTimers();
    final controller = BannerAdController(
      source: src,
      tag: 'test',
      onStatusChanged: (_) {},
      retryDelays: const <Duration>[
        Duration(seconds: 2),
        Duration(seconds: 8),
        Duration(seconds: 30),
      ],
      slowRetryDelay: const Duration(seconds: 60),
      maxSlowRetries: 2,
      sdkReadyTimeout: const Duration(seconds: 30),
      timerFactory: timers.factory,
    );
    return _Harness._(controller, timers, src);
  }

  final BannerAdController controller;
  final ManualTimers timers;
  final FakeAdSource src;
}

Future<void> _flush() async {
  await Future<void>.delayed(Duration.zero);
}

void main() {
  group('BannerAdController', () {
    test('holds off loading until the SDK is ready', () async {
      final h = _Harness()..src.holdSdkReady();
      h.controller.start();
      await _flush();
      expect(h.src.loadCount, 0, reason: 'load must wait for SDK readiness');
      expect(h.controller.status, BannerAdStatus.waiting);
      expect(h.timers.activeDelays, isEmpty,
          reason: 'no retry scheduled while readiness is pending');

      h.src.releaseSdkReady();
      await _flush();
      expect(h.src.loadCount, 1);
      expect(h.controller.status, BannerAdStatus.loading);
      expect(h.timers.activeDelays, [const Duration(seconds: 20)]);

      h.controller.dispose();
    });

    test('silent drop: watchdog fires and schedules a retry', () async {
      final h = _Harness();
      h.controller.start();
      await _flush();
      expect(h.src.loadCount, 1);

      h.timers.fireFirst(); // 20s watchdog
      expect(h.src.loadCount, 1, reason: 'retry is scheduled, not immediate');
      expect(h.controller.status, BannerAdStatus.waiting);
      expect(h.timers.activeDelays, [const Duration(seconds: 2)]);

      h.timers.fireFirst(); // 2s retry
      await _flush();
      expect(h.src.loadCount, 2);

      h.controller.dispose();
    });

    test('failed loads retry with backoff, then slow retries, then give up',
        () async {
      final h = _Harness();
      h.controller.start();
      await _flush();
      expect(h.src.loadCount, 1);

      // Fast retries: 2s, 8s, 30s.
      const fast = <Duration>[
        Duration(seconds: 2),
        Duration(seconds: 8),
        Duration(seconds: 30),
      ];
      for (final delay in fast) {
        h.src.lastCallbacks!.onFailed(3, 'no fill');
        expect(h.timers.activeDelays, [delay]);
        h.timers.fireFirst();
        await _flush();
        expect(h.src.loadCount, fast.indexOf(delay) + 2);
        expect(h.timers.activeDelays, [const Duration(seconds: 20)]);
      }
      // Slow retries: 60s x maxSlowRetries (2).
      for (var i = 0; i < 2; i++) {
        h.src.lastCallbacks!.onFailed(3, 'no fill');
        expect(h.timers.activeDelays, [const Duration(seconds: 60)]);
        h.timers.fireFirst();
        await _flush();
        expect(h.timers.activeDelays, [const Duration(seconds: 20)]);
      }
      expect(h.src.loadCount, 6);

      h.src.lastCallbacks!.onFailed(3, 'no fill');
      expect(h.controller.status, BannerAdStatus.hidden);
      expect(h.timers.activeDelays, isEmpty);
      h.timers.fireFirst(); // nothing left to fire
      await _flush();
      expect(h.src.loadCount, 6);

      h.controller.dispose();
    });

    test('consent pending: retries until consent, then loads', () async {
      final h = _Harness()..src.canRequestAdsResult = false;
      h.controller.start();
      await _flush();
      expect(h.src.loadCount, 0);
      expect(h.controller.status, BannerAdStatus.waiting);
      expect(h.timers.activeDelays, [const Duration(seconds: 2)]);

      h.timers.fireFirst();
      await _flush();
      expect(h.src.loadCount, 0);
      expect(h.timers.activeDelays, [const Duration(seconds: 8)]);

      h.src.canRequestAdsResult = true;
      h.timers.fireFirst();
      await _flush();
      expect(h.src.loadCount, 1);
      expect(h.controller.status, BannerAdStatus.loading);

      h.controller.dispose();
    });

    test('pre-load check failure schedules a retry', () async {
      final h = _Harness()
        ..src.canRequestAdsError = StateError('plugin missing');
      h.controller.start();
      await _flush();
      expect(h.src.loadCount, 0);
      expect(h.timers.activeDelays, [const Duration(seconds: 2)]);

      h.src.canRequestAdsError = null;
      h.timers.fireFirst();
      await _flush();
      expect(h.src.loadCount, 1);

      h.controller.dispose();
    });

    test(
        'appResumed retries immediately without waiting for the backoff timer',
        () async {
      final h = _Harness();
      h.controller.start();
      await _flush();
      expect(h.src.loadCount, 1);

      h.src.lastCallbacks!.onFailed(3, 'no fill');
      expect(h.timers.activeDelays, [const Duration(seconds: 2)]);

      h.controller.appResumed();
      await _flush();
      expect(h.src.loadCount, 2);
      expect(h.timers.activeDelays, [const Duration(seconds: 20)],
          reason: 'the pending backoff timer must be cancelled');
      expect(h.controller.status, BannerAdStatus.loading);

      h.controller.dispose();
    });

    test('loaded: no further loads on resume', () async {
      final h = _Harness();
      h.controller.start();
      await _flush();
      h.src.lastCallbacks!.onLoaded();
      expect(h.controller.status, BannerAdStatus.loaded);

      h.controller.appResumed();
      await _flush();
      expect(h.src.loadCount, 1);

      h.controller.dispose();
    });

    test('reset restarts the sequence with a fresh retry budget', () async {
      final h = _Harness();
      h.controller.start();
      await _flush();
      expect(h.src.loadCount, 1);

      h.src.lastCallbacks!.onFailed(3, 'no fill');
      expect(h.timers.activeDelays, [const Duration(seconds: 2)]);

      h.controller.reset();
      await _flush();
      expect(h.src.loadCount, 2);

      h.src.lastCallbacks!.onFailed(3, 'no fill');
      expect(h.timers.activeDelays, [const Duration(seconds: 2)],
          reason: 'budget must restart from the first backoff delay');

      h.controller.dispose();
    });

    test('hung SDK readiness: timeout still proceeds to load', () async {
      final timers = ManualTimers();
      final src = FakeAdSource()..holdSdkReady();
      final controller = BannerAdController(
        source: src,
        tag: 'test',
        onStatusChanged: (_) {},
        sdkReadyTimeout: const Duration(milliseconds: 50),
        timerFactory: timers.factory,
      );
      controller.start();
      await _flush();
      expect(src.loadCount, 0);

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(src.loadCount, 1,
          reason: 'timeout must unblock the load (SDK may self-init)');

      controller.dispose();
    });

    test('dispose cancels timers and ignores late callbacks', () async {
      final h = _Harness();
      h.controller.start();
      await _flush();
      expect(h.src.loadCount, 1);

      h.controller.dispose();
      expect(h.src.disposeCount, greaterThan(0));

      h.src.lastCallbacks!.onLoaded();
      h.timers.fireFirst();
      await _flush();
      expect(h.src.loadCount, 1);
      expect(h.controller.status, isNot(BannerAdStatus.loaded));
    });
  });
}
