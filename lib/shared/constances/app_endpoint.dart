class AppEndpoint {
  //Auth
  static const String auth = '/auth/signin';
  static const String authCode = '/auth/signin-code';

  static const String products = '/products';
  static const String productsByCategory = '$products/by-category';
  static const String syncProductsOrder = '$products/sync-order';
  static const String searchAdvancedProducts = '$products/search-advanced';
  static const String productsStats = '$products/stats';
  static const String productsQuickSelection = '$products/quick-selection';
  static const String productsQuickSelectionReorder =
      '$products/quick-selection/reorder';

  //Categories
  static const String categories = '/categories';
  static const String syncCategoriesOrder = '$categories/sync-order';
  static const String searchCategories = '$categories/search';

  //Settings
  static const String settings = '/settings';

  //Customers
  static const String customers = '/customers';
  static const String customersSearch = '/customers/search';
  static const String customersBatch = '/customers/batch';
}
