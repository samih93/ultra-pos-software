import 'package:desktoppossystem/controller/category_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/category_model.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/screens/add_edit_category/add_edit_category_screen.dart';
import 'package:desktoppossystem/screens/add_edit_product/add_edit_product_controller.dart';
import 'package:desktoppossystem/screens/add_edit_product/components/add_related_tracked_dialog.dart';
import 'package:desktoppossystem/screens/add_edit_product/components/related_tracked_item.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/products/products_settings_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/custom_toggle_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductFormMobile extends ConsumerStatefulWidget {
  final ProductModel? p;
  final CategoryModel? category;
  const ProductFormMobile(this.p, {this.category, Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ProductFormMobileState();
}

class _ProductFormMobileState extends ConsumerState<ProductFormMobile> {
  List<CategoryModel> categories = [];
  late TextEditingController qtyController;

  @override
  void initState() {
    super.initState();
    qtyController = TextEditingController();
    qtyController.text = widget.p?.qty?.toString() ?? "0";
  }

  @override
  void dispose() {
    qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    categories = ref.watch(categoryControllerProvider).categories;
    var addEditcontroller = ref.watch(addEditProductControllerProvider);

    if (categories.isNotEmpty) {
      categories.sort((a, b) => a.name!.compareTo(b.name!));
    }

    return Form(
      key: addEditcontroller.formkey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Toggle
            _buildNotificationToggle(addEditcontroller),
            SizedBox(height: 16.h),

            // Category Section
            _buildCategorySection(addEditcontroller),
            SizedBox(height: 16.h),

            // Name & Barcode
            _buildNameField(addEditcontroller),
            SizedBox(height: 12.h),
            _buildBarcodeField(addEditcontroller),
            SizedBox(height: 16.h),

            // Pricing Section
            if (ref.read(mainControllerProvider).isSuperAdmin) ...[
              _buildPricingSection(addEditcontroller),
              SizedBox(height: 16.h),
            ],

            // Selling Price Section
            _buildSellingPriceSection(addEditcontroller),
            SizedBox(height: 16.h),

            // Discount
            _buildDiscountField(addEditcontroller),
            SizedBox(height: 12.h),

            // Min Selling Price
            if (ref
                .read(productsSettingsControllerProvider)
                .showMinSellingPrice) ...[
              _buildMinSellingPriceField(addEditcontroller),
              SizedBox(height: 12.h),
            ],

            // Quantity & Tracked
            _buildQuantitySection(addEditcontroller),
            SizedBox(height: 12.h),

            // Expiry Date
            _buildExpiryDateField(addEditcontroller),
            SizedBox(height: 12.h),

            // Warning Alert
            _buildWarningAlertField(addEditcontroller),
            SizedBox(height: 12.h),

            // Description
            _buildDescriptionField(addEditcontroller),
            SizedBox(height: 16.h),

            // Related Tracked Products
            if (!ref.read(mainControllerProvider).isShowRestaurantStock &&
                !addEditcontroller.isTracked)
              _buildRelatedProductsSection(addEditcontroller),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle(dynamic controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: DefaultTextView(
            text: S.of(context).enableDisableNotification,
            fontSize: 14.spMax,
          ),
        ),
        CustomToggleButton(
          text1: S.of(context).on.capitalizeFirstLetter(),
          text2: S.of(context).off.capitalizeFirstLetter(),
          isSelected: controller.enableNotification,
          onPressed: (value) {
            ref
                .read(addEditProductControllerProvider)
                .onChangeNotificationStatus();
          },
        ),
      ],
    );
  }

  Widget _buildCategorySection(dynamic controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultTextView(text: S.of(context).category, fontSize: 14.spMax),
        SizedBox(height: 8.h),
        Container(
          height: 50.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            borderRadius: defaultRadius,
            border: Border.all(width: 1, color: Pallete.greyColor),
          ),
          child: DropdownMenu<String>(
            menuHeight: 300.h,
            width: context.width - 72.w,
            enableSearch: true,
            enableFilter: true,
            hintText: S.of(context).selectCategory,
            initialSelection: controller.selectedCategoryId.toString(),
            inputDecorationTheme: const InputDecorationTheme(
              contentPadding: EdgeInsets.only(bottom: 8),
              border: InputBorder.none,
            ),
            onSelected: (value) => controller.onchangeCategory(value!),
            dropdownMenuEntries: [
              ...categories.map(
                (e) => DropdownMenuEntry<String>(
                  value: e.id.toString(),
                  label: '${e.name}',
                ),
              ),
            ],
          ),
        ),
        if (ref.read(mainControllerProvider).screenUI == ScreenUI.market) ...[
          SizedBox(height: 8.h),
          TextButton.icon(
            onPressed: () => context.to(const AddEditCategoryScreen(null)),
            icon: Icon(Icons.add, size: 18.spMax),
            label: Text(S.of(context).add),
          ),
        ],
      ],
    );
  }

  Widget _buildNameField(dynamic controller) {
    return AppTextFormField(
      showText: true,
      inputtype: TextInputType.name,
      controller: controller.productNameController,
      hinttext: S.of(context).name.capitalizeFirstLetter(),
      onvalidate: (value) {
        if (value!.isEmpty) {
          return S.of(context).nameMustBeNotEmpty;
        }
        return null;
      },
    );
  }

  Widget _buildBarcodeField(dynamic controller) {
    return BarcodeKeyboardListener(
      bufferDuration: const Duration(milliseconds: 200),
      onBarcodeScanned: (barcode) {
        if (barcode.isNotEmpty) {
          controller.productBarcodeController.text = barcode.trim();
        }
      },
      child: AppTextFormField(
        showText: true,
        inputtype: TextInputType.text,
        controller: controller.productBarcodeController,
        hinttext: S.of(context).barcode.capitalizeFirstLetter(),
      ),
    );
  }

  Widget _buildPricingSection(dynamic controller) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTextView(
              text: S.of(context).costPrice.capitalizeFirstLetter(),
              fontSize: 14.spMax,
            ),
            SizedBox(height: 8.h),
            AppTextFormField(
              showText: true,
              inputtype: TextInputType.phone,
              onchange: (value) {
                double newValue = double.tryParse(value.toString()) ?? 0;
                ref
                    .read(addEditProductControllerProvider)
                    .onchangeCost(newValue);
              },
              format: numberTextFormatter,
              controller: controller.productCostPriceController,
              hinttext:
                  "${S.of(context).costPrice} (${AppConstance.primaryCurrency.currencyLocalization()})",
              onvalidate: (value) {
                double? price = double.tryParse(value.toString());
                if (price == null) {
                  return 'Cost Price must be a Number';
                }
                return null;
              },
            ),
            SizedBox(height: 8.h),
            AppTextFormField(
              showText: true,
              inputtype: TextInputType.phone,
              onchange: (value) {
                double costSecondary = double.tryParse(value.toString()) ?? 0;
                ref
                    .read(addEditProductControllerProvider)
                    .onChangeSecondaryCostPrice(costSecondary);
              },
              format: numberTextFormatter,
              controller: controller.productSecondaryCostPriceController,
              hinttext:
                  "${S.of(context).costPrice} (${AppConstance.secondaryCurrency.currencyLocalization()})",
              onvalidate: (value) {
                double? price = double.tryParse(value.toString());
                if (price == null) {
                  return 'Cost Price must be a Number';
                }
                return null;
              },
            ),
            SizedBox(height: 8.h),
            AppTextFormField(
              showText: true,
              inputtype: TextInputType.phone,
              onchange: (value) {
                double newProfitRate = double.tryParse(value.toString()) ?? 0;
                ref
                    .read(addEditProductControllerProvider)
                    .onchangeProfitRate(newProfitRate);
              },
              format: numberTextFormatter,
              controller: controller.profitRateController,
              hinttext: S.of(context).profitRate.capitalizeFirstLetter(),
              suffixIcon: const Icon(Icons.percent),
              onvalidate: (value) => null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellingPriceSection(dynamic controller) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DefaultTextView(
                  text: S.of(context).sellingPrice.capitalizeFirstLetter(),
                  fontSize: 14.spMax,
                ),
                Row(
                  children: [
                    DefaultTextView(
                      text: S.of(context).autoUpdateSellingPrice,
                      fontSize: 12.spMax,
                    ),
                    Checkbox(
                      value: controller.autoUpdateSellingPrice,
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
            SizedBox(height: 8.h),
            AppTextFormField(
              showText: true,
              inputtype: TextInputType.phone,
              format: numberTextFormatter,
              controller: controller.productSellingPriceController,
              hinttext:
                  "${S.of(context).sellingPrice} (${AppConstance.primaryCurrency.currencyLocalization()})",
              onchange: (value) {
                double newValue = double.tryParse(value.toString()) ?? 0;
                ref
                    .read(addEditProductControllerProvider)
                    .onchangeSellingPrice(newValue);
              },
              onvalidate: (value) {
                double? price = double.tryParse(value.toString());
                if (price == null) {
                  return S.of(context).sellingPriceMustBeNotEmpty;
                }
                return null;
              },
            ),
            SizedBox(height: 8.h),
            AppTextFormField(
              showText: true,
              inputtype: TextInputType.phone,
              format: numberTextFormatter,
              controller: controller.productSecondarySellingPriceController,
              hinttext:
                  "${S.of(context).sellingPrice} (${AppConstance.secondaryCurrency.currencyLocalization()})",
              onchange: (value) {
                ref
                    .read(addEditProductControllerProvider)
                    .onChangeSecondarySellingPrice(
                      value.toString().validateDouble(),
                    );
              },
              onvalidate: (value) {
                double? price = double.tryParse(value.toString());
                if (price == null) {
                  return S.of(context).sellingPriceMustBeNotEmpty;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountField(dynamic controller) {
    return AppTextFormField(
      showText: true,
      inputtype: TextInputType.phone,
      format: numberTextFormatter,
      controller: controller.discountTextController,
      hinttext: S.of(context).discount,
      suffixIcon: const Icon(Icons.percent),
    );
  }

  Widget _buildMinSellingPriceField(dynamic controller) {
    return AppTextFormField(
      showText: true,
      inputtype: TextInputType.phone,
      format: numberTextFormatter,
      controller: controller.minSellingPriceController,
      hinttext: S.of(context).minSellingPrice,
    );
  }

  Widget _buildQuantitySection(dynamic controller) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DefaultTextView(
                  text: S.of(context).qty.capitalizeFirstLetter(),
                  fontSize: 14.spMax,
                ),
                Row(
                  children: [
                    DefaultTextView(
                      textDecoration: controller.isTracked
                          ? TextDecoration.none
                          : TextDecoration.lineThrough,
                      text: S.of(context).tracked,
                      fontSize: 14.spMax,
                      color: controller.isTracked
                          ? context.primaryColor
                          : Colors.grey,
                    ),
                    Checkbox(
                      value: controller.isTracked,
                      onChanged: (value) {
                        ref
                            .read(addEditProductControllerProvider)
                            .onChangeTrackProduct();
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),
            AppTextFormField(
              showText: true,
              inputtype: TextInputType.phone,
              format: numberTextFormatter,
              controller: qtyController,
              onchange: (value) {
                final newQty = double.tryParse(value.toString()) ?? 0;
                controller.productQtyController.text = newQty.toString();
              },
              hinttext: S.of(context).qty.capitalizeFirstLetter(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryDateField(dynamic controller) {
    return AppTextFormField(
      showText: true,
      inputtype: TextInputType.datetime,
      controller: controller.expiryDateController,
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
            firstDate: DateTime.now().subtract(const Duration(days: 90)),
            lastDate: DateTime.parse('2050-01-01'),
          );
          if (selectedDate != null) {
            final formattedDate =
                "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
            controller.expiryDateController.text = formattedDate;
            controller.onchangeExpiryDate(formattedDate);
          }
        },
        icon: const Icon(Icons.calendar_month),
      ),
      readonly: false,
      format: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
        DateInputFormatter(),
      ],
      onchange: (value) {
        if (value.length > 10) return;
        if (!value.isValidDate()) {
          if (value.length == 10) {
            ToastUtils.showToast(
              message: "Invalid date format. Please use yyyy-mm-dd",
              type: RequestState.error,
            );
          }
        }
      },
    );
  }

  Widget _buildWarningAlertField(dynamic controller) {
    return AppTextFormField(
      showText: true,
      inputtype: TextInputType.phone,
      format: numberTextFormatter,
      controller: controller.warningAlertController,
      hinttext: S.of(context).warningAlert,
      onvalidate: (value) => null,
    );
  }

  Widget _buildDescriptionField(dynamic controller) {
    return AppTextFormField(
      showText: true,
      inputtype: TextInputType.text,
      controller: controller.descriptionController,
      hinttext: S.of(context).description,
      onvalidate: (value) => null,
    );
  }

  Widget _buildRelatedProductsSection(dynamic controller) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: DefaultTextView(
                    text: S.of(context).addNeedsFromStock,
                    fontSize: 14.spMax,
                    color: context.primaryColor,
                  ),
                ),
                Checkbox(
                  value: !controller.isTracked,
                  onChanged: (value) {
                    ref
                        .read(addEditProductControllerProvider)
                        .onChangeTrackProduct();
                  },
                ),
              ],
            ),
            SizedBox(height: 8.h),
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
            if (controller.trackedRelatedProductList.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  ...controller.trackedRelatedProductList.map(
                    (e) => RelatedTrackedItem(e),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
