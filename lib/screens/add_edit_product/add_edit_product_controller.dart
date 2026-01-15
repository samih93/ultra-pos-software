import 'dart:io';
import 'dart:typed_data';

import 'package:desktoppossystem/controller/category_controller.dart';
import 'package:desktoppossystem/controller/product_controller.dart';
import 'package:desktoppossystem/models/category_model.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/tracked_related_product.dart';
import 'package:desktoppossystem/repositories/products/iproduct_repository.dart';
import 'package:desktoppossystem/repositories/products/product_repository.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/products/products_settings_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';

import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

final addEditProductControllerProvider =
    ChangeNotifierProvider<AddEditProductController>((ref) {
      return AddEditProductController(
        ref: ref,
        productRepositoy: ref.read(productProviderRepository),
      );
    });

class AddEditProductController extends ChangeNotifier {
  final Ref _ref;
  final IProductRepository _productRepositoy;
  AddEditProductController({
    required Ref ref,
    required IProductRepository productRepositoy,
  }) : _ref = ref,
       _productRepositoy = productRepositoy,
       super();

  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  var productNameController = TextEditingController();
  var productSellingPriceController = TextEditingController();
  var productSecondarySellingPriceController = TextEditingController();

  var productCostPriceController = TextEditingController();
  var productSecondaryCostPriceController = TextEditingController();
  var profitRateController = TextEditingController();
  var discountTextController = TextEditingController();
  var productBarcodeController = TextEditingController();
  var productQtyController = TextEditingController();
  var warningAlertController = TextEditingController();
  var expiryDateController = TextEditingController();
  var minSellingPriceController = TextEditingController();
  var descriptionController = TextEditingController();

  var offerProductQtyController = TextEditingController();
  var offerProductController = TextEditingController();
  var pluTextContoller = TextEditingController();

  bool autoUpdateSellingPrice = true;

  bool isHasOffer = false;
  bool offerOnMenu = false;
  bool isTracked = false;
  bool enableNotification = false;
  bool isWeightedProduct = false;
  void onChangeWeightedProductStatus() {
    isWeightedProduct = !isWeightedProduct;
    if (isWeightedProduct) {
      isTracked = true;
    } else {
      pluTextContoller.text = "";
    }
    notifyListeners();
  }

  toggleAutoUpdateSellingPrice() {
    autoUpdateSellingPrice = !autoUpdateSellingPrice;
    notifyListeners();
  }

  toggleOfferOnMenu() {
    offerOnMenu = !offerOnMenu;
    notifyListeners();
  }

  calculateCostForOffer() {
    double totalCost = 0;
    for (var element in trackedRelatedProductList) {
      double totalCostByItem =
          element.costPrice! * element.qtyFromRelatedProduct;
      totalCost += totalCostByItem;
    }
    productCostPriceController.text = totalCost.formatDouble().toString();
    onchangeCost(totalCost);
  }

  onChangeIsOffer() {
    isHasOffer = !isHasOffer;
    if (isHasOffer == false) removeOfferProductId();
    notifyListeners();
  }

  onChangeNotificationStatus() {
    enableNotification = !enableNotification;
    notifyListeners();
  }

  checkLatestTrackIfAddState() {
    if (productModel!.id == null &&
        !_ref
            .read(productsSettingsControllerProvider)
            .duplicateLatestProductOnAdd) {
      isTracked = _ref.read(appPreferencesProvider).getBool(key: "isTracked");
      notifyListeners();
    }
  }

  onChangeTrackProduct() {
    isTracked = !isTracked;
    _ref
        .read(appPreferencesProvider)
        .saveData(key: 'isTracked', value: isTracked);

    notifyListeners();
  }

  bool get isOffer => trackedRelatedProductList.isNotEmpty && !isTracked;

  List<TrackedRelatedProductModel> trackedRelatedProductList = [];

