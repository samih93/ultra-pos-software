import 'dart:convert';

import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/financial_transaction_controller.dart';
import 'package:desktoppossystem/controller/invoices_controller.dart';
import 'package:desktoppossystem/controller/product_controller.dart';
import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/models/financial_transaction_model.dart';
import 'package:desktoppossystem/models/invoice_details_model.dart';
import 'package:desktoppossystem/models/invoice_model.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/supplier_model.dart';
import 'package:desktoppossystem/models/view_model/pruchase_product_model.dart';
import 'package:desktoppossystem/repositories/invoices/invoice_repository.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';

import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PurchaseState {
  final String refId;
  final String? date;
  final SupplierModel? supplier;
  final List<PurchaseProductModel> purchasesProducts;
  final double totalCost;
  final double totalQty;
  final RequestState requestState;

  PurchaseState({
    this.refId = '',
    this.date,
    this.supplier,
    this.purchasesProducts = const [],
    this.totalCost = 0.0,
    this.totalQty = 0.0,
    this.requestState = RequestState.success,
  });

  // Manually convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'refId': refId,
      'date': date,
      'supplier': supplier?.toMap(), // Assuming SupplierModel has toJson
      'purchasesProducts': purchasesProducts
          .map((e) => e.toMap())
          .toList(), // Assuming PurchaseProductModel has toJson
      'totalCost': totalCost,
      'totalQty': totalQty,
      'requestState':
          requestState.toString(), // Assuming RequestState is an enum or class
    };
  }

  factory PurchaseState.fromJson(Map<String, dynamic> json) {
    return PurchaseState(
        refId: json['refId'] ?? '',
        date: json['date'],
        supplier: json['supplier'] != null
            ? SupplierModel.fromMap(json['supplier'])
            : null, // Assuming SupplierModel has fromJson
        purchasesProducts: (json['purchasesProducts'] as List)
            .map((e) => PurchaseProductModel.fromMap(
                e)) // Assuming PurchaseProductModel has fromJson
            .toList(),
        totalCost: json['totalCost']?.toDouble() ?? 0.0,
        totalQty: json['totalQty']?.toDouble() ?? 0.0,
        requestState: RequestState.success);
  }

  PurchaseState copyWith({
    String? date,
    String? refId,
    SupplierModel? supplier,
    List<PurchaseProductModel>? purchasesProducts,
    double? totalCost,
    double? totalQty,
    RequestState? requestState,
  }) {
    return PurchaseState(
      date: date ?? this.date,
      refId: refId ?? this.refId,
      supplier: supplier,
      purchasesProducts: purchasesProducts ?? this.purchasesProducts,
      totalCost: totalCost ?? this.totalCost,
      totalQty: totalQty ?? this.totalQty,
      requestState: requestState ?? this.requestState,
    );
  }
}

class PurchaseNotifier extends StateNotifier<PurchaseState> {
  final Ref ref;
  final Map<int, Map<String, FocusNode>> _focusNodes = {};

  PurchaseNotifier(this.ref)
      : super(PurchaseState(date: DateTime.now().toString().split(" ").first));

  void saveCurrentState() {
    ref.read(appPreferencesProvider).saveData(
          key: 'purchase',
          value: jsonEncode(state.toJson()),
        );
  }

  void restorePurchase() {
    final savedData = ref.read(appPreferencesProvider).getData(key: 'purchase');
    if (savedData != null) {
      state = PurchaseState.fromJson(jsonDecode(savedData));
    } else {
      state = PurchaseState(date: DateTime.now().toString().split(" ").first);
    }
  }

  PurchaseState loadSavedPurchase() {
    final savedData = ref.read(appPreferencesProvider).getData(key: 'purchase');
    if (savedData != null) {
      return PurchaseState.fromJson(jsonDecode(savedData));
    } else {
      return PurchaseState(date: DateTime.now().toString().split(" ").first);
    }
  }

  void setrefId(String id) {
    state = state.copyWith(refId: id, supplier: state.supplier);
  }

  void setInvoiceDate(String date) {
    state = state.copyWith(date: date, supplier: state.supplier);
  }

