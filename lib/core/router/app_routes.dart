class AppRoutes {
  AppRoutes._();

  static const authGate = '/';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const stockCount = '/stock-count';
  static const stockCountCreate = '/stock-count/create';
  static const stockCountScan = '/stock-count/scan';
  static const stockCountManualEntry = '/stock-count/scan/manual-entry';
  static const stockCountReview = '/stock-count/review';
  static const receiving = '/receiving';
  static const receivingItems = '/receiving/items';
  static const receivingSummary = '/receiving/summary';
  static const receivingSignature = '/receiving/summary/signature';
  static const receivingDetails = '/receiving/details';
  static const alerts = '/alerts';
  static const profile = '/profile';
  static const tasks = '/tasks';
  static const assignTasks = '/assign-tasks';
  static const reports = '/reports';
  static const pendingReview = '/pending-review';
}
