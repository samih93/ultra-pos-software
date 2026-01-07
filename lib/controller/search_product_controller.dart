import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/repositories/products/iproduct_repository.dart';
import 'package:desktoppossystem/repositories/products/product_repository.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchProductControllerProvider =
    ChangeNotifierProvider<SearchProductController>((ref) {
  return SearchProductController(
      productRepositoy: ref.read(productProviderRepository));
});

class SearchProductController extends ChangeNotifier {
  final IProductRepository _productRepositoy;
  SearchProductController({required IProductRepository productRepositoy})
      : _productRepositoy = productRepositoy,
        super();

  RequestState searchForAProductRequestState = RequestState.success;

  Future<List<ProductModel>> searchForAProducts(String query,
      {bool? isForBarcode}) async {
    List<ProductModel> products = await _productRepositoy.searchByNameOrBarcode(
      isForBarcode: isForBarcode,
      query,
    );
    return products;
  }

  Future<List<ProductModel>> searchForAProductOrASandwich(String query) async {
    List<ProductModel> products = [];
    final productsResponse =
        await _productRepositoy.searchForAProductOrASandwich(
      query,
    );
    productsResponse.fold(
      (l) {
        products = [];
      },
      (r) {
        products = r;
      },
    );

    return products;
  }
}