  void setSuplier(SupplierModel s) {
    state = state.copyWith(supplier: s);
  }

  removeSupplier() {
    state = state.copyWith(supplier: null);
  }

  // Method to calculate the new average cost
  double _calculateNewAverageCost(PurchaseProductModel product) {
    double? oldCostPrice = product.oldCostPrice;
    double? oldQty = product.oldQty;
    double? newQty = product.qty ?? 0;

    if (oldQty != null) {
      return (oldCostPrice! * oldQty + product.costPrice! * newQty) /
          (oldQty + newQty);
    }
    return product.costPrice ?? 0.0;
  }

  FocusNode getFocusNode(int productId, String field) {
    if (!_focusNodes.containsKey(productId)) {
      // Create a new Map for that product if not already created
      _focusNodes[productId] = {};
    }

    // If the field (costPrice, profit, sellingPrice) does not exist, create it
    if (!_focusNodes[productId]!.containsKey(field)) {
      _focusNodes[productId]![field] = FocusNode();
    }

    return _focusNodes[productId]![field]!;
  }

  // Don't forget to dispose of FocusNodes in the dispose method
  void disposeControllers() {
    // Dispose TextEditingControllers
    for (var e in state.purchasesProducts) {
      e.costPriceController!.dispose();
      e.sellingPriceController!.dispose();
      e.profitRateController!.dispose();
    }

    _focusNodes.clear();
  }

  void addProduct(ProductModel product) {
    // Check if the product already exists in the list
    bool productExists = state.purchasesProducts.any((p) => p.id == product.id);

    if (!productExists) {
      // Fetch the old prices from the database or wherever you store the product data
      double? oldCostPrice = product
          .costPrice; // You can adjust this if you need to fetch it from a DB
      double? oldSellingPrice = product.sellingPrice; // Same as above
      double? oldQty = product.qty;

      // Create updated product and set its costPrice, sellingPrice and other relevant fields
      PurchaseProductModel updatedProduct = PurchaseProductModel(
        id: product.id!,
        oldQty: oldQty,
        qty: 0,
        costPrice: oldCostPrice,
        oldCostPrice: oldCostPrice,
        oldSellingPrice: oldSellingPrice,
        sellingPrice: product.sellingPrice,
        sellingInPrimary: true,
        profitRate: product.profitRate,
        newAverageCost: oldCostPrice,
        barcode: product.barcode,
        productName: product.name,
        nameController: TextEditingController(
          text: product.name ?? '',
        ),
        costPriceController: TextEditingController(
          text: product.costPrice?.toString() ?? '0',
        ),
        sellingPriceController: TextEditingController(
          text: product.sellingPrice?.toString() ?? '0',
        ),
        profitRateController: TextEditingController(
          text: product.profitRate?.toString() ?? '0',
        ),
        nameFocusNode: getFocusNode(product.id!, 'name'),
        costPriceFocusNode: getFocusNode(product.id!, 'costPrice'),
        sellingPriceFocusNode: getFocusNode(product.id!, 'sellingPrice'),
        profitFocusNode: getFocusNode(product.id!, 'profit'),
      );

      // Add updatedProduct to the list
      List<PurchaseProductModel> updatedProducts = List.from(
        state.purchasesProducts,
      )..add(updatedProduct);

      // Update the total cost after adding the new product
      _updateTotalCost(updatedProducts);

      // Make sure that the state is updated with the new list of products
      state = state.copyWith(
        purchasesProducts: updatedProducts,
        supplier: state.supplier,
      );
    } else {
      ToastUtils.showToast(
        message: "Product '${product.name}' already exists in the invoice",
        type: RequestState.error,
      );
    }
  }

  void onChangeName(int productId, String newName) {
    // Update the product directly without creating a new state
    for (var purchaseProduct in state.purchasesProducts) {
      if (purchaseProduct.id == productId) {
        // Update the product name
        purchaseProduct.productName = newName;
        break;
      }
    }
  }