  addTrackedRelatedProduct() {
    if (currentSelectedProduct != null) {
      if (!trackedRelatedProductList.any(
        (element) => element.relatedProductId == currentSelectedProduct?.id,
      )) {
        trackedRelatedProductList.add(
          TrackedRelatedProductModel(
            productId: productModel?.id,
            costPrice: currentSelectedProduct?.costPrice ?? 0,
            relatedProductId: currentSelectedProduct!.id!,
            relatedProductName: currentSelectedProduct!.name.toString(),
            qtyFromRelatedProduct: currentSelectedQty,
          ),
        );
      }
      calculateCostForOffer();
    }
  }

  removeTrackedRelatedProduct(int id) {
    trackedRelatedProductList.removeWhere(
      (element) => element.relatedProductId == id,
    );
    calculateCostForOffer();
  }

  Future fetchOffers(int productId) async {
    final res = await _productRepositoy.fetchRelatedTrackedByProductId(
      productId,
    );
    res.fold((l) {}, (r) {
      trackedRelatedProductList = r;
    });
    notifyListeners();
  }

  onSelectTrackedProduct(ProductModel p) {
    notifyListeners();
  }

  ProductModel? currentSelectedProduct;
  double currentSelectedQty = 0;
  onSetCurrentSelectedProduct(ProductModel p) {
    offerProductController.text = p.name.toString();
    currentSelectedProduct = p;
  }

  onSetCurrentSelectedQty(double qty) {
    currentSelectedQty = qty;
  }

  removeOfferProductId() {
    offerProductController.clear();
    notifyListeners();
  }

  ProductModel? productModel;

  onSetProduct(
    ProductModel? p,
    BuildContext context, {
    CategoryModel? categoryModel,
  }) {
    if (p == null &&
        _ref.read(latestAddedProductProvider) != null &&
        _ref
            .read(productsSettingsControllerProvider)
            .duplicateLatestProductOnAdd) {
      ProductModel latestProduct = _ref.read(latestAddedProductProvider)!;
      p = latestProduct.copyWith(id: null);

      isTracked = p.isTracked ?? false;
      enableNotification = p.enableNotification ?? false;
    }
    productModel =
        p ??
        ProductModel.second().copyWith(
          profitRate: _ref.read(productsSettingsControllerProvider).profitRate,
        );

    //! if product null so "Add product" is pressed and now we have the category
    if (p == null &&
        _ref.read(categoryControllerProvider).categories.isNotEmpty) {
      final firstcategory = _ref
          .read(categoryControllerProvider)
          .categories
          .first;
      productModel?.categoryId = categoryModel != null
          ? categoryModel.id
          : firstcategory.id ?? 1;
    }

    //!set controller to the product name and price

    discountTextController.text = (productModel!.discount ?? 0).toString();
    productNameController.text = productModel!.name == null
        ? ''.toString()
        : productModel!.name.toString();
    productSellingPriceController.text = productModel!.sellingPrice == null
        ? '0'.toString()
        : productModel!.sellingPrice.toString();
    // Store the precise selling price
    // Calculate and store the rounded display value
    final secondaryDisplayPrice =
        (productModel!.sellingPrice.validateDouble() *
                _ref.read(saleControllerProvider).dolarRate)
            .roundToDouble();
    productSecondarySellingPriceController.text = secondaryDisplayPrice
        .toString();
    minSellingPriceController.text = productModel!.minSellingPrice == null
        ? '0'.toString()
        : productModel!.minSellingPrice.toString();
    profitRateController.text = productModel!.profitRate == null
        ? ''.toString()
        : productModel!.profitRate.toString();
    productCostPriceController.text = productModel!.costPrice == null
        ? ''.toString()
        : productModel!.costPrice.toString();
    productBarcodeController.text = productModel!.barcode == null
        ? ''.toString()
        : productModel!.barcode.toString();

    selectedCategoryId = productModel!.categoryId;
    expiryDateController.text = productModel!.expiryDate != null
        ? productModel!.expiryDate.toString()
        : '';
    warningAlertController.text = productModel!.warningAlert != null
        ? productModel!.warningAlert.toString()
        : '1';

    productCostPriceController.text = productModel!.costPrice != null
        ? productModel!.costPrice.toString()
        : "0";
    // Calculate and set secondary cost price
    final secondaryCostPrice =
        (productModel!.costPrice.validateDouble() *
                _ref.read(saleControllerProvider).dolarRate)
            .roundToDouble();
    productSecondaryCostPriceController.text = secondaryCostPrice == 0
        ? '0'
        : secondaryCostPrice.toString();
    productQtyController.text = productModel!.qty != null
        ? productModel!.qty!.formatDouble().toString()
        : "0";

    isTracked = productModel!.id == null
        ? isTracked
        : productModel!.isTracked ?? false;
    enableNotification = productModel!.id == null
        ? enableNotification
        : productModel!.enableNotification ?? false;
    //! weighted product
    isWeightedProduct = productModel!.id == null
        ? isWeightedProduct
        : productModel!.isWeighted ?? false;
    pluTextContoller.text = productModel!.plu != null
        ? productModel?.plu?.toString() ?? ''
        : "";
    offerOnMenu = productModel!.isOffer ?? false;
    descriptionController.text = productModel!.description ?? '';
  }

