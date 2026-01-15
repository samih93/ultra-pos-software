import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:desktoppossystem/controller/category_controller.dart';
import 'package:desktoppossystem/controller/setting_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/category_model.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/repositories/menu_repository/menu_repository.dart';
import 'package:desktoppossystem/screens/add_edit_category/add_edit_category_screen.dart';
import 'package:desktoppossystem/screens/add_edit_product/add_edit_product_controller.dart';
import 'package:desktoppossystem/screens/add_edit_product/components/add_related_tracked_dialog.dart';
import 'package:desktoppossystem/screens/add_edit_product/components/related_tracked_item.dart';
import 'package:desktoppossystem/screens/add_edit_product/components/weighted_section.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/products/products_settings_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/cached_network_image_widget.dart';
import 'package:desktoppossystem/shared/default%20components/custom_toggle_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_outline_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductForm extends ConsumerStatefulWidget {
  final ProductModel? p;
  final CategoryModel? category;
  // final bool? isRestaurantStock;
  const ProductForm(this.p, {this.category, Key? key}) : super(key: key);
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<ProductForm> {
  List<CategoryModel> categories = [];

  late TextEditingController categoryTextController;
  late TextEditingController qtyController; // Controller for quantity field
  bool _isDragging = false; // Track drag state for visual feedback

  @override
  void initState() {
    super.initState();
    qtyController = TextEditingController();
    categoryTextController = TextEditingController();
    qtyController.text = widget.p?.qty?.toString() ?? "0";
  }

  @override
  void dispose() {
    categoryTextController.dispose();
    qtyController.dispose();
    super.dispose();
  }

  ValueNotifier<bool> isUploading = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    categories = ref.watch(categoryControllerProvider).categories;
    ScreenUI screenUI = ref.read(mainControllerProvider).screenUI;
    double dolarRate = ref.read(saleControllerProvider).dolarRate;
    var addEditcontroller = ref.watch(addEditProductControllerProvider);

    if (categories.isNotEmpty) {
      categories.sort((a, b) => a.name!.compareTo(b.name!));
    }

    return Center(
      child: SizedBox(
        width: context.width * 0.85,
        height: context.height - kToolbarHeight - 22,
        child: Form(
          key: addEditcontroller.formkey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: .start,
              children: [
                kGap10,
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: .start,
                      children: [
                        Row(
                          children: [
                            DefaultTextView(
                              text: S.of(context).enableDisableNotification,
                            ),
                            kGap5,
                            CustomToggleButton(
                              text1: S.of(context).on.capitalizeFirstLetter(),
                              text2: S.of(context).off.capitalizeFirstLetter(),
                              isSelected: addEditcontroller.enableNotification,
                              onPressed: (value) {
                                ref
                                    .read(addEditProductControllerProvider)
                                    .onChangeNotificationStatus();
                              },
                            ),
                          ],
                        ),
                        kGap5,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: .start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: DefaultTextView(
                                    text: S.of(context).category,
                                  ),
                                ),
                                Container(
                                  height: 45,
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: defaultRadius,
                                    border: Border.all(
                                      width: 1,
                                      color: Pallete.greyColor,
                                    ),
                                  ),
                                  child: DropdownMenu<String>(
                                    menuHeight: 300,
                                    //  controller: categoryTextController,
                                    width: 250,
                                    enableSearch: true,
                                    enableFilter: true,
                                    hintText: S.of(context).selectCategory,
                                    //   dropdownColor: Colors.white,
                                    initialSelection: addEditcontroller
                                        .selectedCategoryId
                                        .toString(),
                                    inputDecorationTheme:
                                        const InputDecorationTheme(
                                          contentPadding: EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                    onSelected: (value) => addEditcontroller
                                        .onchangeCategory(value!),
                                    searchCallback: (entries, query) {
                                      final String searchText =
                                          categoryTextController.value.text
                                              .toLowerCase();
                                      if (searchText.isEmpty) {
                                        return null;
                                      }
                                      final int index = entries.indexWhere(
                                        (DropdownMenuEntry<String> entry) =>
                                            entry.label.toLowerCase().contains(
                                              searchText,
                                            ),
                                      );

                                      return index != -1 ? index : null;
                                    },
                                    dropdownMenuEntries: [
                                      ...categories
                                          .map(
                                            (e) => DropdownMenuEntry<String>(
                                              value: e.id.toString(),
                                              label: '${e.name}',
                                            ),
                                          )
                                          .toList(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            kGap10,
                            if (ref.read(mainControllerProvider).screenUI ==
                                ScreenUI.market)
                              DefaultOutlineButton(
                                name: "${S.of(context).add} ",
                                fontSize: 16,
                                onpress: () {
                                  context.to(const AddEditCategoryScreen(null));
                                },
                              ),
                            SizedBox(
                              width: 200,
                              child: AppTextFormField(
                                showText: true,
                                inputtype: TextInputType.phone,
                                format: numberTextFormatter,
                                controller:
                                    addEditcontroller.discountTextController,
                                hinttext: S.of(context).discount,
                                suffixIcon: const Icon(Icons.percent),
                              ),
                            ),
                            kGap5,
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        DropTarget(
                          onDragEntered: (details) {
                            setState(() {
                              _isDragging = true;
                            });
                          },
                          onDragExited: (details) {
                            setState(() {
                              _isDragging = false;
                            });
                          },
                          onDragDone: (details) async {
                            setState(() {
                              _isDragging = false;
                            });
                            // Handle the dropped files
                            for (var file in details.files) {
                              final fileName = file.path.toLowerCase();
                              // Check if it's an image file
                              if (fileName.endsWith('.png') ||
                                  fileName.endsWith('.webp') ||
                                  fileName.endsWith('.jpg') ||
                                  fileName.endsWith('.jpeg') ||
                                  fileName.endsWith('.gif')) {
                                // Read the file and set it as the product image
                                final imageFile = File(file.path);
                                final bytes = await imageFile.readAsBytes();
                                addEditcontroller.pickedProductFile = imageFile;
                                addEditcontroller
                                        .productModel!
                                        .pickedImageFile =
                                    imageFile;

                                break; // Only take the first valid image
                              }
                            }
                          },
                          child: GestureDetector(
                            onTap: () async {
                              addEditcontroller.pickProductImage();
                            },
                            child: Container(
                              width: context.width * .12,
                              height: context.width * .12,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: _isDragging
                                    ? Border.all(
                                        color: context.primaryColor,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child:
                                  (addEditcontroller.pickedProductFile !=
                                          null ||
                                      (addEditcontroller.productModel != null &&
                                          addEditcontroller
                                                  .productModel!
                                                  .image !=
                                              null))
                                  ? Stack(
                                      alignment: AlignmentDirectional.topEnd,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child:
                                              addEditcontroller
                                                      .pickedProductFile !=
                                                  null
                                              ? Image.file(
                                                  addEditcontroller
                                                      .pickedProductFile!,
                                                  width: context.width * .12,
                                                  height: context.width * .12,
                                                  fit: BoxFit.cover,
                                                )
                                              : CachedNetworkImageWidget(
                                                  imageUrl: addEditcontroller
                                                      .productModel!
                                                      .image!,
                                                  width: context.width * .12,
                                                  height: context.width * .12,
                                                ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            addEditcontroller.removeImage();
                                          },
                                          icon: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.2),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.close,
                                              color: context.primaryColor,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: _isDragging
                                            ? context.primaryColor.withValues(
                                                alpha: 0.1,
                                              )
                                            : Pallete.greyColor.withValues(
                                                alpha: 0.3,
                                              ),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _isDragging
                                              ? context.primaryColor
                                              : Pallete.greyColor.withValues(
                                                  alpha: 0.5,
                                                ),
                                          width: _isDragging ? 2 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _isDragging
                                                ? Icons.upload
                                                : Icons.backup,
                                            color: context.primaryColor,
                                            size: 40,
                                          ),
                                          DefaultTextView(
                                            text: _isDragging
                                                ? 'Drop image here'
                                                : S.of(context).pickImage,
                                            textAlign: TextAlign.center,
                                            fontSize: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: AppTextFormField(
                        showText: true,
                        inputtype: TextInputType.name,
                        controller: addEditcontroller.productNameController,
                        hinttext: S.of(context).name.capitalizeFirstLetter(),
                        onvalidate: (value) {
                          if (value!.isEmpty) {
                            return S.of(context).nameMustBeNotEmpty;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: BarcodeKeyboardListener(
                        bufferDuration: const Duration(milliseconds: 200),
                        onBarcodeScanned: (barcode) {
                          if (barcode.isNotEmpty) {
                            addEditcontroller.productBarcodeController.text =
                                barcode.trim();
                          }
                        },
                        child: AppTextFormField(
                          showText: true,
                          inputtype: TextInputType.text,
                          // format: <TextInputFormatter>[
                          //   FilteringTextInputFormatter.allow(
                          //       RegExp(r'^\d+\.?\d{0,2}')),
                          // ],
                          controller:
                              addEditcontroller.productBarcodeController,
                          hinttext: S
                              .of(context)
                              .barcode
                              .capitalizeFirstLetter(),
                        ),
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (ref
                              .read(mainControllerProvider)
                              .isSuperAdmin) ...[
                            Expanded(
                              flex: 2,
                              child: AppTextFormField(
                                showText: true,
                                inputtype: TextInputType.phone,
                                onchange: (value) {
                                  double newValue =
                                      double.tryParse(value.toString()) ?? 0;
                                  ref
                                      .read(addEditProductControllerProvider)
                                      .onchangeCost(newValue);
                                },
                                format: numberTextFormatter,
                                controller: addEditcontroller
                                    .productCostPriceController,
                                hinttext:
                                    S
                                        .of(context)
                                        .costPrice
                                        .capitalizeFirstLetter() +
                                    "(${AppConstance.primaryCurrency.currencyLocalization()})",
                                onvalidate: (value) {
                                  double? price = double.tryParse(
                                    value.toString(),
                                  );
                                  if (price == null) {
                                    return 'Cost Price must be a Number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            kGap10,
                            Expanded(
                              flex: 3,
                              child: AppTextFormField(
                                showText: true,
                                inputtype: TextInputType.phone,
                                onchange: (value) {
                                  double costSecondary =
                                      double.tryParse(value.toString()) ?? 0;
                                  ref
                                      .read(addEditProductControllerProvider)
                                      .onChangeSecondaryCostPrice(
                                        costSecondary,
                                      );
                                },
                                format: numberTextFormatter,
                                controller: addEditcontroller
                                    .productSecondaryCostPriceController,
                                hinttext:
                                    S
                                        .of(context)
                                        .costPrice
                                        .capitalizeFirstLetter() +
                                    "(${AppConstance.secondaryCurrency.currencyLocalization()})",
                                onvalidate: (value) {
                                  double? price = double.tryParse(
                                    value.toString(),
                                  );
                                  if (price == null) {
                                    return 'Cost Price must be a Number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            kGap10,
                          ],
                          Expanded(
                            flex: 2,
                            child: AppTextFormField(
                              showText: true,
                              inputtype: TextInputType.phone,
                              onchange: (value) {
                                double newProfitRate =
                                    double.tryParse(value.toString()) ?? 0;
                                ref
                                    .read(addEditProductControllerProvider)
                                    .onchangeProfitRate(newProfitRate);
                              },
                              format: numberTextFormatter,
                              controller:
                                  addEditcontroller.profitRateController,
                              hinttext: S
                                  .of(context)
                                  .profitRate
                                  .capitalizeFirstLetter(),
                              suffixIcon: const Icon(Icons.percent),
                              onvalidate: (value) {
                                return null;

                                // double? price =
                                //     double.tryParse(value.toString());
                                // if (price == null) {
                                //   return 'Profit Rate must be a Number';
                                // }
                                // return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    kGap20,
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 5),
                        padding: kPadd3,
                        decoration: BoxDecoration(
                          border: Border.all(color: Pallete.greyColor),
                          borderRadius: defaultRadius,
                        ),
                        child: Row(
                          mainAxisAlignment: .center,
                          children: [
                            Expanded(
                              child: AppTextFormField(
                                showText: true,
                                inputtype: TextInputType.phone,
                                format: numberTextFormatter,
                                controller: addEditcontroller
                                    .productSellingPriceController,
                                hinttext:
                                    S
                                        .of(context)
                                        .sellingPrice
                                        .capitalizeFirstLetter() +
                                    "(${AppConstance.primaryCurrency.currencyLocalization()})",
                                onchange: (value) {
                                  double newValue =
                                      double.tryParse(value.toString()) ?? 0;
                                  ref
                                      .read(addEditProductControllerProvider)
                                      .onchangeSellingPrice(newValue);
                                },
                                onvalidate: (value) {
                                  double? price = double.tryParse(
                                    value.toString(),
                                  );
                                  if (price == null) {
                                    return S
                                        .of(context)
                                        .sellingPriceMustBeNotEmpty;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            kGap10,
                            Expanded(
                              flex: 2,
                              child: AppTextFormField(
                                showText: true,
                                inputtype: TextInputType.phone,
                                format: numberTextFormatter,
                                controller: addEditcontroller
                                    .productSecondarySellingPriceController,
                                hinttext:
                                    S
                                        .of(context)
                                        .sellingPrice
                                        .capitalizeFirstLetter() +
                                    "(${AppConstance.secondaryCurrency.currencyLocalization()})",
                                onchange: (value) {
                                  ref
                                      .read(addEditProductControllerProvider)
                                      .onChangeSecondarySellingPrice(
                                        value.toString().validateDouble(),
                                      );
                                },
                                onvalidate: (value) {
                                  double? price = double.tryParse(
                                    value.toString(),
                                  );
                                  if (price == null) {
                                    return S
                                        .of(context)
                                        .sellingPriceMustBeNotEmpty;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Column(
                              mainAxisAlignment: .center,
                              crossAxisAlignment: .end,
                              children: [
                                DefaultTextView(
                                  text: S
                                      .of(context)
                                      .autoUpdateSellingPrice
                                      .capitalizeFirstLetter(),
                                ),
                                Checkbox(
                                  value:
                                      addEditcontroller.autoUpdateSellingPrice,
                                  onChanged: (value) {
                                    ref
                                        .read(addEditProductControllerProvider)
                                        .toggleAutoUpdateSellingPrice();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (ref
                        .read(productsSettingsControllerProvider)
                        .showMinSellingPrice) ...[
                      Expanded(
                        child: AppTextFormField(
                          showText: true,
                          inputtype: TextInputType.phone,
                          format: numberTextFormatter,
                          controller:
                              addEditcontroller.minSellingPriceController,
                          hinttext: S.of(context).minSellingPrice,
                        ),
                      ),
                      kGap20,
                    ],
                    Expanded(
                      child: Listener(
                        onPointerSignal: (event) {
                          if (event is PointerScrollEvent) {
                            // Get current quantity
                            double currentQty =
                                double.tryParse(
                                  addEditcontroller.productQtyController.text,
                                ) ??
                                0;

                            // Adjust quantity based on the scroll direction
                            if (event.scrollDelta.dy > 0) {
                              currentQty += 1; // Scroll down (increase)
                            } else if (event.scrollDelta.dy < 0) {
                              currentQty -= 1; // Scroll up (decrease)
                            }

                            // Prevent negative quantities
                            if (currentQty < 0) currentQty = 0;

                            qtyController.text = currentQty
                                .toString(); // Update controller value
                            addEditcontroller.productQtyController.text =
                                currentQty.toString();
                          }
                        },
                        child: AppTextFormField(
                          showText: true,
                          suffixIcon: SizedBox(
                            width: context.isWindows ? 120 : 140,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                DefaultTextView(
                                  textDecoration: addEditcontroller.isTracked
                                      ? TextDecoration.none
                                      : TextDecoration.lineThrough,
                                  text: S.of(context).tracked,
                                  fontSize: 20,
                                  color: addEditcontroller.isTracked
                                      ? context.primaryColor
                                      : Colors.grey,
                                ),
                                Checkbox(
                                  value: addEditcontroller.isTracked,
                                  onChanged: (value) {
                                    ref
                                        .read(addEditProductControllerProvider)
                                        .onChangeTrackProduct();
                                  },
                                ),
                              ],
                            ),
                          ),
                          inputtype: TextInputType.phone,
                          format: numberTextFormatter,
                          controller: qtyController,
                          onchange: (value) {
                            final newQty =
                                double.tryParse(value.toString()) ?? 0;
                            addEditcontroller.productQtyController.text = newQty
                                .toString();
                          },
                          hinttext: S.of(context).qty.capitalizeFirstLetter(),
                        ),
                      ),
                    ),
                    kGap20,
                    Expanded(
                      child: AppTextFormField(
                        showText: true,
                        inputtype:
                            TextInputType.datetime, // Use number input type
                        controller: addEditcontroller.expiryDateController,
                        hinttext:
                            "${S.of(context).expiryDate.capitalizeFirstLetter()} (yyyy-mm-dd)",
                        onvalidate: (expDate) {
                          if (expDate.toString().trim().isNotEmpty &&
                              expDate.toString().validateDate() != null) {
                            return expDate.toString().validateDate();
                          }
                          return null;
                        },
                        suffixIcon: IconButton(
                          onPressed: () async {
                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 90),
                              ),
                              lastDate: DateTime.parse('2050-01-01'),
                            );
                            if (selectedDate != null) {
                              // Format the selected date as YYYY-MM-DD
                              final formattedDate =
                                  "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                              addEditcontroller.expiryDateController.text =
                                  formattedDate;
                              addEditcontroller.onchangeExpiryDate(
                                formattedDate,
                              );
                            }
                          },
                          icon: const Icon(Icons.calendar_month),
                        ),
                        readonly: false,

                        format: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9-]'),
                          ), // Allow only numbers and '/'
                          DateInputFormatter(), // Custom formatter to enforce date format
                        ],
                        onchange: (value) {
                          if (value.length > 10) return;
                          if (!value.isValidDate()) {
                            if (value.length == 10) {
                              ToastUtils.showToast(
                                message:
                                    "Invalid date format. Please use yyyy-mm-dd",
                                type: RequestState.error,
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: AppTextFormField(
                        showText: true,
                        inputtype: TextInputType.phone,
                        format: numberTextFormatter,
                        controller: addEditcontroller.warningAlertController,
                        hinttext: S.of(context).warningAlert,
                        onvalidate: (value) {
                          return null;
                        },
                      ),
                    ),
                    kGap10,
                    !ref.read(productsSettingsControllerProvider).isUsingScale
                        ? Expanded(
                            child: AppTextFormField(
                              showText: true,
                              inputtype: TextInputType.text,
                              controller:
                                  addEditcontroller.descriptionController,
                              hinttext: S.of(context).description,
                              onvalidate: (value) {
                                return null;
                              },
                            ),
                          )
                        : const Expanded(child: WeightedSection()),
                  ],
                ),
                // if using scale show description field in next row
                if (ref
                    .read(productsSettingsControllerProvider)
                    .isUsingScale) ...[
                  kGap10,
                  AppTextFormField(
                    showText: true,
                    inputtype: TextInputType.text,
                    controller: addEditcontroller.descriptionController,
                    hinttext: S.of(context).description,
                    onvalidate: (value) {
                      return null;
                    },
                  ),
                ],

                kGap10,
                if (!ref.read(mainControllerProvider).isShowRestaurantStock &&
                    !addEditcontroller.isTracked)
                  Column(
                    crossAxisAlignment: .start,
                    children: [
                      Row(
                        children: [
                          DefaultTextView(
                            text: S.of(context).addNeedsFromStock,
                            fontSize: 20,
                            color: context.primaryColor,
                          ),
                          //! if selected so product not tracked
                          Checkbox(
                            value: !addEditcontroller.isTracked,
                            onChanged: (value) {
                              ref
                                  .read(addEditProductControllerProvider)
                                  .onChangeTrackProduct();
                            },
                          ),
                          kGap15,
                          ElevatedButtonWidget(
                            icon: Icons.add,
                            text: S.of(context).addFromStock,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (dialogContext) =>
                                    const AddRelatedTrackedProductDialog(),
                              );
                            },
                          ),
                          kGap10,
                        ],
                      ),
                      kGap10,
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: [
                          ...addEditcontroller.trackedRelatedProductList.map(
                            (e) => RelatedTrackedItem(e),
                          ),
                        ],
                      ),
                    ],
                  ),
                kGap10,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