  void onChangeCost(int productId, double newCostPrice) {
    List<PurchaseProductModel> updatedProducts = state.purchasesProducts.map((
      purchaseProduct,
    ) {
      if (purchaseProduct.id == productId) {
        double profitRate = purchaseProduct.profitRate ?? 0.0;
        double newSellingPrice =
            ((profitRate * newCostPrice / 100) + newCostPrice).formatDouble();

        // Update the purchase product details
        purchaseProduct.costPrice = newCostPrice;
        purchaseProduct.sellingPrice = newSellingPrice;

        purchaseProduct.sellingPriceController!.text =
            newSellingPrice.toString();

        // Recalculate the new average cost if necessary
        purchaseProduct.newAverageCost = _calculateNewAverageCost(
          purchaseProduct,
        ).formatDoubleWith6();

        // Return a copy of the updated product
        return purchaseProduct.copyWith(
          id: productId,
          costPrice: newCostPrice,
          sellingPrice: newSellingPrice,
          newAverageCost: purchaseProduct.newAverageCost,
        );
      }
      return purchaseProduct; // Return unchanged product if IDs don't match
    }).toList();
    _updateTotalCost(updatedProducts);

    // Update the state with the updated list of products
    state = state.copyWith(
      purchasesProducts: updatedProducts,
      supplier: state.supplier,
    );
  }

  void onChangeProfitRate(int productId, double newProfitRate) {
    List<PurchaseProductModel> updatedProducts = state.purchasesProducts.map((
      purchaseProduct,
    ) {
      if (purchaseProduct.id == productId) {
        // Update the profit rate in the model
        purchaseProduct.profitRate = newProfitRate;

        // Recalculate the new selling price based on the cost price and the new profit rate
        double newCostPrice = purchaseProduct.costPrice ??
            0.0; // Get the cost price (fallback to 0.0 if null)
        double newSellingPrice =
            ((newProfitRate * newCostPrice / 100) + newCostPrice)
                .formatDouble();

        // Update the selling price
        purchaseProduct.sellingPrice = newSellingPrice;
        purchaseProduct.sellingPriceController!.text =
            newSellingPrice.toString();

        // Recalculate the new average cost
        purchaseProduct.newAverageCost = _calculateNewAverageCost(
          purchaseProduct,
        );

        // Return the updated product with the recalculated values
        return purchaseProduct.copyWith(
          id: productId,
          profitRate: newProfitRate,
          sellingPrice: newSellingPrice,
          newAverageCost: purchaseProduct.newAverageCost,
        );
      }
      return purchaseProduct; // Return unchanged product if IDs don't match
    }).toList();

    // Update the state with the updated list of products
    state = state.copyWith(purchasesProducts: updatedProducts);
  }

  void onchangeSellingPrice({
    required double sellingPrice,
    required int productId,
  }) {
    final dolarRate = ref.read(saleControllerProvider).dolarRate;

    List<PurchaseProductModel> updatedProducts = state.purchasesProducts.map((
      product,
    ) {
      if (product.id == productId) {
        // Convert selling price to primary currency if it's in secondary currency
        double primarySelling = product.sellingInPrimary!
            ? sellingPrice
            : (sellingPrice / dolarRate).formatDoubleWith6();

        // Calculate profit based on cost price and selling price
        double profit = primarySelling - (product.costPrice ?? 0.0);
        double profitRate = (profit / (product.costPrice ?? 1.0)) *
            100; // Profit rate in percentage

        // Update the product details
        product.profitRateController!.text =
            profitRate.formatDoubleWith6().toString();

        return product.copyWith(
          id: product.id,
          sellingPrice: primarySelling,
          oldSellingPrice: product.sellingPrice,
          profitRate: profitRate, // Update profit rate
        );
      }
      return product;
    }).toList();

    // Update the state with the modified products list
    state = state.copyWith(purchasesProducts: updatedProducts);
  }

  PurchaseProductModel getProductByIndex(int index) {
    return state.purchasesProducts[index];
  }

  /// Remove Product from Invoice
  void removeProduct(int productId) {
    List<PurchaseProductModel> updatedProducts =
        state.purchasesProducts.where((p) => p.id != productId).toList();
    _updateTotalCost(updatedProducts);
  }