  int? selectedCategoryId;

  //!NOTE on change remind list
  onchangeCategory(String value) {
    productModel!.categoryId = int.parse(value);
    selectedCategoryId = productModel!.categoryId;
    //notifyListeners();
  }

  onchangeExpiryDate(String date) {
    productModel!.expiryDate = date;

    expiryDateController.text = productModel!.expiryDate.toString();
    notifyListeners();
  }

  onchangeProfitRate(double? rate) {
    double cost = double.tryParse(productCostPriceController.text) ?? 0;
    double rate = double.tryParse(profitRateController.text) ?? 0;
    final selling = ((rate * cost / 100) + cost).formatDoubleWith6();
    productSellingPriceController.text = selling.toString();
    productSecondarySellingPriceController.text =
        (_ref.read(saleControllerProvider).dolarRate * (selling)).toString();
    notifyListeners();
  }

  onchangeCost(double cost) {
    double cost = double.tryParse(productCostPriceController.text) ?? 0;
    // Update secondary cost price when primary cost changes
    final secondaryCost = cost * _ref.read(saleControllerProvider).dolarRate;
    productSecondaryCostPriceController.text = secondaryCost.toString();
    if (autoUpdateSellingPrice == false) {
      notifyListeners();
      return;
    }

    double rate = double.tryParse(profitRateController.text) ?? 0;
    final selling = ((rate * cost / 100) + cost).formatDouble();
    productSellingPriceController.text = selling.toString();
    productSecondarySellingPriceController.text =
        (_ref.read(saleControllerProvider).dolarRate * (selling)).toString();

    notifyListeners();
  }

  void onChangeSecondaryCostPrice(double secondaryCost) {
    double dolarRate = _ref.read(saleControllerProvider).dolarRate;

    if (dolarRate == 0) {
      // Avoid division by zero if dollar rate is 0
      profitRateController.text = "0";
      notifyListeners();
      return;
    }

    // Calculate primary cost price from secondary cost price
    double costPrice = secondaryCost / dolarRate;

    // Update the cost price controller
    productCostPriceController.text = costPrice.formatDoubleWith6().toString();
    if (autoUpdateSellingPrice == false) {
      notifyListeners();
      return;
    }

    // Now update selling prices based on new cost and profit rate
    double rate = double.tryParse(profitRateController.text) ?? 0;
    final selling = ((rate * costPrice / 100) + costPrice).formatDouble();
    productSellingPriceController.text = selling.toString();
    productSecondarySellingPriceController.text = (dolarRate * selling)
        .formatDouble()
        .toString();

    notifyListeners();
  }

