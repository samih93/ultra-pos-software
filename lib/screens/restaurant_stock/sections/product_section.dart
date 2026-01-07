import 'package:desktoppossystem/controller/product_controller.dart';
import 'package:desktoppossystem/controller/restaurant_stock_controller.dart';
import 'package:desktoppossystem/models/ingrendient_model.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/sandwiches_ingredients.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/are_you_sure_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_title_section.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';

import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../generated/l10n.dart';
import '../../../shared/default components/default_text_view.dart';
import '../../../controller/search_product_controller.dart';

class ProductSection extends ConsumerStatefulWidget {
  const ProductSection({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProductSectionState();
}

class _ProductSectionState extends ConsumerState<ProductSection> {
  var textSearchAndSelectProductController = TextEditingController();

  Future saveIngrendientsToSandwich() async {
    int? productId = ref.read(selectedSandwichProvider)?.id;
    List<IngredientModel> ingredients = ref
        .read(selectedIngredientsProvider)
        .toList();
    List<SandwichesIngredients> list = [];
    if (ingredients.isNotEmpty) {
      for (var item in ingredients) {
        SandwichesIngredients sandwichesIngredients = SandwichesIngredients(
          ingredientId: item.id!,
          productId: productId!,
        );
        list.add(sandwichesIngredients);
      }
      await ref
          .read(restaurantStockControllerProvider)
          .addSandwichesIngredients(list);
      ref.refresh(futureingredientsBySandwichProvider);
      ref.invalidate(selectedIngredientsProvider);
    }
  }

  @override
  void initState() {
    super.initState();
    final selectedSandwich = ref.read(selectedSandwichProvider);

    if (selectedSandwich != null) {
      textSearchAndSelectProductController.text = selectedSandwich.name
          .toString();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedSandwich = ref.watch(selectedSandwichProvider);

    if (selectedSandwich != null) {
      textSearchAndSelectProductController.text = selectedSandwich.name
          .toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSaveEnabled =
        ref.watch(selectedSandwichProvider)?.id != null &&
        ref.watch(selectedIngredientsProvider).isNotEmpty;
    final futureIngredientBySandiwch = ref.watch(
      futureingredientsBySandwichProvider,
    );
    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppTextTitleSection(S.of(context).items),
            Row(
              children: [
                if (ref.watch(mainControllerProvider).isAdmin)
                  Tooltip(
                    message:
                        "${S.of(context).download.capitalizeFirstLetter()} ${S.of(context).items} (${S.of(context).costPrice}/${S.of(context).sellingPrice})",
                    child: ElevatedButtonWidget(
                      icon: FontAwesomeIcons.fileExcel,
                      states: [
                        ref
                            .watch(restaurantStockControllerProvider)
                            .downloadItemsRequestState,
                      ],
                      text: S.of(context).items,
                      onPressed: () async {
                        await ref
                            .read(restaurantStockControllerProvider)
                            .fetchAndDownloadItems();
                      },
                    ),
                  ),
                if (ref.watch(mainControllerProvider).isAdmin) ...[
                  kGap10,
                  Tooltip(
                    message:
                        "${S.of(context).download.capitalizeFirstLetter()} ${S.of(context).items} ${S.of(context).ingredients}",
                    child: ElevatedButtonWidget(
                      onPressed: () async {
                        await ref
                            .read(restaurantStockControllerProvider)
                            .fetchAndDownloadItemsWithIngredients();
                      },
                      states: [
                        ref
                            .watch(restaurantStockControllerProvider)
                            .downloadItemsWithIngredientsRequestState,
                      ],
                      text: S.of(context).ingredients,
                      icon: FontAwesomeIcons.fileExcel,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        kGap10,
        TypeAheadField<ProductModel>(
          hideOnError: true,
          hideOnEmpty: true,
          builder: (context, controller, focusNode) {
            String name = textSearchAndSelectProductController.text;
            controller.text = name;
            textSearchAndSelectProductController = controller;
            return AppTextFormField(
              readonly: ref.watch(selectedSandwichProvider) != null
                  ? true
                  : false,
              inputtype: TextInputType.text,
              controller: textSearchAndSelectProductController,
              focusNode: focusNode,
              suffixIcon: ref.watch(selectedSandwichProvider) != null
                  ? IconButton(
                      onPressed: () {
                        ref.read(selectedSandwichProvider.notifier).state =
                            null;
                        textSearchAndSelectProductController.clear();
                      },
                      icon: const Icon(Icons.close),
                    )
                  : kEmptyWidget,
              hinttext: " ${S.of(context).searchByName} ",
            );
          },
          itemBuilder: (context, ProductModel? suggestion) {
            return Stack(
              alignment: AlignmentDirectional.topEnd,
              children: [
                Column(
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      tileColor: Colors.white,
                      title: DefaultTextView(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        text: "${suggestion?.name}",
                      ),
                      subtitle: DefaultTextView(
                        fontSize: 12,
                        color: Colors.black,
                        text: "${suggestion?.sellingPrice} \$",
                      ),
                    ),
                    const Divider(color: Colors.grey, height: 1),
                  ],
                ),
              ],
            );
          },
          suggestionsCallback: (String query) async {
            if (query.trim() == "") return [];
            var products = await ref
                .read(searchProductControllerProvider)
                .searchForAProductOrASandwich(query);
            return products.toList();
          },
          onSelected: (ProductModel value) {
            textSearchAndSelectProductController.text = value.name.toString();
            ref.read(selectedSandwichProvider.notifier).state = value;
            ref.invalidate(searchProductControllerProvider);
            ref.invalidate(selectedIngredientsProvider);
          },
        ),
        kGap20,
        futureIngredientBySandiwch.when(
          data: (data) {
            if (data.isNotEmpty) {
              return Expanded(
                child: Column(
                  children: [
                    DefaultTextView(
                      text:
                          "${S.of(context).savedIngredients} (${data.length})",
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          IngredientModel i = data[index];

                          return Row(
                            children: [
                              if (i.forPackaging == true) ...[
                                Tooltip(
                                  message: S.of(context).packaging,
                                  child: Container(
                                    color: Pallete.redColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                      vertical: 1,
                                    ),
                                    child: const DefaultTextView(
                                      text: "P",
                                      color: Pallete.whiteColor,
                                    ),
                                  ),
                                ),
                                kGap5,
                              ],
                              DefaultTextView(
                                text: "${index + 1}) ",
                                color: context.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                              Expanded(
                                child: DefaultTextView(
                                  text: i.nameWithQty,
                                  maxlines: 2,
                                ),
                              ),
                              if (ref.read(mainControllerProvider).isSuperAdmin)
                                DefaultTextView(
                                  textDecoration: i.forPackaging == true
                                      ? TextDecoration.lineThrough
                                      : null,
                                  text:
                                      "${(i.pricePerIngredient?.formatDouble())} ${AppConstance.primaryCurrency}",
                                  color: Pallete.redColor,
                                ),
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      RequestState deleteRequest =
                                          RequestState.success;
                                      return StatefulBuilder(
                                        builder: (context, setState) => AreYouSureDialog(
                                          agreeText: S.of(context).delete,
                                          agreeState: deleteRequest,
                                          "${S.of(context).areYouSureDelete} '${i.name}'",
                                          onAgree: () async {
                                            setState(
                                              () => deleteRequest =
                                                  RequestState.loading,
                                            );
                                            await ref
                                                .read(
                                                  restaurantStockControllerProvider,
                                                )
                                                .deleteSandwichIngrdientById(
                                                  i.sandwichIngredientId!,
                                                )
                                                .whenComplete(() {
                                                  setState(
                                                    () => deleteRequest =
                                                        RequestState.success,
                                                  );
                                                  context.pop();
                                                });
                                          },
                                          onCancel: () => context.pop(),
                                        ),
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider();
                        },
                        itemCount: data.length,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return kEmptyWidget;
            }
          },
          error: (error, stackTrace) => ErrorSection(
            retry: () {
              ref.refresh(futureingredientsBySandwichProvider);
            },
          ),
          loading: () => const CoreCircularIndicator(),
        ),
        if (ref.watch(selectedSandwichProvider) != null)
          Padding(
            padding: kPadd8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (ref.read(mainControllerProvider).isSuperAdmin)
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          DefaultTextView(
                            text: S.of(context).costPrice,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          kGap10,
                          DefaultTextView(
                            text:
                                ": ${ref.read(totalIngedientsCostProvider).formatDouble()} ${AppConstance.primaryCurrency} => ",
                            fontWeight: FontWeight.bold,
                            color: Pallete.redColor,
                            fontSize: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                AppSquaredOutlinedButton(
                  states: [
                    ref.watch(productControllerProvider).updateCostRequestState,
                  ],
                  onPressed: () {
                    ref
                        .read(productControllerProvider)
                        .updateCostPrice(
                          cost: ref.read(totalIngedientsCostProvider),
                          productId: ref.read(selectedSandwichProvider)!.id!,
                        );
                  },
                  child: Icon(Icons.save, color: context.primaryColor),
                ),
              ],
            ),
          ),
        if (ref.watch(selectedIngredientsProvider).isNotEmpty)
          Expanded(
            child: Column(
              children: [
                DefaultTextView(
                  text:
                      "${S.of(context).selectedIngredients} (${ref.read(selectedIngredientsProvider).length})",
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                Expanded(
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      IngredientModel i = ref
                          .watch(selectedIngredientsProvider)
                          .toList()[index];

                      return Row(
                        children: [
                          if (i.forPackaging == true) ...[
                            Tooltip(
                              message: S.of(context).packaging,
                              child: Container(
                                color: Pallete.redColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                  vertical: 1,
                                ),
                                child: const DefaultTextView(
                                  text: "P",
                                  color: Pallete.whiteColor,
                                ),
                              ),
                            ),
                            kGap5,
                          ],
                          DefaultTextView(
                            text: "${index + 1}) ",
                            color: context.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          Expanded(
                            child: DefaultTextView(
                              maxlines: 2,
                              text: ref
                                  .watch(selectedIngredientsProvider)
                                  .toList()[index]
                                  .nameWithQty,
                            ),
                          ),
                          if (ref.read(mainControllerProvider).isSuperAdmin)
                            DefaultTextView(
                              textDecoration: i.forPackaging == true
                                  ? TextDecoration.lineThrough
                                  : null,
                              text:
                                  "${i.pricePerIngredient?.formatDouble()} ${AppConstance.primaryCurrency}",
                              color: Pallete.redColor,
                            ),
                          IconButton(
                            onPressed: () {
                              ref
                                  .read(restaurantStockControllerProvider)
                                  .unSelectIngredient(
                                    ref
                                        .watch(selectedIngredientsProvider)
                                        .toList()[index],
                                  );
                            },
                            icon: const Icon(Icons.clear),
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider();
                    },
                    itemCount: ref.watch(selectedIngredientsProvider).length,
                  ),
                ),
              ],
            ),
          ),
        if (ref.watch(selectedIngredientsProvider).isNotEmpty &&
            ref.read(mainControllerProvider).isSuperAdmin)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DefaultTextView(
                  text: S.of(context).selectedIngredients,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                kGap10,
                DefaultTextView(
                  text:
                      ": ${ref.read(totalSelectedIngedientsCostProvider).formatDouble()} ${AppConstance.primaryCurrency}",
                  fontWeight: FontWeight.bold,
                  color: Pallete.redColor,
                  fontSize: 16,
                ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: ElevatedButtonWidget(
                icon: Icons.save,
                text:
                    "${S.of(context).save.capitalizeFirstLetter()} ${S.of(context).ingredients}",
                isDisabled: !isSaveEnabled,
                states: [
                  ref
                      .watch(restaurantStockControllerProvider)
                      .addIngredientToSandwichRequestState,
                ],
                onPressed: () {
                  if (isSaveEnabled) {
                    saveIngrendientsToSandwich();
                  } else {
                    ToastUtils.showToast(
                      message:
                          "Select prodcut then select ingredients then try again",
                      type: RequestState.error,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
