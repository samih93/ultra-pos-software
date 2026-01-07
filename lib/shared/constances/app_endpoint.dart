class AppEndpoint {
  static const String products = '/products';
  static const String updateProducts = '$products/update';
  static const String productsByCategory = '$products/by-category';
  static const String syncProductsOrder = '$products/sync-order';

  //Categories
  static const String categories = '/categories';
  static const String syncCategoriesOrder = '$categories/sync-order';
  static const String searchCategories = '$categories/search';

  //Settings
  static const String settings = '/settings';
}