  void onchangeSellingPrice(double selling) {
    double cost = double.tryParse(productCostPriceController.text) ?? 0;
    productSecondarySellingPriceController.text =
        (_ref.read(saleControllerProvider).dolarRate * (selling))
            .formatDouble()
            .toString();
    if (cost == 0) {
      profitRateController.text = "0";
      notifyListeners();
      return;
    }

    double profitRate = ((selling - cost) / cost) * 100;

    profitRateController.text = profitRate.toStringAsFixed(2);

    notifyListeners();
  }

  void onChangeSecondarySellingPrice(double secondarySelling) {
    double cost = double.tryParse(productCostPriceController.text) ?? 0;
    double dolarRate = _ref.read(saleControllerProvider).dolarRate;

    if (dolarRate == 0) {
      // Avoid division by zero if dollar rate is 0
      profitRateController.text = "0";
      notifyListeners();
      return;
    }

    // Calculate primary selling price from secondary price
    double sellingPrice = secondarySelling / dolarRate;

    // Update the selling price controller
    // (assuming you have a controller for primary selling price)
    productSellingPriceController.text = sellingPrice
        .formatDoubleWith6()
        .toString();

    if (cost == 0) {
      profitRateController.text = "0";
      notifyListeners();
      return;
    }

    // Calculate profit rate
    double profitRate = ((sellingPrice - cost) / cost) * 100;
    profitRateController.text = profitRate.toStringAsFixed(2);

    notifyListeners();
  }

  Future<List<ProductModel>> searchForAProducts(
    String query, {
    bool? isTracked,
  }) async {
    List<ProductModel> products = await _productRepositoy.searchByNameOrBarcode(
      query,
      isTracked: isTracked,
    );
    return products;
  }

  // Future setProductImageFromBytes(Uint8List imageBytes) async {
  //   try {
  //     // Decode image
  //     img.Image? decodedImage = img.decodeImage(imageBytes);
  //     if (decodedImage == null) {
  //       throw Exception("Unable to decode image");
  //     }

  //     // Resize if necessary
  //     if (decodedImage.width > 800 || decodedImage.height > 800) {
  //       decodedImage = img.copyResize(
  //         decodedImage,
  //         width: decodedImage.width > decodedImage.height ? 800 : null,
  //         height: decodedImage.height >= decodedImage.width ? 800 : null,
  //       );
  //     }

  //     // Encode back to bytes (JPEG or PNG)
  //     Uint8List resizedBytes = Uint8List.fromList(
  //       img.encodeJpg(decodedImage, quality: 80),
  //     );

  //     // Save to model
  //     productModel!.image = resizedBytes;
  //     notifyListeners();
  //   } catch (e) {
  //     ToastUtils.showToast(message: e.toString(), type: RequestState.error);
  //   }
  // }

  File? pickedProductFile;

  removeImage() {
    pickedProductFile = null;
    productModel?.image = null;
    productModel?.pickedImageFile = null;
    notifyListeners();
  }

  Future pickProductImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null) {
        pickedProductFile = File(result.files.single.path!);
        productModel?.pickedImageFile = pickedProductFile;
      }
    } catch (e) {
      ToastUtils.showToast(message: e.toString(), type: RequestState.error);
    }

    notifyListeners();
  }

  @override
  void dispose() {
    productNameController.dispose();
    productSellingPriceController.dispose();
    productCostPriceController.dispose();
    productSecondaryCostPriceController.dispose();
    profitRateController.dispose();
    discountTextController.dispose();
    productBarcodeController.dispose();
    productQtyController.dispose();
    warningAlertController.dispose();
    expiryDateController.dispose();
    offerProductQtyController.dispose();
    minSellingPriceController.dispose();
    pluTextContoller.dispose();
    super.dispose();
  }
}
