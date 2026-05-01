class Routes {
  const Routes._();

  static const String scan = '/scan';
  static const String scanName = 'scan';

  static const String history = '/history';
  static const String historyName = 'history';

  static const String capture = '/capture';
  static const String captureName = 'capture';

  static const String billReview = '/review';
  static const String billReviewName = 'bill-review';

  static const String billSplit = '/split/:billId';
  static const String billSplitName = 'bill-split';

  static const String billDetail = '/detail/:billId';
  static const String billDetailName = 'bill-detail';

  static const String login = '/login';
  static const String loginName = 'login';

  static const String register = '/register';
  static const String registerName = 'register';

  static const String verifyEmail = '/verify-email';
  static const String verifyEmailName = 'verify-email';
}
