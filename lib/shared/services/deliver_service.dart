import 'package:desktoppossystem/models/failure_model.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/shared/constances/table_constant.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class DeliverService {
  FutureEitherVoid deliverInvoice(
      {required ReceiptModel receiptModel, required String note});
  factory DeliverService(String clientKey) {
    switch (clientKey) {
      case '10003':
        return PoenyPourElle();
      case '99999':
        return PoenyPourElle();
      // // Add more cases as needed
      default:
        throw Exception('Client not supported');
    }
  }
}

class PoenyPourElle implements DeliverService {
  @override
  FutureEitherVoid deliverInvoice(
      {required ReceiptModel receiptModel, required String note}) async {
    try {
      Dio dio = Dio();
      dio.options.headers = {
        'Authorization':
            'Bearer dPtE4A/N]t!SNfdX193@CHUMa)OmlASOXiIBQAb70yPpMeby[!NiSuz44SQE2vJzK1)@_!H_MxJ_qVPa(2Ezi4P5PHqr/CW',
        'X-Access-Token':
            'OUlkI6r!c23P91yfng0(JuO.wjrjtTh247uK2(uBKdbK.vPxLy0Ut_G71wGy5p-viXisXmDGZnvq]hP7ac(X!pZ1ohLQaxdW',
      };
      String phoneNumber = "${receiptModel.customerModel?.phoneNumber}";

      String fullName = "";
      String firstName = "";
      String lastName = "";
      if (receiptModel.customerModel != null) {
        String fullName = receiptModel.customerModel!.name.toString();

        // Split the full name on spaces
        var splitFullName = fullName.split(" ");

        // Initialize firstName and lastName

        // Check if there are words in the split array
        if (splitFullName.isNotEmpty) {
          firstName = splitFullName.first; // The first word is the first name

          // Join the remaining words as lastName
          if (splitFullName.length > 1) {
            lastName = splitFullName.sublist(1).join(" "); // Join the rest
          } else {
            lastName = splitFullName.first;
          }
        }
      }

      final response = await dio
          .post("https://systemtunes.com/d2d/api/peony/insert/", data: {
        "firstName": firstName,
        "lastName": lastName,
        "countryPhoneCode": "961",
        "phoneNumber": receiptModel.customerModel?.phoneNumber ?? "00",
        "reference_id": "p_${receiptModel.id}",
        "totalLbpPrice": "0",
        "totalUsdPrice": "${receiptModel.foreignReceiptPrice}",
        "orderSize": "1",
        "zone_id": "2856",
        "address": receiptModel.customerModel?.address ?? '',
        "note": note,
        "refund": 0 //set to 1 for refunded order
      });

      if (response.data.toString().contains("order_id")) {
        await globalAppWidgetRef.read(posDbProvider).database.rawUpdate(
            "update ${TableConstant.receiptTable} set invoiceDelivered=1 , isPaid=0,orderType='${OrderType.delivery.name}' where id=${receiptModel.id}");
        return right(null);
      } else {
        return left(FailureModel(response.data.toString()));
      }
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }
}

class Capella implements DeliverService {
  @override
  FutureEitherVoid deliverInvoice(
      {required ReceiptModel receiptModel, required String note}) async {
    try {
      String phoneNumber = "${receiptModel.customerModel?.phoneNumber}";

      String fullName = "";
      String firstName = "";
      String lastName = "";
      if (receiptModel.customerModel != null) {
        String fullName = receiptModel.customerModel!.name.toString();

        // Split the full name on spaces
        var splitFullName = fullName.split(" ");

        // Initialize firstName and lastName

        // Check if there are words in the split array
        if (splitFullName.isNotEmpty) {
          firstName = splitFullName.first; // The first word is the first name

          // Join the remaining words as lastName
          if (splitFullName.length > 1) {
            lastName = splitFullName.sublist(1).join(" "); // Join the rest
          } else {
            lastName = splitFullName.first;
          }
        }
      }
      print("first name $firstName");
      print("last name $lastName");
      print("last name $note");
      Dio dio = Dio();
      print("calling capella");
      return right(null);
    } catch (e) {
      print("error is $e");
      return left(FailureModel(e.toString()));
    }
  }
}
