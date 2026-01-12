class AppEndpoint {
  //Auth
  static const String auth = '/auth/signin';
  static const String authCode = '/auth/signin-code';

  static const String products = '/products';
  static const String productsByCategory = '$products/by-category';
  static const String syncProductsOrder = '$products/sync-order';
  static const String searchAdvancedProducts = '$products/search-advanced';
  static const String productsStats = '$products/stats';

  //Categories
  static const String categories = '/categories';
  static const String syncCategoriesOrder = '$categories/sync-order';
  static const String searchCategories = '$categories/search';

  //Settings
  static const String settings = '/settings';
}
