class PrinterModel {
  int? id;
  String? modelName;
//  String? networkModelName;
  String? pageSize;
  bool? isprintReceipt;
  bool? isHasNetworkPrinter;

  PrinterModel(
      {this.id,
      this.modelName,
      //    this.networkModelName,
      this.pageSize,
      this.isprintReceipt,
      this.isHasNetworkPrinter});
  factory PrinterModel.fromJson(Map<String, dynamic> map) {
    return PrinterModel(
        id: map['id'],
        modelName: map['modelName'],
        //    networkModelName: map['networkModelName'],
        pageSize: map["pageSize"],
        isprintReceipt: map["isprintReceipt"] == 1 ? true : false,
        isHasNetworkPrinter: map["isHasNetworkPrinter"] == 1 ? true : false);
  }

  toJson() {
    return {
      "id": id,
      "modelName": modelName,
      //  "networkModelName": networkModelName,
      "isHasNetworkPrinter": isHasNetworkPrinter == true ? 1 : 0,
      "pageSize": pageSize,
      "isprintReceipt": isprintReceipt == true ? 1 : 0,
    };
  }

  toSpecificJson() {
    return {
      "modelName": modelName,
      //  "networkModelName": networkModelName,
      "pageSize": pageSize,
      "isprintReceipt": isprintReceipt == true ? 1 : 0,
    };
  }
}