  void updateQuantity({required int productId, required double newQty}) {
    List<PurchaseProductModel> updatedProducts = state.purchasesProducts.map((
      product,
    ) {
      if (product.id == productId) {
        double? oldQty = product.oldQty;
        double? oldCostPrice = product.oldCostPrice;
        double? currentCostPrice = product.costPrice ?? 0;

        double newAverageCost = (oldQty! + newQty) > 0
            ? ((oldQty * oldCostPrice!) + (newQty * currentCostPrice)) /
                (oldQty + newQty)
            : currentCostPrice;

        newAverageCost = newAverageCost.formatDoubleWith6();

        return product.copyWith(
          id: product.id,
          qty: newQty,
          newAverageCost: newAverageCost,
          // Explicitly keep all other values including selling price
          sellingPrice: product.sellingPrice,
          costPrice: product.costPrice,
          oldCostPrice: product.oldCostPrice,
          oldSellingPrice: product.oldSellingPrice,
          oldQty: product.oldQty,
        );
      }
      return product;
    }).toList();

    _updateTotalCost(updatedProducts);
  }

  /// Toggle between showing primary/secondary currency
  void toggleSellingCurrency(int productId) {
    state = state.copyWith(
      purchasesProducts: state.purchasesProducts.map((product) {
        if (product.id == productId) {
          return product.copyWith(
            id: product.id,
            sellingPrice: 0,
            sellingInPrimary: !product.sellingInPrimary!,
          );
        }
        return product;
      }).toList(),
    );
  }

  // /// Update Product Quantity & Prices
  // void updateProduct(int productId,
  //     {double? costPrice, double? qty, bool? dontNotify}) {
  //   List<PurchaseProductModel> updatedProducts =
  //       state.purchasesProducts.map((product) {
  //     if (product.id == productId) {
  //       final dolarRate = ref.read(saleControllerProvider).dolarRate;
  //       // If secondary price was provided, calculate primary price

  //       bool hasCostChanged =
  //           costPrice != null && costPrice != product.costPrice;
  //       bool hasQtyChanged = qty != null && qty != product.qty;
  //       double? oldQty = product.oldQty;
  //       double? oldCostPrice = product.oldCostPrice;
  //       double? newQty = qty ?? product.qty ?? 0;
  //       double? newCostPrice = costPrice ?? product.costPrice ?? 0;
  //       double? oldSellingPrice = product.oldSellingPrice;
  //       double newAverageCost = (oldQty! + newQty) > 0
  //           ? ((oldQty * oldCostPrice!) + (newQty * newCostPrice)) /
  //               (oldQty + newQty)
  //           : newCostPrice;

  //       newAverageCost = newAverageCost.formatDouble();
  //       return product.copyWith(
  //           id: product.id,
  //           costPrice: costPrice ?? product.costPrice,
  //           sellingPrice: product.sellingPrice,
  //           qty: qty ?? product.qty,
  //           oldCostPrice: oldCostPrice, // Save old cost price
  //           oldSellingPrice: oldSellingPrice, // Save old selling price
  //           oldQty: oldQty, // Save old selling price
  //           newAverageCost: newAverageCost);
  //     }
  //     return product;
  //   }).toList();
  //   _updateTotalCost(updatedProducts);
  // }

  /// Calculate the Total Cost of Invoice
  void _updateTotalCost(List<PurchaseProductModel> products) {
    double totalCost = products.fold(
      0.0,
      (sum, product) => sum + (product.costPrice! * product.qty!),
    );
    double totalQty = products.fold(
      0.0,
      (sum, product) => sum + (product.qty!),
    );
    state = state.copyWith(
      purchasesProducts: products,
      supplier: state.supplier,
      totalCost: totalCost,
      totalQty: totalQty,
    );
  }

  /// Clear the Invoice
  void clearInvoice() {
    state = PurchaseState(
      purchasesProducts: [],
      refId: '',
      supplier: null,
      totalCost: 0.0,
    );
  }

