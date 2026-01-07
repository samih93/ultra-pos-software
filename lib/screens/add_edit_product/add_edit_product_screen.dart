import 'package:desktoppossystem/controller/product_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/category_model.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/screens/add_edit_product/add_edit_product_controller.dart';
import 'package:desktoppossystem/screens/add_edit_product/components/product_form.dart';
import 'package:desktoppossystem/screens/add_edit_product/components/product_form_mobile.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_screen.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/styles/app_text_style.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  final ProductModel? p;
  final CategoryModel? c;
  final bool? isFromStock;
  final bool? fromNotifications;
  const AddEditProductScreen(
    this.p,
    this.c, {
    super.key,
    this.isFromStock,
    this.fromNotifications,
  });
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addEditProductControllerProvider)
        ..onSetProduct(widget.p, context, categoryModel: widget.c)
        ..fetchOffers(widget.p?.id ?? 0)
        ..checkLatestTrackIfAddState();
    });
  }

  @override
  Widget build(BuildContext context) {
    var productController = ref.read(productControllerProvider);
    var addEditController = ref.read(addEditProductControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(barcodeListenerEnabledProvider.notifier).state = true;
            context.pop();
            ref.invalidate(addEditProductControllerProvider);
            ref.read(productControllerProvider).resetState();
          },
        ),
        title: Text(
          widget.p != null
              ? "${S.of(context).edit} ${widget.p!.name}"
              : S.of(context).addProductButton,
          style: AppTextStyles.appBarTitle,
        ),
        actions: [
          AppSquaredOutlinedButton(
            backgroundColor: Pallete.whiteColor,
            states: [
              ref.watch(productControllerProvider).updateRequestState,
              ref.watch(productControllerProvider).addProductRequestState,
            ],
            onPressed: () async {
              // if form is valid
              if (addEditController.formkey.currentState!.validate()) {
                if (addEditController.productModel?.categoryId == null) {
                  ToastUtils.showToast(
                    message: "Category is required",
                    type: RequestState.error,
                  );
                  return;
                }
                //! get name and price from fields
                addEditController.productModel!.name = addEditController
                    .productNameController
                    .text
                    .toString();
                //! parsing price to double

                addEditController.productModel!.sellingPrice =
                    double.tryParse(
                      addEditController.productSellingPriceController.text,
                    ) ??
                    0;
                addEditController.productModel!.minSellingPrice =
                    double.tryParse(
                      addEditController.minSellingPriceController.text,
                    ) ??
                    0;
                addEditController.productModel!.profitRate =
                    double.tryParse(
                      addEditController.profitRateController.text,
                    ) ??
                    0;
                addEditController.productModel!.costPrice =
                    double.tryParse(
                      addEditController.productCostPriceController.text,
                    ) ??
                    0;
                addEditController.productModel!.qty =
                    double.tryParse(
                      addEditController.productQtyController.text,
                    ) ??
                    0;

                addEditController.productModel!.barcode = addEditController
                    .productBarcodeController
                    .text
                    .trim();
                addEditController.productModel!.expiryDate = addEditController
                    .expiryDateController
                    .text
                    .trim();

                addEditController.productModel!.isTracked =
                    addEditController.isTracked;
                addEditController.productModel!.enableNotification =
                    addEditController.enableNotification;
                addEditController.productModel!.discount =
                    double.tryParse(
                      addEditController.discountTextController.text,
                    ) ??
                    0;
                addEditController.productModel!.warningAlert =
                    double.tryParse(
                      addEditController.warningAlertController.text,
                    ) ??
                    1;

                addEditController.productModel!.isWeighted =
                    addEditController.isWeightedProduct;
                addEditController.productModel!.plu =
                    int.tryParse(
                      addEditController.pluTextContoller.text.trim(),
                    ) ??
                    0;
                addEditController.productModel!.isOffer =
                    ref.read(mainControllerProvider).isShowRestaurantStock
                    ? addEditController.offerOnMenu
                    : addEditController.isOffer;
                addEditController.productModel!.description = addEditController
                    .descriptionController
                    .text
                    .trim();
                //! after  adding product add their notes from categroy without access database
                // ! cz product added in temp list wihtout getting all new products from database

                //! case update
                if (addEditController.productModel?.id != null) {
                  productController.updateProduct(
                    fromNotifications: widget.fromNotifications ?? false,
                    p: addEditController.productModel!,
                    trackedRelatedProductModel:
                        addEditController.trackedRelatedProductList,
                    context: context,
                    isFromStock: widget.isFromStock,
                  );
                  if (ref.read(saleControllerProvider).basketItems.isNotEmpty) {
                    ref
                        .read(saleControllerProvider)
                        .onUpdateBasketProductPrice(
                          addEditController.productModel!,
                        );
                  }
                } else {
                  //! case add if (widget.c != null) {

                  productController.addProduct(
                    addEditController.productModel!,
                    addEditController.trackedRelatedProductList,
                    context,
                  );
                }
              }
            },
            child: const Icon(FontAwesomeIcons.floppyDisk, size: 20),
          ),
          defaultGap,
        ],
      ),
      body: context.isMobile
          ? ProductFormMobile(
              widget.p,
              category: widget.c,
            ).baseContainer(context.cardColor)
          : ProductForm(
              widget.p,
              category: widget.c,
            ).baseContainer(context.cardColor),
    );
  }
}
