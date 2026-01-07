// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Add Category`
  String get addCategoryButton {
    return Intl.message(
      'Add Category',
      name: 'addCategoryButton',
      desc: '',
      args: [],
    );
  }

  /// `Categories Settings`
  String get settingCategory {
    return Intl.message(
      'Categories Settings',
      name: 'settingCategory',
      desc: '',
      args: [],
    );
  }

  /// `Restaurant Inventory`
  String get restaurantInventory {
    return Intl.message(
      'Restaurant Inventory',
      name: 'restaurantInventory',
      desc: '',
      args: [],
    );
  }

  /// `Nb Of Lines`
  String get nbOfLines {
    return Intl.message(
      'Nb Of Lines',
      name: 'nbOfLines',
      desc: '',
      args: [],
    );
  }

  /// `Hide Categories`
  String get hideCategories {
    return Intl.message(
      'Hide Categories',
      name: 'hideCategories',
      desc: '',
      args: [],
    );
  }

  /// `Show Restuarant Stock`
  String get showRestaurantStock {
    return Intl.message(
      'Show Restuarant Stock',
      name: 'showRestaurantStock',
      desc: '',
      args: [],
    );
  }

  /// `Add Product`
  String get addProductButton {
    return Intl.message(
      'Add Product',
      name: 'addProductButton',
      desc: '',
      args: [],
    );
  }

  /// `Clean The Basket`
  String get cleanTheBasket {
    return Intl.message(
      'Clean The Basket',
      name: 'cleanTheBasket',
      desc: '',
      args: [],
    );
  }

  /// `Product Settings`
  String get settingProduct {
    return Intl.message(
      'Product Settings',
      name: 'settingProduct',
      desc: '',
      args: [],
    );
  }

  /// `Font Weight Bold`
  String get fontWeight {
    return Intl.message(
      'Font Weight Bold',
      name: 'fontWeight',
      desc: '',
      args: [],
    );
  }

  /// `Show Qty`
  String get showQty {
    return Intl.message(
      'Show Qty',
      name: 'showQty',
      desc: '',
      args: [],
    );
  }

  /// `Low Qty`
  String get lowQty {
    return Intl.message(
      'Low Qty',
      name: 'lowQty',
      desc: '',
      args: [],
    );
  }

  /// `Low Qty Alert`
  String get lowQtyAlert {
    return Intl.message(
      'Low Qty Alert',
      name: 'lowQtyAlert',
      desc: '',
      args: [],
    );
  }

  /// `Text Size`
  String get textSize {
    return Intl.message(
      'Text Size',
      name: 'textSize',
      desc: '',
      args: [],
    );
  }

  /// `height`
  String get height {
    return Intl.message(
      'height',
      name: 'height',
      desc: '',
      args: [],
    );
  }

  /// `width`
  String get width {
    return Intl.message(
      'width',
      name: 'width',
      desc: '',
      args: [],
    );
  }

  /// `Pay`
  String get pay {
    return Intl.message(
      'Pay',
      name: 'pay',
      desc: '',
      args: [],
    );
  }

  /// `order`
  String get order {
    return Intl.message(
      'order',
      name: 'order',
      desc: '',
      args: [],
    );
  }

  /// `Change`
  String get changeButton {
    return Intl.message(
      'Change',
      name: 'changeButton',
      desc: '',
      args: [],
    );
  }

  /// `Last Receipt`
  String get lastReceipt {
    return Intl.message(
      'Last Receipt',
      name: 'lastReceipt',
      desc: '',
      args: [],
    );
  }

  /// `Open Drawer`
  String get openCashButton {
    return Intl.message(
      'Open Drawer',
      name: 'openCashButton',
      desc: '',
      args: [],
    );
  }

  /// `Tables`
  String get tablesButton {
    return Intl.message(
      'Tables',
      name: 'tablesButton',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get totalAmount {
    return Intl.message(
      'Total',
      name: 'totalAmount',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get categories {
    return Intl.message(
      'Categories',
      name: 'categories',
      desc: '',
      args: [],
    );
  }

  /// `Category width`
  String get categoryWidth {
    return Intl.message(
      'Category width',
      name: 'categoryWidth',
      desc: '',
      args: [],
    );
  }

  /// `Products`
  String get products {
    return Intl.message(
      'Products',
      name: 'products',
      desc: '',
      args: [],
    );
  }

  /// `Product width`
  String get productWidth {
    return Intl.message(
      'Product width',
      name: 'productWidth',
      desc: '',
      args: [],
    );
  }

  /// `Product`
  String get product {
    return Intl.message(
      'Product',
      name: 'product',
      desc: '',
      args: [],
    );
  }

  /// `Qty`
  String get qty {
    return Intl.message(
      'Qty',
      name: 'qty',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get price {
    return Intl.message(
      'Price',
      name: 'price',
      desc: '',
      args: [],
    );
  }

  /// `Point Of Sale`
  String get saleScreen {
    return Intl.message(
      'Point Of Sale',
      name: 'saleScreen',
      desc: '',
      args: [],
    );
  }

  /// `Daily Financials`
  String get dailyFinancials {
    return Intl.message(
      'Daily Financials',
      name: 'dailyFinancials',
      desc: '',
      args: [],
    );
  }

  /// `Shift`
  String get shiftScreen {
    return Intl.message(
      'Shift',
      name: 'shiftScreen',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard`
  String get dashboardScreen {
    return Intl.message(
      'Dashboard',
      name: 'dashboardScreen',
      desc: '',
      args: [],
    );
  }

  /// `Profit Report`
  String get profitReport {
    return Intl.message(
      'Profit Report',
      name: 'profitReport',
      desc: '',
      args: [],
    );
  }

  /// `Users`
  String get usersScreen {
    return Intl.message(
      'Users',
      name: 'usersScreen',
      desc: '',
      args: [],
    );
  }

  /// `Customers`
  String get customersScreen {
    return Intl.message(
      'Customers',
      name: 'customersScreen',
      desc: '',
      args: [],
    );
  }

  /// `User Name`
  String get userName {
    return Intl.message(
      'User Name',
      name: 'userName',
      desc: '',
      args: [],
    );
  }

  /// `email`
  String get email {
    return Intl.message(
      'email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `role`
  String get role {
    return Intl.message(
      'role',
      name: 'role',
      desc: '',
      args: [],
    );
  }

  /// `Inventory`
  String get stockScreen {
    return Intl.message(
      'Inventory',
      name: 'stockScreen',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settingScreen {
    return Intl.message(
      'Settings',
      name: 'settingScreen',
      desc: '',
      args: [],
    );
  }

  /// `Module`
  String get selectModule {
    return Intl.message(
      'Module',
      name: 'selectModule',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Barcode Or Name ...`
  String get barcodeOrName {
    return Intl.message(
      'Barcode Or Name ...',
      name: 'barcodeOrName',
      desc: '',
      args: [],
    );
  }

  /// `barcode`
  String get barcode {
    return Intl.message(
      'barcode',
      name: 'barcode',
      desc: '',
      args: [],
    );
  }

  /// `Expiry Date`
  String get expiryDate {
    return Intl.message(
      'Expiry Date',
      name: 'expiryDate',
      desc: '',
      args: [],
    );
  }

  /// `Add Amount`
  String get addAmount {
    return Intl.message(
      'Add Amount',
      name: 'addAmount',
      desc: '',
      args: [],
    );
  }

  /// `transaction`
  String get transaction {
    return Intl.message(
      'transaction',
      name: 'transaction',
      desc: '',
      args: [],
    );
  }

  /// `Is Offer`
  String get isOffer {
    return Intl.message(
      'Is Offer',
      name: 'isOffer',
      desc: '',
      args: [],
    );
  }

  /// `Product Image`
  String get productImage {
    return Intl.message(
      'Product Image',
      name: 'productImage',
      desc: '',
      args: [],
    );
  }

  /// `Click to select image`
  String get clickToSelectImage {
    return Intl.message(
      'Click to select image',
      name: 'clickToSelectImage',
      desc: '',
      args: [],
    );
  }

  /// `Drag & Drop or Click to select image`
  String get dragDropImage {
    return Intl.message(
      'Drag & Drop or Click to select image',
      name: 'dragDropImage',
      desc: '',
      args: [],
    );
  }

  /// `Amount`
  String get amount {
    return Intl.message(
      'Amount',
      name: 'amount',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Amount must not be empty`
  String get amountAlert {
    return Intl.message(
      'Amount must not be empty',
      name: 'amountAlert',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `Print Receipt`
  String get printReceipt {
    return Intl.message(
      'Print Receipt',
      name: 'printReceipt',
      desc: '',
      args: [],
    );
  }

  /// `Print Report`
  String get printReportButton {
    return Intl.message(
      'Print Report',
      name: 'printReportButton',
      desc: '',
      args: [],
    );
  }

  /// `Or`
  String get or {
    return Intl.message(
      'Or',
      name: 'or',
      desc: '',
      args: [],
    );
  }

  /// `And`
  String get and {
    return Intl.message(
      'And',
      name: 'and',
      desc: '',
      args: [],
    );
  }

  /// `Deposit`
  String get deposit {
    return Intl.message(
      'Deposit',
      name: 'deposit',
      desc: '',
      args: [],
    );
  }

  /// `withdraw`
  String get withdraw {
    return Intl.message(
      'withdraw',
      name: 'withdraw',
      desc: '',
      args: [],
    );
  }

  /// `Withdraw from cash`
  String get withdrawFromCash {
    return Intl.message(
      'Withdraw from cash',
      name: 'withdrawFromCash',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get detailsButton {
    return Intl.message(
      'Details',
      name: 'detailsButton',
      desc: '',
      args: [],
    );
  }

  /// `Refund`
  String get refundButton {
    return Intl.message(
      'Refund',
      name: 'refundButton',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get deleteButton {
    return Intl.message(
      'Delete',
      name: 'deleteButton',
      desc: '',
      args: [],
    );
  }

  /// `Items`
  String get items {
    return Intl.message(
      'Items',
      name: 'items',
      desc: '',
      args: [],
    );
  }

  /// `Payment Type`
  String get paymentType {
    return Intl.message(
      'Payment Type',
      name: 'paymentType',
      desc: '',
      args: [],
    );
  }

  /// `End Shift`
  String get endOFShift {
    return Intl.message(
      'End Shift',
      name: 'endOFShift',
      desc: '',
      args: [],
    );
  }

  /// `Print Shift Report`
  String get printShift {
    return Intl.message(
      'Print Shift Report',
      name: 'printShift',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get time {
    return Intl.message(
      'Time',
      name: 'time',
      desc: '',
      args: [],
    );
  }

  /// `Select Category`
  String get selectCategory {
    return Intl.message(
      'Select Category',
      name: 'selectCategory',
      desc: '',
      args: [],
    );
  }

  /// `Clear Selected Category`
  String get clearCateogry {
    return Intl.message(
      'Clear Selected Category',
      name: 'clearCateogry',
      desc: '',
      args: [],
    );
  }

  /// `Download Stock by Category`
  String get downloadStockByCategory {
    return Intl.message(
      'Download Stock by Category',
      name: 'downloadStockByCategory',
      desc: '',
      args: [],
    );
  }

  /// `Download All Stock`
  String get downloadAllStock {
    return Intl.message(
      'Download All Stock',
      name: 'downloadAllStock',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get category {
    return Intl.message(
      'Category',
      name: 'category',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Notes`
  String get notes {
    return Intl.message(
      'Notes',
      name: 'notes',
      desc: '',
      args: [],
    );
  }

  /// `Note`
  String get note {
    return Intl.message(
      'Note',
      name: 'note',
      desc: '',
      args: [],
    );
  }

  /// `Cost Price`
  String get costPrice {
    return Intl.message(
      'Cost Price',
      name: 'costPrice',
      desc: '',
      args: [],
    );
  }

  /// `Selling Price`
  String get sellingPrice {
    return Intl.message(
      'Selling Price',
      name: 'sellingPrice',
      desc: '',
      args: [],
    );
  }

  /// `Profit`
  String get profit {
    return Intl.message(
      'Profit',
      name: 'profit',
      desc: '',
      args: [],
    );
  }

  /// `Are you Sure you want to remove`
  String get areYouSureDelete {
    return Intl.message(
      'Are you Sure you want to remove',
      name: 'areYouSureDelete',
      desc: '',
      args: [],
    );
  }

  /// `search`
  String get search {
    return Intl.message(
      'search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `new`
  String get newTitle {
    return Intl.message(
      'new',
      name: 'newTitle',
      desc: '',
      args: [],
    );
  }

  /// `user`
  String get user {
    return Intl.message(
      'user',
      name: 'user',
      desc: '',
      args: [],
    );
  }

  /// `save`
  String get save {
    return Intl.message(
      'save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `name`
  String get name {
    return Intl.message(
      'name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `USD`
  String get usd {
    return Intl.message(
      'USD',
      name: 'usd',
      desc: '',
      args: [],
    );
  }

  /// `LBP`
  String get lbp {
    return Intl.message(
      'LBP',
      name: 'lbp',
      desc: '',
      args: [],
    );
  }

  /// `Select Date`
  String get selectDate {
    return Intl.message(
      'Select Date',
      name: 'selectDate',
      desc: '',
      args: [],
    );
  }

  /// `Select Year`
  String get selectYear {
    return Intl.message(
      'Select Year',
      name: 'selectYear',
      desc: '',
      args: [],
    );
  }

  /// `Download Daily Report`
  String get downloadDailyReport {
    return Intl.message(
      'Download Daily Report',
      name: 'downloadDailyReport',
      desc: '',
      args: [],
    );
  }

  /// `Delete Invoice`
  String get deleteInvoice {
    return Intl.message(
      'Delete Invoice',
      name: 'deleteInvoice',
      desc: '',
      args: [],
    );
  }

  /// `Receipt`
  String get receipt {
    return Intl.message(
      'Receipt',
      name: 'receipt',
      desc: '',
      args: [],
    );
  }

  /// `nb`
  String get nb {
    return Intl.message(
      'nb',
      name: 'nb',
      desc: '',
      args: [],
    );
  }

  /// `cash`
  String get cash {
    return Intl.message(
      'cash',
      name: 'cash',
      desc: '',
      args: [],
    );
  }

  /// `Download Shift Report`
  String get downalodShiftReport {
    return Intl.message(
      'Download Shift Report',
      name: 'downalodShiftReport',
      desc: '',
      args: [],
    );
  }

  /// `Top 10 Selling Products`
  String get top10Selling {
    return Intl.message(
      'Top 10 Selling Products',
      name: 'top10Selling',
      desc: '',
      args: [],
    );
  }

  /// `by`
  String get by {
    return Intl.message(
      'by',
      name: 'by',
      desc: '',
      args: [],
    );
  }

  /// `Sales`
  String get sales {
    return Intl.message(
      'Sales',
      name: 'sales',
      desc: '',
      args: [],
    );
  }

  /// `LAST YEAR`
  String get lastYear {
    return Intl.message(
      'LAST YEAR',
      name: 'lastYear',
      desc: '',
      args: [],
    );
  }

  /// `LAST MONTH`
  String get lastMonth {
    return Intl.message(
      'LAST MONTH',
      name: 'lastMonth',
      desc: '',
      args: [],
    );
  }

  /// `YESTERDAY`
  String get yesterday {
    return Intl.message(
      'YESTERDAY',
      name: 'yesterday',
      desc: '',
      args: [],
    );
  }

  /// `TODAY`
  String get today {
    return Intl.message(
      'TODAY',
      name: 'today',
      desc: '',
      args: [],
    );
  }

  /// `THIS WEEK`
  String get thisWeek {
    return Intl.message(
      'THIS WEEK',
      name: 'thisWeek',
      desc: '',
      args: [],
    );
  }

  /// `THIS MONTH`
  String get thisMonth {
    return Intl.message(
      'THIS MONTH',
      name: 'thisMonth',
      desc: '',
      args: [],
    );
  }

  /// `THIS YEAR`
  String get thisYear {
    return Intl.message(
      'THIS YEAR',
      name: 'thisYear',
      desc: '',
      args: [],
    );
  }

  /// `DAILY`
  String get daily {
    return Intl.message(
      'DAILY',
      name: 'daily',
      desc: '',
      args: [],
    );
  }

  /// `MONTHLY`
  String get monthly {
    return Intl.message(
      'MONTHLY',
      name: 'monthly',
      desc: '',
      args: [],
    );
  }

  /// `YEARLY`
  String get yearly {
    return Intl.message(
      'YEARLY',
      name: 'yearly',
      desc: '',
      args: [],
    );
  }

  /// `day`
  String get day {
    return Intl.message(
      'day',
      name: 'day',
      desc: '',
      args: [],
    );
  }

  /// `month`
  String get month {
    return Intl.message(
      'month',
      name: 'month',
      desc: '',
      args: [],
    );
  }

  /// `Customers`
  String get customers {
    return Intl.message(
      'Customers',
      name: 'customers',
      desc: '',
      args: [],
    );
  }

  /// `On Hold`
  String get onHold {
    return Intl.message(
      'On Hold',
      name: 'onHold',
      desc: '',
      args: [],
    );
  }

  /// `View On Hold`
  String get viewOnHold {
    return Intl.message(
      'View On Hold',
      name: 'viewOnHold',
      desc: '',
      args: [],
    );
  }

  /// `invoice`
  String get invoice {
    return Intl.message(
      'invoice',
      name: 'invoice',
      desc: '',
      args: [],
    );
  }

  /// `Saved Invoices`
  String get openInvoices {
    return Intl.message(
      'Saved Invoices',
      name: 'openInvoices',
      desc: '',
      args: [],
    );
  }

  /// `Import Data`
  String get importData {
    return Intl.message(
      'Import Data',
      name: 'importData',
      desc: '',
      args: [],
    );
  }

  /// `template`
  String get template {
    return Intl.message(
      'template',
      name: 'template',
      desc: '',
      args: [],
    );
  }

  /// `upload`
  String get upload {
    return Intl.message(
      'upload',
      name: 'upload',
      desc: '',
      args: [],
    );
  }

  /// `import`
  String get import {
    return Intl.message(
      'import',
      name: 'import',
      desc: '',
      args: [],
    );
  }

  /// `ready to import`
  String get readyToImport {
    return Intl.message(
      'ready to import',
      name: 'readyToImport',
      desc: '',
      args: [],
    );
  }

  /// `Update User`
  String get updateUser {
    return Intl.message(
      'Update User',
      name: 'updateUser',
      desc: '',
      args: [],
    );
  }

  /// `Name must not be empty`
  String get nameMustBeNotEmpty {
    return Intl.message(
      'Name must not be empty',
      name: 'nameMustBeNotEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Email must not be empty`
  String get emailMustBeNotEmpty {
    return Intl.message(
      'Email must not be empty',
      name: 'emailMustBeNotEmpty',
      desc: '',
      args: [],
    );
  }

  /// `password`
  String get password {
    return Intl.message(
      'password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `password must be not empty`
  String get passwordMustBeNotEmpty {
    return Intl.message(
      'password must be not empty',
      name: 'passwordMustBeNotEmpty',
      desc: '',
      args: [],
    );
  }

  /// `update`
  String get update {
    return Intl.message(
      'update',
      name: 'update',
      desc: '',
      args: [],
    );
  }

  /// `In Stock`
  String get qtyInStock {
    return Intl.message(
      'In Stock',
      name: 'qtyInStock',
      desc: '',
      args: [],
    );
  }

  /// `Print barcode`
  String get printLabel {
    return Intl.message(
      'Print barcode',
      name: 'printLabel',
      desc: '',
      args: [],
    );
  }

  /// `Print label on Label Printer`
  String get printLabelOnLabelPrinter {
    return Intl.message(
      'Print label on Label Printer',
      name: 'printLabelOnLabelPrinter',
      desc: '',
      args: [],
    );
  }

  /// `Show Shift Screen`
  String get showShiftScreen {
    return Intl.message(
      'Show Shift Screen',
      name: 'showShiftScreen',
      desc: '',
      args: [],
    );
  }

  /// `Show Select Module Screen`
  String get showSelectModule {
    return Intl.message(
      'Show Select Module Screen',
      name: 'showSelectModule',
      desc: '',
      args: [],
    );
  }

  /// `language`
  String get language {
    return Intl.message(
      'language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `ar`
  String get ar {
    return Intl.message(
      'ar',
      name: 'ar',
      desc: '',
      args: [],
    );
  }

  /// `en`
  String get en {
    return Intl.message(
      'en',
      name: 'en',
      desc: '',
      args: [],
    );
  }

  /// `Printer Properties`
  String get printerProperties {
    return Intl.message(
      'Printer Properties',
      name: 'printerProperties',
      desc: '',
      args: [],
    );
  }

  /// `Selected Printer`
  String get selectedPrinter {
    return Intl.message(
      'Selected Printer',
      name: 'selectedPrinter',
      desc: '',
      args: [],
    );
  }

  /// `printers`
  String get printers {
    return Intl.message(
      'printers',
      name: 'printers',
      desc: '',
      args: [],
    );
  }

  /// `printer Name`
  String get printerModel {
    return Intl.message(
      'printer Name',
      name: 'printerModel',
      desc: '',
      args: [],
    );
  }

  /// `Network Printers ? `
  String get networkPrinter {
    return Intl.message(
      'Network Printers ? ',
      name: 'networkPrinter',
      desc: '',
      args: [],
    );
  }

  /// `Page Size`
  String get pageSize {
    return Intl.message(
      'Page Size',
      name: 'pageSize',
      desc: '',
      args: [],
    );
  }

  /// `Print Basket Items In`
  String get printBasketIn {
    return Intl.message(
      'Print Basket Items In',
      name: 'printBasketIn',
      desc: '',
      args: [],
    );
  }

  /// `Print Receipt Price In`
  String get printReceiptPriceIn {
    return Intl.message(
      'Print Receipt Price In',
      name: 'printReceiptPriceIn',
      desc: '',
      args: [],
    );
  }

  /// `?`
  String get quetionMark {
    return Intl.message(
      '?',
      name: 'quetionMark',
      desc: '',
      args: [],
    );
  }

  /// `Receipt Nb`
  String get receiptNumber {
    return Intl.message(
      'Receipt Nb',
      name: 'receiptNumber',
      desc: '',
      args: [],
    );
  }

  /// `Receipt number must not be empty`
  String get receiptMustBeNotEmpty {
    return Intl.message(
      'Receipt number must not be empty',
      name: 'receiptMustBeNotEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Store Info`
  String get storeInfo {
    return Intl.message(
      'Store Info',
      name: 'storeInfo',
      desc: '',
      args: [],
    );
  }

  /// `address`
  String get address {
    return Intl.message(
      'address',
      name: 'address',
      desc: '',
      args: [],
    );
  }

  /// `phone`
  String get phone {
    return Intl.message(
      'phone',
      name: 'phone',
      desc: '',
      args: [],
    );
  }

  /// `currencies`
  String get currencies {
    return Intl.message(
      'currencies',
      name: 'currencies',
      desc: '',
      args: [],
    );
  }

  /// `Secondary Currency`
  String get secondaryCurrency {
    return Intl.message(
      'Secondary Currency',
      name: 'secondaryCurrency',
      desc: '',
      args: [],
    );
  }

  /// `Primary Currency`
  String get primaryCurrency {
    return Intl.message(
      'Primary Currency',
      name: 'primaryCurrency',
      desc: '',
      args: [],
    );
  }

  /// `Scan Barcode`
  String get scanBarcode {
    return Intl.message(
      'Scan Barcode',
      name: 'scanBarcode',
      desc: '',
      args: [],
    );
  }

  /// `Select Product`
  String get selectProduct {
    return Intl.message(
      'Select Product',
      name: 'selectProduct',
      desc: '',
      args: [],
    );
  }

  /// `select product from stock`
  String get selectProductFromStock {
    return Intl.message(
      'select product from stock',
      name: 'selectProductFromStock',
      desc: '',
      args: [],
    );
  }

  /// `search by name or barcode `
  String get searchByNameOrBarcode {
    return Intl.message(
      'search by name or barcode ',
      name: 'searchByNameOrBarcode',
      desc: '',
      args: [],
    );
  }

  /// `search by name`
  String get searchByName {
    return Intl.message(
      'search by name',
      name: 'searchByName',
      desc: '',
      args: [],
    );
  }

  /// `Profit rate`
  String get profitRate {
    return Intl.message(
      'Profit rate',
      name: 'profitRate',
      desc: '',
      args: [],
    );
  }

  /// `Selling Price must be a Number`
  String get sellingPriceMustBeNotEmpty {
    return Intl.message(
      'Selling Price must be a Number',
      name: 'sellingPriceMustBeNotEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Tracked`
  String get tracked {
    return Intl.message(
      'Tracked',
      name: 'tracked',
      desc: '',
      args: [],
    );
  }

  /// `For Offer Click `
  String get forOfferClick {
    return Intl.message(
      'For Offer Click ',
      name: 'forOfferClick',
      desc: '',
      args: [],
    );
  }

  /// `Select Products from stock`
  String get addNeedsFromStock {
    return Intl.message(
      'Select Products from stock',
      name: 'addNeedsFromStock',
      desc: '',
      args: [],
    );
  }

  /// `Add From Stock`
  String get addFromStock {
    return Intl.message(
      'Add From Stock',
      name: 'addFromStock',
      desc: '',
      args: [],
    );
  }

  /// `What do you want to do`
  String get whatDoYouWantToDo {
    return Intl.message(
      'What do you want to do',
      name: 'whatDoYouWantToDo',
      desc: '',
      args: [],
    );
  }

  /// `Add Note`
  String get addNote {
    return Intl.message(
      'Add Note',
      name: 'addNote',
      desc: '',
      args: [],
    );
  }

  /// `Background Color`
  String get backgroundColor {
    return Intl.message(
      'Background Color',
      name: 'backgroundColor',
      desc: '',
      args: [],
    );
  }

  /// `Text Color`
  String get textColor {
    return Intl.message(
      'Text Color',
      name: 'textColor',
      desc: '',
      args: [],
    );
  }

  /// `Pick a color`
  String get pickColor {
    return Intl.message(
      'Pick a color',
      name: 'pickColor',
      desc: '',
      args: [],
    );
  }

  /// `Background Color must not be empty`
  String get backgoundColorMustBeNotEmpty {
    return Intl.message(
      'Background Color must not be empty',
      name: 'backgoundColorMustBeNotEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Text Color must not be empty`
  String get textColorMustBeNotEmpty {
    return Intl.message(
      'Text Color must not be empty',
      name: 'textColorMustBeNotEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Sign In Using Code`
  String get signInUsingCode {
    return Intl.message(
      'Sign In Using Code',
      name: 'signInUsingCode',
      desc: '',
      args: [],
    );
  }

  /// `Sign In Using Email`
  String get signInUsingEmail {
    return Intl.message(
      'Sign In Using Email',
      name: 'signInUsingEmail',
      desc: '',
      args: [],
    );
  }

  /// `Login Screen`
  String get loginScreen {
    return Intl.message(
      'Login Screen',
      name: 'loginScreen',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get signIn {
    return Intl.message(
      'Sign In',
      name: 'signIn',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to logout`
  String get areYouSureYouWantToLogout {
    return Intl.message(
      'Are you sure you want to logout',
      name: 'areYouSureYouWantToLogout',
      desc: '',
      args: [],
    );
  }

  /// `no`
  String get no {
    return Intl.message(
      'no',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `yes`
  String get yes {
    return Intl.message(
      'yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to close the system`
  String get areYouSureToCloseProgram {
    return Intl.message(
      'Are you sure you want to close the system',
      name: 'areYouSureToCloseProgram',
      desc: '',
      args: [],
    );
  }

  /// `note must not be empty`
  String get noteMustNotBeEmpty {
    return Intl.message(
      'note must not be empty',
      name: 'noteMustNotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `General Section`
  String get generalSection {
    return Intl.message(
      'General Section',
      name: 'generalSection',
      desc: '',
      args: [],
    );
  }

  /// `Expenses`
  String get expenses {
    return Intl.message(
      'Expenses',
      name: 'expenses',
      desc: '',
      args: [],
    );
  }

  /// `Daily expenses`
  String get dailyExpenses {
    return Intl.message(
      'Daily expenses',
      name: 'dailyExpenses',
      desc: '',
      args: [],
    );
  }

  /// `select customer`
  String get selectCustomer {
    return Intl.message(
      'select customer',
      name: 'selectCustomer',
      desc: '',
      args: [],
    );
  }

  /// `Add Customer`
  String get addCustomer {
    return Intl.message(
      'Add Customer',
      name: 'addCustomer',
      desc: '',
      args: [],
    );
  }

  /// `Update Customer`
  String get updateCustomer {
    return Intl.message(
      'Update Customer',
      name: 'updateCustomer',
      desc: '',
      args: [],
    );
  }

  /// `Customer Name`
  String get customerName {
    return Intl.message(
      'Customer Name',
      name: 'customerName',
      desc: '',
      args: [],
    );
  }

  /// `adress must not be empty`
  String get addressMustNotBeEmpty {
    return Intl.message(
      'adress must not be empty',
      name: 'addressMustNotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `phone nmumber must not be empty`
  String get phoneMustNotBeEmpty {
    return Intl.message(
      'phone nmumber must not be empty',
      name: 'phoneMustNotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Customer`
  String get customer {
    return Intl.message(
      'Customer',
      name: 'customer',
      desc: '',
      args: [],
    );
  }

  /// `Store Qr Code `
  String get storeQrCode {
    return Intl.message(
      'Store Qr Code ',
      name: 'storeQrCode',
      desc: '',
      args: [],
    );
  }

  /// `Discount`
  String get discount {
    return Intl.message(
      'Discount',
      name: 'discount',
      desc: '',
      args: [],
    );
  }

  /// `Select Color`
  String get selectColor {
    return Intl.message(
      'Select Color',
      name: 'selectColor',
      desc: '',
      args: [],
    );
  }

  /// `Add Expense Type`
  String get addExpenseType {
    return Intl.message(
      'Add Expense Type',
      name: 'addExpenseType',
      desc: '',
      args: [],
    );
  }

  /// `Tap here to select expense`
  String get tapHereToSelectExpense {
    return Intl.message(
      'Tap here to select expense',
      name: 'tapHereToSelectExpense',
      desc: '',
      args: [],
    );
  }

  /// `Expense Type must not be Empty`
  String get expenseAlert {
    return Intl.message(
      'Expense Type must not be Empty',
      name: 'expenseAlert',
      desc: '',
      args: [],
    );
  }

  /// `Per kilo or per item`
  String get perKiloOrPerItem {
    return Intl.message(
      'Per kilo or per item',
      name: 'perKiloOrPerItem',
      desc: '',
      args: [],
    );
  }

  /// `cost price must not be empty`
  String get costPriceMustNotBeEmpty {
    return Intl.message(
      'cost price must not be empty',
      name: 'costPriceMustNotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Select basket font size`
  String get selectBasketFontSize {
    return Intl.message(
      'Select basket font size',
      name: 'selectBasketFontSize',
      desc: '',
      args: [],
    );
  }

  /// `Select basket width`
  String get selectBasketWidth {
    return Intl.message(
      'Select basket width',
      name: 'selectBasketWidth',
      desc: '',
      args: [],
    );
  }

  /// `Basket font size`
  String get basketFontSize {
    return Intl.message(
      'Basket font size',
      name: 'basketFontSize',
      desc: '',
      args: [],
    );
  }

  /// `basketWidth`
  String get basketwidth {
    return Intl.message(
      'basketWidth',
      name: 'basketwidth',
      desc: '',
      args: [],
    );
  }

  /// `Theme Color`
  String get themeColor {
    return Intl.message(
      'Theme Color',
      name: 'themeColor',
      desc: '',
      args: [],
    );
  }

  /// `Refunded qty`
  String get refundQty {
    return Intl.message(
      'Refunded qty',
      name: 'refundQty',
      desc: '',
      args: [],
    );
  }

  /// `Refund Reason`
  String get refundReason {
    return Intl.message(
      'Refund Reason',
      name: 'refundReason',
      desc: '',
      args: [],
    );
  }

  /// `Counts as One Item`
  String get countsAsOneItem {
    return Intl.message(
      'Counts as One Item',
      name: 'countsAsOneItem',
      desc: '',
      args: [],
    );
  }

  /// `Restaurant Use`
  String get restaurantUse {
    return Intl.message(
      'Restaurant Use',
      name: 'restaurantUse',
      desc: '',
      args: [],
    );
  }

  /// `Selected Language`
  String get selectLanguage {
    return Intl.message(
      'Selected Language',
      name: 'selectLanguage',
      desc: '',
      args: [],
    );
  }

  /// `show`
  String get show {
    return Intl.message(
      'show',
      name: 'show',
      desc: '',
      args: [],
    );
  }

  /// `hide`
  String get hide {
    return Intl.message(
      'hide',
      name: 'hide',
      desc: '',
      args: [],
    );
  }

  /// `on`
  String get on {
    return Intl.message(
      'on',
      name: 'on',
      desc: '',
      args: [],
    );
  }

  /// `off`
  String get off {
    return Intl.message(
      'off',
      name: 'off',
      desc: '',
      args: [],
    );
  }

  /// `Current Shift`
  String get currentShift {
    return Intl.message(
      'Current Shift',
      name: 'currentShift',
      desc: '',
      args: [],
    );
  }

  /// `Selected Shift`
  String get selectedShift {
    return Intl.message(
      'Selected Shift',
      name: 'selectedShift',
      desc: '',
      args: [],
    );
  }

  /// `Select Shift`
  String get selectShift {
    return Intl.message(
      'Select Shift',
      name: 'selectShift',
      desc: '',
      args: [],
    );
  }

  /// `Start at`
  String get startAt {
    return Intl.message(
      'Start at',
      name: 'startAt',
      desc: '',
      args: [],
    );
  }

  /// `Open latest Shifts`
  String get openLatestShifts {
    return Intl.message(
      'Open latest Shifts',
      name: 'openLatestShifts',
      desc: '',
      args: [],
    );
  }

  /// `fetching shifts`
  String get fetchingShifts {
    return Intl.message(
      'fetching shifts',
      name: 'fetchingShifts',
      desc: '',
      args: [],
    );
  }

  /// `shift`
  String get shift {
    return Intl.message(
      'shift',
      name: 'shift',
      desc: '',
      args: [],
    );
  }

  /// `now`
  String get now {
    return Intl.message(
      'now',
      name: 'now',
      desc: '',
      args: [],
    );
  }

  /// `For Staff`
  String get forStaff {
    return Intl.message(
      'For Staff',
      name: 'forStaff',
      desc: '',
      args: [],
    );
  }

  /// `Backup`
  String get backup {
    return Intl.message(
      'Backup',
      name: 'backup',
      desc: '',
      args: [],
    );
  }

  /// `Restore Data`
  String get restore {
    return Intl.message(
      'Restore Data',
      name: 'restore',
      desc: '',
      args: [],
    );
  }

  /// `Secure your important information by backing up your data to prevent potential loss in the future`
  String get backupSubtitle {
    return Intl.message(
      'Secure your important information by backing up your data to prevent potential loss in the future',
      name: 'backupSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Restore Your Data with Caution: Back up your current information before restoring, as it will be replaced with the latest backup.`
  String get restoreSubtitle {
    return Intl.message(
      'Restore Your Data with Caution: Back up your current information before restoring, as it will be replaced with the latest backup.',
      name: 'restoreSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `New Customer`
  String get newCustomer {
    return Intl.message(
      'New Customer',
      name: 'newCustomer',
      desc: '',
      args: [],
    );
  }

  /// `Import customers`
  String get importCustomers {
    return Intl.message(
      'Import customers',
      name: 'importCustomers',
      desc: '',
      args: [],
    );
  }

  /// `Number of Tables`
  String get nbOfTables {
    return Intl.message(
      'Number of Tables',
      name: 'nbOfTables',
      desc: '',
      args: [],
    );
  }

  /// `Profit OverView`
  String get profitOverView {
    return Intl.message(
      'Profit OverView',
      name: 'profitOverView',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard Overview`
  String get dashboardOverview {
    return Intl.message(
      'Dashboard Overview',
      name: 'dashboardOverview',
      desc: '',
      args: [],
    );
  }

  /// `Total Cost`
  String get totalCost {
    return Intl.message(
      'Total Cost',
      name: 'totalCost',
      desc: '',
      args: [],
    );
  }

  /// `Total Price`
  String get totalPrice {
    return Intl.message(
      'Total Price',
      name: 'totalPrice',
      desc: '',
      args: [],
    );
  }

  /// `Mine`
  String get mine {
    return Intl.message(
      'Mine',
      name: 'mine',
      desc: '',
      args: [],
    );
  }

  /// `Other Users`
  String get otherUsers {
    return Intl.message(
      'Other Users',
      name: 'otherUsers',
      desc: '',
      args: [],
    );
  }

  /// `Closed`
  String get closed {
    return Intl.message(
      'Closed',
      name: 'closed',
      desc: '',
      args: [],
    );
  }

  /// `Number of Customers`
  String get numberOfCustomers {
    return Intl.message(
      'Number of Customers',
      name: 'numberOfCustomers',
      desc: '',
      args: [],
    );
  }

  /// `card`
  String get card {
    return Intl.message(
      'card',
      name: 'card',
      desc: '',
      args: [],
    );
  }

  /// `Add fixed monthly expense`
  String get addFixedMonthlyExpense {
    return Intl.message(
      'Add fixed monthly expense',
      name: 'addFixedMonthlyExpense',
      desc: '',
      args: [],
    );
  }

  /// `fixed monthly expenses`
  String get fixedMonthlyExpense {
    return Intl.message(
      'fixed monthly expenses',
      name: 'fixedMonthlyExpense',
      desc: '',
      args: [],
    );
  }

  /// `Stock Item`
  String get stockItem {
    return Intl.message(
      'Stock Item',
      name: 'stockItem',
      desc: '',
      args: [],
    );
  }

  /// `Ingredients`
  String get ingredients {
    return Intl.message(
      'Ingredients',
      name: 'ingredients',
      desc: '',
      args: [],
    );
  }

  /// `Nb of portions per kg`
  String get nbOfPortionsPerKg {
    return Intl.message(
      'Nb of portions per kg',
      name: 'nbOfPortionsPerKg',
      desc: '',
      args: [],
    );
  }

  /// `Qty in kg`
  String get qtyAsKg {
    return Intl.message(
      'Qty in kg',
      name: 'qtyAsKg',
      desc: '',
      args: [],
    );
  }

  /// `Qty as g`
  String get qtyAsg {
    return Intl.message(
      'Qty as g',
      name: 'qtyAsg',
      desc: '',
      args: [],
    );
  }

  /// `Qty in portions`
  String get qtyAsPortions {
    return Intl.message(
      'Qty in portions',
      name: 'qtyAsPortions',
      desc: '',
      args: [],
    );
  }

  /// `Qty per unit`
  String get qtyPerUnit {
    return Intl.message(
      'Qty per unit',
      name: 'qtyPerUnit',
      desc: '',
      args: [],
    );
  }

  /// `Price per unit`
  String get pricePerUnit {
    return Intl.message(
      'Price per unit',
      name: 'pricePerUnit',
      desc: '',
      args: [],
    );
  }

  /// `unit`
  String get unit {
    return Intl.message(
      'unit',
      name: 'unit',
      desc: '',
      args: [],
    );
  }

  /// `Saved Ingredients`
  String get savedIngredients {
    return Intl.message(
      'Saved Ingredients',
      name: 'savedIngredients',
      desc: '',
      args: [],
    );
  }

  /// `Selected Ingredients`
  String get selectedIngredients {
    return Intl.message(
      'Selected Ingredients',
      name: 'selectedIngredients',
      desc: '',
      args: [],
    );
  }

  /// `No ingredients found`
  String get noIngredientFound {
    return Intl.message(
      'No ingredients found',
      name: 'noIngredientFound',
      desc: '',
      args: [],
    );
  }

  /// `Update Sandwiches Costs`
  String get updateSandwichesCosts {
    return Intl.message(
      'Update Sandwiches Costs',
      name: 'updateSandwichesCosts',
      desc: '',
      args: [],
    );
  }

  /// `Stock Usage`
  String get stockUsage {
    return Intl.message(
      'Stock Usage',
      name: 'stockUsage',
      desc: '',
      args: [],
    );
  }

  /// `Stock OverView`
  String get stockOverView {
    return Intl.message(
      'Stock OverView',
      name: 'stockOverView',
      desc: '',
      args: [],
    );
  }

  /// `Warning Alert`
  String get warningAlert {
    return Intl.message(
      'Warning Alert',
      name: 'warningAlert',
      desc: '',
      args: [],
    );
  }

  /// `Price per kg`
  String get pricePerKg {
    return Intl.message(
      'Price per kg',
      name: 'pricePerKg',
      desc: '',
      args: [],
    );
  }

  /// `Price per portion`
  String get pricePerPortion {
    return Intl.message(
      'Price per portion',
      name: 'pricePerPortion',
      desc: '',
      args: [],
    );
  }

  /// `Manage stock`
  String get manageStock {
    return Intl.message(
      'Manage stock',
      name: 'manageStock',
      desc: '',
      args: [],
    );
  }

  /// `Nb of packets`
  String get nbOfPackets {
    return Intl.message(
      'Nb of packets',
      name: 'nbOfPackets',
      desc: '',
      args: [],
    );
  }

  /// `Qty per packet`
  String get qtyPerPacket {
    return Intl.message(
      'Qty per packet',
      name: 'qtyPerPacket',
      desc: '',
      args: [],
    );
  }

  /// `optional`
  String get optional {
    return Intl.message(
      'optional',
      name: 'optional',
      desc: '',
      args: [],
    );
  }

  /// `Download Restaurant Stock Report`
  String get downloadRestaurantStockReport {
    return Intl.message(
      'Download Restaurant Stock Report',
      name: 'downloadRestaurantStockReport',
      desc: '',
      args: [],
    );
  }

  /// `close`
  String get close {
    return Intl.message(
      'close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `You are not connected to the printer, try again later`
  String get checkPrinterConnectionStatus {
    return Intl.message(
      'You are not connected to the printer, try again later',
      name: 'checkPrinterConnectionStatus',
      desc: '',
      args: [],
    );
  }

  /// `print`
  String get print {
    return Intl.message(
      'print',
      name: 'print',
      desc: '',
      args: [],
    );
  }

  /// `Print restaurant stock`
  String get printRestaurantStock {
    return Intl.message(
      'Print restaurant stock',
      name: 'printRestaurantStock',
      desc: '',
      args: [],
    );
  }

  /// `download`
  String get download {
    return Intl.message(
      'download',
      name: 'download',
      desc: '',
      args: [],
    );
  }

  /// `Order Type`
  String get orderType {
    return Intl.message(
      'Order Type',
      name: 'orderType',
      desc: '',
      args: [],
    );
  }

  /// `Show Order Type Section`
  String get showOrderTypeSection {
    return Intl.message(
      'Show Order Type Section',
      name: 'showOrderTypeSection',
      desc: '',
      args: [],
    );
  }

  /// `Delivery`
  String get delivery {
    return Intl.message(
      'Delivery',
      name: 'delivery',
      desc: '',
      args: [],
    );
  }

  /// `Dine In`
  String get dineIn {
    return Intl.message(
      'Dine In',
      name: 'dineIn',
      desc: '',
      args: [],
    );
  }

  /// `Packaging Cost`
  String get packagingCost {
    return Intl.message(
      'Packaging Cost',
      name: 'packagingCost',
      desc: '',
      args: [],
    );
  }

  /// `For Packaging, select`
  String get forPackagingSelect {
    return Intl.message(
      'For Packaging, select',
      name: 'forPackagingSelect',
      desc: '',
      args: [],
    );
  }

  /// `packaging`
  String get packaging {
    return Intl.message(
      'packaging',
      name: 'packaging',
      desc: '',
      args: [],
    );
  }

  /// `Food Items`
  String get foodItems {
    return Intl.message(
      'Food Items',
      name: 'foodItems',
      desc: '',
      args: [],
    );
  }

  /// `filter`
  String get filter {
    return Intl.message(
      'filter',
      name: 'filter',
      desc: '',
      args: [],
    );
  }

  /// `all`
  String get all {
    return Intl.message(
      'all',
      name: 'all',
      desc: '',
      args: [],
    );
  }

  /// `allow negative discount`
  String get allowNegativeDiscount {
    return Intl.message(
      'allow negative discount',
      name: 'allowNegativeDiscount',
      desc: '',
      args: [],
    );
  }

  /// `This feature enables us to apply a negative discount, effectively increasing the selling price of an item without modifying the product details.`
  String get allowNegativeDiscountDescription {
    return Intl.message(
      'This feature enables us to apply a negative discount, effectively increasing the selling price of an item without modifying the product details.',
      name: 'allowNegativeDiscountDescription',
      desc: '',
      args: [],
    );
  }

  /// `pick logo`
  String get pickLogo {
    return Intl.message(
      'pick logo',
      name: 'pickLogo',
      desc: '',
      args: [],
    );
  }

  /// `Print logo on invoice`
  String get printLogoOnInvoice {
    return Intl.message(
      'Print logo on invoice',
      name: 'printLogoOnInvoice',
      desc: '',
      args: [],
    );
  }

  /// `This feature allows printing the logo on the invoice instead of the QR code`
  String get printLogoOnInvoiceDescription {
    return Intl.message(
      'This feature allows printing the logo on the invoice instead of the QR code',
      name: 'printLogoOnInvoiceDescription',
      desc: '',
      args: [],
    );
  }

  /// `Deliver Package`
  String get deliverPackage {
    return Intl.message(
      'Deliver Package',
      name: 'deliverPackage',
      desc: '',
      args: [],
    );
  }

  /// `Show Deliver Package`
  String get showDeliverPackage {
    return Intl.message(
      'Show Deliver Package',
      name: 'showDeliverPackage',
      desc: '',
      args: [],
    );
  }

  /// `manage`
  String get manage {
    return Intl.message(
      'manage',
      name: 'manage',
      desc: '',
      args: [],
    );
  }

  /// `Remove image`
  String get removeImage {
    return Intl.message(
      'Remove image',
      name: 'removeImage',
      desc: '',
      args: [],
    );
  }

  /// `Pick Image`
  String get pickImage {
    return Intl.message(
      'Pick Image',
      name: 'pickImage',
      desc: '',
      args: [],
    );
  }

  /// `Low stock`
  String get lowStock {
    return Intl.message(
      'Low stock',
      name: 'lowStock',
      desc: '',
      args: [],
    );
  }

  /// `Hide or Show text`
  String get hideShowText {
    return Intl.message(
      'Hide or Show text',
      name: 'hideShowText',
      desc: '',
      args: [],
    );
  }

  /// `Press 'Hide' to hide or 'Show' to show text for products with images`
  String get pressHideToHide {
    return Intl.message(
      'Press \'Hide\' to hide or \'Show\' to show text for products with images',
      name: 'pressHideToHide',
      desc: '',
      args: [],
    );
  }

  /// `Quotation`
  String get quotation {
    return Intl.message(
      'Quotation',
      name: 'quotation',
      desc: '',
      args: [],
    );
  }

  /// `New Purchase`
  String get newPurchase {
    return Intl.message(
      'New Purchase',
      name: 'newPurchase',
      desc: '',
      args: [],
    );
  }

  /// `Purchases`
  String get purchases {
    return Intl.message(
      'Purchases',
      name: 'purchases',
      desc: '',
      args: [],
    );
  }

  /// `Invoices`
  String get invoices {
    return Intl.message(
      'Invoices',
      name: 'invoices',
      desc: '',
      args: [],
    );
  }

  /// `reference id`
  String get refId {
    return Intl.message(
      'reference id',
      name: 'refId',
      desc: '',
      args: [],
    );
  }

  /// `Supplier`
  String get supplier {
    return Intl.message(
      'Supplier',
      name: 'supplier',
      desc: '',
      args: [],
    );
  }

  /// `Quick Add: Duplicate Latest Added Product`
  String get quickAddProduct {
    return Intl.message(
      'Quick Add: Duplicate Latest Added Product',
      name: 'quickAddProduct',
      desc: '',
      args: [],
    );
  }

  /// `When adding a new product, the form pre-fills with the details of the latest added product, allowing quick edits and adjustments`
  String get quickAddSubtitle {
    return Intl.message(
      'When adding a new product, the form pre-fills with the details of the latest added product, allowing quick edits and adjustments',
      name: 'quickAddSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `default profit rate %`
  String get defaultProfitRate {
    return Intl.message(
      'default profit rate %',
      name: 'defaultProfitRate',
      desc: '',
      args: [],
    );
  }

  /// `search for a supplier`
  String get searchForASupplier {
    return Intl.message(
      'search for a supplier',
      name: 'searchForASupplier',
      desc: '',
      args: [],
    );
  }

  /// `date`
  String get date {
    return Intl.message(
      'date',
      name: 'date',
      desc: '',
      args: [],
    );
  }

  /// `Enter the invoice`
  String get enterTheInvoice {
    return Intl.message(
      'Enter the invoice',
      name: 'enterTheInvoice',
      desc: '',
      args: [],
    );
  }

  /// `Invoices List`
  String get invoicesList {
    return Intl.message(
      'Invoices List',
      name: 'invoicesList',
      desc: '',
      args: [],
    );
  }

  /// `Report charts`
  String get reportCharts {
    return Intl.message(
      'Report charts',
      name: 'reportCharts',
      desc: '',
      args: [],
    );
  }

  /// `Total Revenue`
  String get totalRevenue {
    return Intl.message(
      'Total Revenue',
      name: 'totalRevenue',
      desc: '',
      args: [],
    );
  }

  /// `Total Profit`
  String get totalProfit {
    return Intl.message(
      'Total Profit',
      name: 'totalProfit',
      desc: '',
      args: [],
    );
  }

  /// `Total Expenses`
  String get totalExpenses {
    return Intl.message(
      'Total Expenses',
      name: 'totalExpenses',
      desc: '',
      args: [],
    );
  }

  /// `Top most bought items`
  String get topMostBoughtItemsPie {
    return Intl.message(
      'Top most bought items',
      name: 'topMostBoughtItemsPie',
      desc: '',
      args: [],
    );
  }

  /// `Old qty`
  String get oldQty {
    return Intl.message(
      'Old qty',
      name: 'oldQty',
      desc: '',
      args: [],
    );
  }

  /// `New qty`
  String get newQty {
    return Intl.message(
      'New qty',
      name: 'newQty',
      desc: '',
      args: [],
    );
  }

  /// `Old cost`
  String get oldCost {
    return Intl.message(
      'Old cost',
      name: 'oldCost',
      desc: '',
      args: [],
    );
  }

  /// `New cost`
  String get newCost {
    return Intl.message(
      'New cost',
      name: 'newCost',
      desc: '',
      args: [],
    );
  }

  /// `New Avg cost`
  String get newAvgCost {
    return Intl.message(
      'New Avg cost',
      name: 'newAvgCost',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to restore`
  String get areYouSureRestore {
    return Intl.message(
      'Are you sure you want to restore',
      name: 'areYouSureRestore',
      desc: '',
      args: [],
    );
  }

  /// `Restore Product`
  String get restoreProduct {
    return Intl.message(
      'Restore Product',
      name: 'restoreProduct',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get active {
    return Intl.message(
      'Active',
      name: 'active',
      desc: '',
      args: [],
    );
  }

  /// `Deleted`
  String get deleted {
    return Intl.message(
      'Deleted',
      name: 'deleted',
      desc: '',
      args: [],
    );
  }

  /// `Show table button`
  String get showTableButton {
    return Intl.message(
      'Show table button',
      name: 'showTableButton',
      desc: '',
      args: [],
    );
  }

  /// `out of stock`
  String get outOfStock {
    return Intl.message(
      'out of stock',
      name: 'outOfStock',
      desc: '',
      args: [],
    );
  }

  /// `Enable/Disable Notifications`
  String get enableDisableNotification {
    return Intl.message(
      'Enable/Disable Notifications',
      name: 'enableDisableNotification',
      desc: '',
      args: [],
    );
  }

  /// `Backup to cloud`
  String get backupToCloud {
    return Intl.message(
      'Backup to cloud',
      name: 'backupToCloud',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Receipts`
  String get receipts {
    return Intl.message(
      'Receipts',
      name: 'receipts',
      desc: '',
      args: [],
    );
  }

  /// `Users`
  String get users {
    return Intl.message(
      'Users',
      name: 'users',
      desc: '',
      args: [],
    );
  }

  /// `Sales by categories`
  String get salesByCategories {
    return Intl.message(
      'Sales by categories',
      name: 'salesByCategories',
      desc: '',
      args: [],
    );
  }

  /// `Login to your account`
  String get loginToYourAccount {
    return Intl.message(
      'Login to your account',
      name: 'loginToYourAccount',
      desc: '',
      args: [],
    );
  }

  /// `Top 10 spending Customers`
  String get top10SpendingCustomers {
    return Intl.message(
      'Top 10 spending Customers',
      name: 'top10SpendingCustomers',
      desc: '',
      args: [],
    );
  }

  /// `Sales by users`
  String get salesByUsers {
    return Intl.message(
      'Sales by users',
      name: 'salesByUsers',
      desc: '',
      args: [],
    );
  }

  /// `waste`
  String get waste {
    return Intl.message(
      'waste',
      name: 'waste',
      desc: '',
      args: [],
    );
  }

  /// `Total waste`
  String get totalWaste {
    return Intl.message(
      'Total waste',
      name: 'totalWaste',
      desc: '',
      args: [],
    );
  }

  /// `Waste reason`
  String get wasteReason {
    return Intl.message(
      'Waste reason',
      name: 'wasteReason',
      desc: '',
      args: [],
    );
  }

  /// `Stock warning`
  String get stockWarning {
    return Intl.message(
      'Stock warning',
      name: 'stockWarning',
      desc: '',
      args: [],
    );
  }

  /// `Stock transactions`
  String get stockTransactions {
    return Intl.message(
      'Stock transactions',
      name: 'stockTransactions',
      desc: '',
      args: [],
    );
  }

  /// `Stock in`
  String get stockIn {
    return Intl.message(
      'Stock in',
      name: 'stockIn',
      desc: '',
      args: [],
    );
  }

  /// `Waste Out`
  String get wasteOut {
    return Intl.message(
      'Waste Out',
      name: 'wasteOut',
      desc: '',
      args: [],
    );
  }

  /// `Mark this order as wasted`
  String get markeThisOrderAsWasted {
    return Intl.message(
      'Mark this order as wasted',
      name: 'markeThisOrderAsWasted',
      desc: '',
      args: [],
    );
  }

  /// `Normal waste`
  String get normalWaste {
    return Intl.message(
      'Normal waste',
      name: 'normalWaste',
      desc: '',
      args: [],
    );
  }

  /// `Staff waste`
  String get staffWaste {
    return Intl.message(
      'Staff waste',
      name: 'staffWaste',
      desc: '',
      args: [],
    );
  }

  /// `Staff Meal`
  String get staffMeal {
    return Intl.message(
      'Staff Meal',
      name: 'staffMeal',
      desc: '',
      args: [],
    );
  }

  /// `Remove all`
  String get removeAll {
    return Intl.message(
      'Remove all',
      name: 'removeAll',
      desc: '',
      args: [],
    );
  }

  /// `Selected Items`
  String get selectedItems {
    return Intl.message(
      'Selected Items',
      name: 'selectedItems',
      desc: '',
      args: [],
    );
  }

  /// `receipt id`
  String get receiptId {
    return Intl.message(
      'receipt id',
      name: 'receiptId',
      desc: '',
      args: [],
    );
  }

  /// `copied to clipboard`
  String get copiedToClipboard {
    return Intl.message(
      'copied to clipboard',
      name: 'copiedToClipboard',
      desc: '',
      args: [],
    );
  }

  /// `Total weight`
  String get totalWeight {
    return Intl.message(
      'Total weight',
      name: 'totalWeight',
      desc: '',
      args: [],
    );
  }

  /// `Net weight`
  String get netWeight {
    return Intl.message(
      'Net weight',
      name: 'netWeight',
      desc: '',
      args: [],
    );
  }

  /// `Waste per Kg`
  String get wastePerKg {
    return Intl.message(
      'Waste per Kg',
      name: 'wastePerKg',
      desc: '',
      args: [],
    );
  }

  /// `Open the system in full screen mode`
  String get openSystemFullScreen {
    return Intl.message(
      'Open the system in full screen mode',
      name: 'openSystemFullScreen',
      desc: '',
      args: [],
    );
  }

  /// `Change category order`
  String get changeCategoryOrder {
    return Intl.message(
      'Change category order',
      name: 'changeCategoryOrder',
      desc: '',
      args: [],
    );
  }

  /// `Change product order`
  String get changeProductOrder {
    return Intl.message(
      'Change product order',
      name: 'changeProductOrder',
      desc: '',
      args: [],
    );
  }

  /// `Min selling Price`
  String get minSellingPrice {
    return Intl.message(
      'Min selling Price',
      name: 'minSellingPrice',
      desc: '',
      args: [],
    );
  }

  /// `Hourly Customers`
  String get hourlyCustomers {
    return Intl.message(
      'Hourly Customers',
      name: 'hourlyCustomers',
      desc: '',
      args: [],
    );
  }

  /// `Weighted product`
  String get weightedProduct {
    return Intl.message(
      'Weighted product',
      name: 'weightedProduct',
      desc: '',
      args: [],
    );
  }

  /// `hour`
  String get hour {
    return Intl.message(
      'hour',
      name: 'hour',
      desc: '',
      args: [],
    );
  }

  /// `Label type`
  String get labelType {
    return Intl.message(
      'Label type',
      name: 'labelType',
      desc: '',
      args: [],
    );
  }

  /// `Show Quick Selection Products`
  String get showQuickSelectionProducts {
    return Intl.message(
      'Show Quick Selection Products',
      name: 'showQuickSelectionProducts',
      desc: '',
      args: [],
    );
  }

  /// `print store name on label`
  String get printStoreNameOnLabel {
    return Intl.message(
      'print store name on label',
      name: 'printStoreNameOnLabel',
      desc: '',
      args: [],
    );
  }

  /// `Contact Details`
  String get contactDetails {
    return Intl.message(
      'Contact Details',
      name: 'contactDetails',
      desc: '',
      args: [],
    );
  }

  /// `Supplier Address`
  String get supplierAddress {
    return Intl.message(
      'Supplier Address',
      name: 'supplierAddress',
      desc: '',
      args: [],
    );
  }

  /// `Suppliers`
  String get suppliers {
    return Intl.message(
      'Suppliers',
      name: 'suppliers',
      desc: '',
      args: [],
    );
  }

  /// `Restore Saved purchase`
  String get restoreSavedPurchase {
    return Intl.message(
      'Restore Saved purchase',
      name: 'restoreSavedPurchase',
      desc: '',
      args: [],
    );
  }

  /// `Continue later`
  String get continueLater {
    return Intl.message(
      'Continue later',
      name: 'continueLater',
      desc: '',
      args: [],
    );
  }

  /// `Pay as delivery`
  String get payDelivery {
    return Intl.message(
      'Pay as delivery',
      name: 'payDelivery',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to pay receipt nb`
  String get areYouSurePay {
    return Intl.message(
      'Are you sure you want to pay receipt nb',
      name: 'areYouSurePay',
      desc: '',
      args: [],
    );
  }

  /// `Pay later`
  String get payLater {
    return Intl.message(
      'Pay later',
      name: 'payLater',
      desc: '',
      args: [],
    );
  }

  /// `remaining`
  String get remaining {
    return Intl.message(
      'remaining',
      name: 'remaining',
      desc: '',
      args: [],
    );
  }

  /// `paid`
  String get paid {
    return Intl.message(
      'paid',
      name: 'paid',
      desc: '',
      args: [],
    );
  }

  /// `pending`
  String get pending {
    return Intl.message(
      'pending',
      name: 'pending',
      desc: '',
      args: [],
    );
  }

  /// `Total purchases`
  String get totalPurchases {
    return Intl.message(
      'Total purchases',
      name: 'totalPurchases',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to pay all pending receipts`
  String get areYouSurePayAllReceipts {
    return Intl.message(
      'Are you sure you want to pay all pending receipts',
      name: 'areYouSurePayAllReceipts',
      desc: '',
      args: [],
    );
  }

  /// `Balance`
  String get balance {
    return Intl.message(
      'Balance',
      name: 'balance',
      desc: '',
      args: [],
    );
  }

  /// `Pay Later receipts`
  String get payLaterReceits {
    return Intl.message(
      'Pay Later receipts',
      name: 'payLaterReceits',
      desc: '',
      args: [],
    );
  }

  /// `Complementary`
  String get complementary {
    return Intl.message(
      'Complementary',
      name: 'complementary',
      desc: '',
      args: [],
    );
  }

  /// `light`
  String get light {
    return Intl.message(
      'light',
      name: 'light',
      desc: '',
      args: [],
    );
  }

  /// `dark`
  String get dark {
    return Intl.message(
      'dark',
      name: 'dark',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the 'Clearing Old Receipt' key

  /// `Collected Pending Receipts`
  String get collectedPendingReceipts {
    return Intl.message(
      'Collected Pending Receipts',
      name: 'collectedPendingReceipts',
      desc: '',
      args: [],
    );
  }

  /// `transactions`
  String get transactions {
    return Intl.message(
      'transactions',
      name: 'transactions',
      desc: '',
      args: [],
    );
  }

  /// `Collected pending amount for previous receipts (excluding today's)`
  String get collectedPendingAmountTooltip {
    return Intl.message(
      'Collected pending amount for previous receipts (excluding today\'s)',
      name: 'collectedPendingAmountTooltip',
      desc: '',
      args: [],
    );
  }

  /// `last two months`
  String get lastTwoMonths {
    return Intl.message(
      'last two months',
      name: 'lastTwoMonths',
      desc: '',
      args: [],
    );
  }

  /// `Show open cash button`
  String get showOpenCashButton {
    return Intl.message(
      'Show open cash button',
      name: 'showOpenCashButton',
      desc: '',
      args: [],
    );
  }

  /// `Open change Dialog on pay`
  String get openChangeDialogOnPay {
    return Intl.message(
      'Open change Dialog on pay',
      name: 'openChangeDialogOnPay',
      desc: '',
      args: [],
    );
  }

  /// `actions`
  String get actions {
    return Intl.message(
      'actions',
      name: 'actions',
      desc: '',
      args: [],
    );
  }

  /// `Filter by Category`
  String get filterByCategory {
    return Intl.message(
      'Filter by Category',
      name: 'filterByCategory',
      desc: '',
      args: [],
    );
  }

  /// `Pay from Cash`
  String get payFromCash {
    return Intl.message(
      'Pay from Cash',
      name: 'payFromCash',
      desc: '',
      args: [],
    );
  }

  /// `from cash`
  String get fromCash {
    return Intl.message(
      'from cash',
      name: 'fromCash',
      desc: '',
      args: [],
    );
  }

  /// `Show Product Image`
  String get showProductImage {
    return Intl.message(
      'Show Product Image',
      name: 'showProductImage',
      desc: '',
      args: [],
    );
  }

  /// `Sync Products to Cloud`
  String get syncProductsToCloud {
    return Intl.message(
      'Sync Products to Cloud',
      name: 'syncProductsToCloud',
      desc: '',
      args: [],
    );
  }

  /// `Hide on Menu`
  String get hideOnMenu {
    return Intl.message(
      'Hide on Menu',
      name: 'hideOnMenu',
      desc: '',
      args: [],
    );
  }

  /// `Offer on Menu`
  String get offerOnMenu {
    return Intl.message(
      'Offer on Menu',
      name: 'offerOnMenu',
      desc: '',
      args: [],
    );
  }

  /// `Sync Products (Data Only)`
  String get syncProductsDataOnly {
    return Intl.message(
      'Sync Products (Data Only)',
      name: 'syncProductsDataOnly',
      desc: '',
      args: [],
    );
  }

  /// `Sync products with data (no images), enabling quick updates like price changes and item sorting.`
  String get syncProductsDataOnlyDescription {
    return Intl.message(
      'Sync products with data (no images), enabling quick updates like price changes and item sorting.',
      name: 'syncProductsDataOnlyDescription',
      desc: '',
      args: [],
    );
  }

  /// `Sync Products (With Images)`
  String get syncProductsWithImages {
    return Intl.message(
      'Sync Products (With Images)',
      name: 'syncProductsWithImages',
      desc: '',
      args: [],
    );
  }

  /// `Sync all products, including images, with a slight delay (up to 20 seconds), ensuring full product updates.`
  String get syncProductsWithImagesDescription {
    return Intl.message(
      'Sync all products, including images, with a slight delay (up to 20 seconds), ensuring full product updates.',
      name: 'syncProductsWithImagesDescription',
      desc: '',
      args: [],
    );
  }

  /// `description`
  String get description {
    return Intl.message(
      'description',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `Subscriptions`
  String get subscriptions {
    return Intl.message(
      'Subscriptions',
      name: 'subscriptions',
      desc: '',
      args: [],
    );
  }

  /// `Subscription Management`
  String get subscriptionManagement {
    return Intl.message(
      'Subscription Management',
      name: 'subscriptionManagement',
      desc: '',
      args: [],
    );
  }

  /// `Due`
  String get dueStatus {
    return Intl.message(
      'Due',
      name: 'dueStatus',
      desc: '',
      args: [],
    );
  }

  /// `Overdue`
  String get overdue {
    return Intl.message(
      'Overdue',
      name: 'overdue',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled`
  String get cancelled {
    return Intl.message(
      'Cancelled',
      name: 'cancelled',
      desc: '',
      args: [],
    );
  }

  /// `Paused`
  String get paused {
    return Intl.message(
      'Paused',
      name: 'paused',
      desc: '',
      args: [],
    );
  }

  /// `Monthly Amount`
  String get monthlyAmount {
    return Intl.message(
      'Monthly Amount',
      name: 'monthlyAmount',
      desc: '',
      args: [],
    );
  }

  /// `Next Payment`
  String get nextPayment {
    return Intl.message(
      'Next Payment',
      name: 'nextPayment',
      desc: '',
      args: [],
    );
  }

  /// `Customer Information`
  String get customerInfo {
    return Intl.message(
      'Customer Information',
      name: 'customerInfo',
      desc: '',
      args: [],
    );
  }

  /// `Subscription Statistics`
  String get subscriptionStats {
    return Intl.message(
      'Subscription Statistics',
      name: 'subscriptionStats',
      desc: '',
      args: [],
    );
  }

  /// `Total Active`
  String get totalActive {
    return Intl.message(
      'Total Active',
      name: 'totalActive',
      desc: '',
      args: [],
    );
  }

  /// `Total Overdue`
  String get totalOverdue {
    return Intl.message(
      'Total Overdue',
      name: 'totalOverdue',
      desc: '',
      args: [],
    );
  }

  /// `Monthly Revenue`
  String get monthlyRevenue {
    return Intl.message(
      'Monthly Revenue',
      name: 'monthlyRevenue',
      desc: '',
      args: [],
    );
  }

  /// `Total Cancelled`
  String get totalCancelled {
    return Intl.message(
      'Total Cancelled',
      name: 'totalCancelled',
      desc: '',
      args: [],
    );
  }

  /// `Search subscriptions...`
  String get searchSubscription {
    return Intl.message(
      'Search subscriptions...',
      name: 'searchSubscription',
      desc: '',
      args: [],
    );
  }

  /// `Filter Subscriptions`
  String get filterSubscriptions {
    return Intl.message(
      'Filter Subscriptions',
      name: 'filterSubscriptions',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get allSubscriptions {
    return Intl.message(
      'All',
      name: 'allSubscriptions',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get activeSubscriptions {
    return Intl.message(
      'Active',
      name: 'activeSubscriptions',
      desc: '',
      args: [],
    );
  }

  /// `Due`
  String get dueSubscriptions {
    return Intl.message(
      'Due',
      name: 'dueSubscriptions',
      desc: '',
      args: [],
    );
  }

  /// `Overdue`
  String get overdueSubscriptions {
    return Intl.message(
      'Overdue',
      name: 'overdueSubscriptions',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled`
  String get cancelledSubscriptions {
    return Intl.message(
      'Cancelled',
      name: 'cancelledSubscriptions',
      desc: '',
      args: [],
    );
  }

  /// `Paused`
  String get pausedSubscriptions {
    return Intl.message(
      'Paused',
      name: 'pausedSubscriptions',
      desc: '',
      args: [],
    );
  }

  /// `View Details`
  String get viewDetails {
    return Intl.message(
      'View Details',
      name: 'viewDetails',
      desc: '',
      args: [],
    );
  }

  /// `Make Payment`
  String get makePayment {
    return Intl.message(
      'Make Payment',
      name: 'makePayment',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Subscription`
  String get cancelSubscription {
    return Intl.message(
      'Cancel Subscription',
      name: 'cancelSubscription',
      desc: '',
      args: [],
    );
  }

  /// `Pause Subscription`
  String get pauseSubscription {
    return Intl.message(
      'Pause Subscription',
      name: 'pauseSubscription',
      desc: '',
      args: [],
    );
  }

  /// `Resume Subscription`
  String get resumeSubscription {
    return Intl.message(
      'Resume Subscription',
      name: 'resumeSubscription',
      desc: '',
      args: [],
    );
  }

  /// `Payment History`
  String get paymentHistory {
    return Intl.message(
      'Payment History',
      name: 'paymentHistory',
      desc: '',
      args: [],
    );
  }

  /// `Subscription Details`
  String get subscriptionDetails {
    return Intl.message(
      'Subscription Details',
      name: 'subscriptionDetails',
      desc: '',
      args: [],
    );
  }

  /// `Start Date`
  String get startDate {
    return Intl.message(
      'Start Date',
      name: 'startDate',
      desc: '',
      args: [],
    );
  }

  /// `Last Payment`
  String get lastPayment {
    return Intl.message(
      'Last Payment',
      name: 'lastPayment',
      desc: '',
      args: [],
    );
  }

  /// `Cycle Start Date`
  String get cycleStartDate {
    return Intl.message(
      'Cycle Start Date',
      name: 'cycleStartDate',
      desc: '',
      args: [],
    );
  }

  /// `Cycle End Date`
  String get cycleEndDate {
    return Intl.message(
      'Cycle End Date',
      name: 'cycleEndDate',
      desc: '',
      args: [],
    );
  }

  /// `Paid By`
  String get paidBy {
    return Intl.message(
      'Paid By',
      name: 'paidBy',
      desc: '',
      args: [],
    );
  }

  /// `No subscriptions found`
  String get noSubscriptions {
    return Intl.message(
      'No subscriptions found',
      name: 'noSubscriptions',
      desc: '',
      args: [],
    );
  }

  /// `Subscription created successfully`
  String get subscriptionCreated {
    return Intl.message(
      'Subscription created successfully',
      name: 'subscriptionCreated',
      desc: '',
      args: [],
    );
  }

  /// `Subscription updated successfully`
  String get subscriptionUpdated {
    return Intl.message(
      'Subscription updated successfully',
      name: 'subscriptionUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Payment processed successfully`
  String get paymentProcessed {
    return Intl.message(
      'Payment processed successfully',
      name: 'paymentProcessed',
      desc: '',
      args: [],
    );
  }

  /// `Subscription cancelled successfully`
  String get subscriptionCancelled {
    return Intl.message(
      'Subscription cancelled successfully',
      name: 'subscriptionCancelled',
      desc: '',
      args: [],
    );
  }

  /// `Subscription paused successfully`
  String get subscriptionPaused {
    return Intl.message(
      'Subscription paused successfully',
      name: 'subscriptionPaused',
      desc: '',
      args: [],
    );
  }

  /// `Subscription resumed successfully`
  String get subscriptionResumed {
    return Intl.message(
      'Subscription resumed successfully',
      name: 'subscriptionResumed',
      desc: '',
      args: [],
    );
  }

  /// `Download and restore database backup from cloud storage`
  String get downloadAndRestore {
    return Intl.message(
      'Download and restore database backup from cloud storage',
      name: 'downloadAndRestore',
      desc: '',
      args: [],
    );
  }

  /// `Restoring database from cloud`
  String get restoringDatabaseFromCloud {
    return Intl.message(
      'Restoring database from cloud',
      name: 'restoringDatabaseFromCloud',
      desc: '',
      args: [],
    );
  }

  /// `Restore from Cloud`
  String get restoreFromCloud {
    return Intl.message(
      'Restore from Cloud',
      name: 'restoreFromCloud',
      desc: '',
      args: [],
    );
  }

  /// `Back up your data locally before proceeding. Restoring from the cloud will overwrite your current database. Are you sure you want to continue?`
  String get restoreFromCloudExplanation {
    return Intl.message(
      'Back up your data locally before proceeding. Restoring from the cloud will overwrite your current database. Are you sure you want to continue?',
      name: 'restoreFromCloudExplanation',
      desc: '',
      args: [],
    );
  }

  /// `Online Menu`
  String get onlineMenuScreen {
    return Intl.message(
      'Online Menu',
      name: 'onlineMenuScreen',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Exchange Rate`
  String get dollarRate {
    return Intl.message(
      'Exchange Rate',
      name: 'dollarRate',
      desc: '',
      args: [],
    );
  }

  /// `Change Next Payment Date`
  String get changeNextPaymentDate {
    return Intl.message(
      'Change Next Payment Date',
      name: 'changeNextPaymentDate',
      desc: '',
      args: [],
    );
  }

  /// `Current Date`
  String get currentDate {
    return Intl.message(
      'Current Date',
      name: 'currentDate',
      desc: '',
      args: [],
    );
  }

  /// `Hidden`
  String get hidden {
    return Intl.message(
      'Hidden',
      name: 'hidden',
      desc: '',
      args: [],
    );
  }

  /// `Edit Monthly Amount`
  String get editMonthlyAmount {
    return Intl.message(
      'Edit Monthly Amount',
      name: 'editMonthlyAmount',
      desc: '',
      args: [],
    );
  }

  /// `Current Amount`
  String get currentAmount {
    return Intl.message(
      'Current Amount',
      name: 'currentAmount',
      desc: '',
      args: [],
    );
  }

  /// `New Amount`
  String get newAmount {
    return Intl.message(
      'New Amount',
      name: 'newAmount',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid amount`
  String get pleaseEnterValidAmount {
    return Intl.message(
      'Please enter a valid amount',
      name: 'pleaseEnterValidAmount',
      desc: '',
      args: [],
    );
  }

  /// `Monthly amount updated successfully`
  String get monthlyAmountUpdatedSuccessfully {
    return Intl.message(
      'Monthly amount updated successfully',
      name: 'monthlyAmountUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Next payment date updated successfully`
  String get nextPaymentDateUpdatedSuccessfully {
    return Intl.message(
      'Next payment date updated successfully',
      name: 'nextPaymentDateUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Export to Excel`
  String get exportToExcel {
    return Intl.message(
      'Export to Excel',
      name: 'exportToExcel',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to cancel this subscription?`
  String get cancelSubscriptionConfirmation {
    return Intl.message(
      'Are you sure you want to cancel this subscription?',
      name: 'cancelSubscriptionConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `confirm`
  String get confirm {
    return Intl.message(
      'confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to resume this subscription?`
  String get resumeSubscriptionConfirmation {
    return Intl.message(
      'Are you sure you want to resume this subscription?',
      name: 'resumeSubscriptionConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Subscription cancelled successfully`
  String get subscriptionCancelledSuccessfully {
    return Intl.message(
      'Subscription cancelled successfully',
      name: 'subscriptionCancelledSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Subscription resumed successfully`
  String get subscriptionResumedSuccessfully {
    return Intl.message(
      'Subscription resumed successfully',
      name: 'subscriptionResumedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Payment Count`
  String get paymentCount {
    return Intl.message(
      'Payment Count',
      name: 'paymentCount',
      desc: '',
      args: [],
    );
  }

  /// `Total Paid`
  String get totalPaid {
    return Intl.message(
      'Total Paid',
      name: 'totalPaid',
      desc: '',
      args: [],
    );
  }

  /// `Total Subscription Income`
  String get totalSubscriptionIncome {
    return Intl.message(
      'Total Subscription Income',
      name: 'totalSubscriptionIncome',
      desc: '',
      args: [],
    );
  }

  /// `Auto Update`
  String get autoUpdateSellingPrice {
    return Intl.message(
      'Auto Update',
      name: 'autoUpdateSellingPrice',
      desc: '',
      args: [],
    );
  }

  /// `Backup date`
  String get backupDate {
    return Intl.message(
      'Backup date',
      name: 'backupDate',
      desc: '',
      args: [],
    );
  }

  /// `Last restore`
  String get lastRestore {
    return Intl.message(
      'Last restore',
      name: 'lastRestore',
      desc: '',
      args: [],
    );
  }

  /// `Never`
  String get never {
    return Intl.message(
      'Never',
      name: 'never',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'fr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