  Future addInvoice(
      {required bool payFromCash, required bool payInPrimary}) async {
    InvoiceModel invoiceModel = InvoiceModel(
      referenceId: state.refId,
      receiptDate: state.date,
      foreignPrice: state.totalCost.formatDouble(),
      dolarRate: ref.read(saleControllerProvider).dolarRate,
      localPrice: state.totalCost * ref.read(saleControllerProvider).dolarRate,
      transactionInPrimary: true,
      userId: ref.read(currentUserProvider)!.id,
      supplierId: state.supplier!.id,
    );
    state = state.copyWith(
      requestState: RequestState.loading,
      supplier: state.supplier,
    );

    final response =
        await ref.read(invoiceProviderRepository).addInvoice(invoiceModel);
    response.fold(
      (l) {
        state = state.copyWith(
          requestState: RequestState.error,
          supplier: state.supplier,
        );
      },
      (r) async {
        if (payFromCash == true) {
          // Add transaction of type purchase
          String transactionDate = DateTime.now().toString();
          String formattedTransactionDate =
              "${state.date} ${transactionDate.split(" ")[1]}";

          FinancialTransactionModel transaction = FinancialTransactionModel(
            transactionDate: formattedTransactionDate,
            primaryAmount: payInPrimary ? state.totalCost : 0,
            secondaryAmount: payInPrimary
                ? 0
                : state.totalCost *
                    ref
                        .read(saleControllerProvider)
                        .dolarRate, // Local currency amount
            dollarRate: ref.read(saleControllerProvider).dolarRate,
            isTransactionInPrimary: payInPrimary,
            paymentType: PaymentType.cash,
            flow: TransactionFlow.OUT, // Money going out for purchase
            transactionType:
                TransactionType.purchase, // Assuming you have this enum value
            receiptId: r.id, // Link to the invoice/receipt
            expenseId: null, // Not an expense, it's a purchase
            note: "Purchase from ${state.supplier!.name} - Ref: ${state.refId}",
            customerId: null,
            shiftId: ref.read(currentShiftProvider).id,
            userId: ref.read(currentUserProvider)?.id ?? 0,
            fromCash: true,
          );

          await ref
              .read(financialTransactionControllerProvider)
              .addFinancialTransaction(transaction);
        }

        List<PurchaseDetailsModel> invoiceDetails = [];
        for (var product in state.purchasesProducts) {
          double profitRate = (((product.sellingPrice! - product.costPrice!) /
                      product.costPrice!) *
                  100)
              .formatDoubleWith6();
          invoiceDetails.add(
            PurchaseDetailsModel(
              newAverageCost: product.newAverageCost,
              productName: product.productName,
              invoiceId: r.id,
              productId: product.id,
              qty: product.qty,
              profitRate: profitRate,
              sellingPrice: product.sellingPrice,
              costPrice: product.costPrice,
              oldCostPrice: product.oldCostPrice, // Add old cost price
              oldSellingPrice: product.oldSellingPrice, // Add old selling price
              oldQty: product.oldQty, // Add old selling price
            ),
          );
        }
        final response = await ref
            .read(invoiceProviderRepository)
            .addInvoiceDetails(invoiceDetails);

        response.fold(
          (l) {
            state = state.copyWith(
              requestState: RequestState.error,
              supplier: state.supplier,
            );
            ToastUtils.showToast(message: l.message, type: RequestState.error);
          },
          (r) async {
            state = state.copyWith(
              requestState: RequestState.success,
              purchasesProducts: [],
              refId: '',
              totalCost: 0,
            );

            _focusNodes.clear();
            disposeControllers();
            ref.refresh(invoicesProvider);
            if (ref.read(mainControllerProvider).screenUI ==
                ScreenUI.restaurant) {
              ref.read(productControllerProvider).getAllProducts(limit: 200);
            }
            ToastUtils.showToast(message: "Invoice added successfully");
          },
        );
      },
    );
  }
}

/// Create Riverpod Provider
final newInvoiceProvider =
    StateNotifierProvider<PurchaseNotifier, PurchaseState>(
  (ref) => PurchaseNotifier(ref),
);
