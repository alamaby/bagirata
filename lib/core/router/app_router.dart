import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/ocr_result.dart';
import '../../presentation/bills/screens/bill_list_screen.dart';
import '../../presentation/bills/screens/bill_review_screen.dart';
import '../../presentation/ocr/screens/receipt_capture_screen.dart';
import 'routes.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: Routes.billList,
    routes: [
      GoRoute(
        path: Routes.billList,
        name: Routes.billListName,
        builder: (context, state) => const BillListScreen(),
      ),
      GoRoute(
        path: Routes.capture,
        name: Routes.captureName,
        builder: (context, state) => const ReceiptCaptureScreen(),
      ),
      GoRoute(
        path: Routes.billReview,
        name: Routes.billReviewName,
        builder: (context, state) =>
            BillReviewScreen(ocr: state.extra! as OcrResult),
      ),
    ],
  );
}
