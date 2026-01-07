import 'package:desktoppossystem/models/customers_model.dart';
import 'package:desktoppossystem/models/failure_model.dart';
import 'package:desktoppossystem/repositories/customers/icustomer_repository.dart';
import 'package:desktoppossystem/shared/constances/table_constant.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jiffy/jiffy.dart' as jiffy_library;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final customerProviderRepository = Provider((ref) {
  return CustomerRepository(ref);
});

class CustomerRepository extends ICustomerRepository {
  final Ref ref;
  CustomerRepository(this.ref);
  @override
  FutureEither<CustomerModel> addCustomer(CustomerModel customerModel) async {
    try {
      CustomerModel? customer;

      final checkCustomer = await checkCustomerByPhone(
        customerModel.phoneNumber.toString(),
      );
      await checkCustomer.fold(
        (l) {
          throw Exception(l.message);
        },
        (r) async {
          await ref
              .read(posDbProvider)
              .database
              .insert(TableConstant.customersTable, customerModel.toJson())
              .then((value) {
                debugPrint("inserted $value");
                customer = CustomerModel.second();
                customer = customerModel;
                customer!.id = value;
              });
        },
      );
      return right(customerModel);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<CustomerModel>> getCustomersByNameOrPhone(
    String query,
  ) async {
    List<CustomerModel> customers = [];

    try {
      List<String> keywords = query.split(" ");
      String q = "";
      for (int i = 0; i < keywords.length; i++) {
        q +=
            " (phoneNumber like '%${keywords[i]}%' or name like '%${keywords[i]}%' )";
        if (i < keywords.length - 1) {
          q += " AND";
        }
      }
      await ref
          .read(posDbProvider)
          .database
          .query(TableConstant.customersTable, where: q)
          .then((response) {
            customers = List.from(
              (response).map((e) => CustomerModel.fromJson(e)),
            );
          });

      return right(customers);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  FutureEither checkCustomerByPhone(String phoneNumber) async {
    try {
      final result = await ref
          .read(posDbProvider)
          .database
          .query(
            TableConstant.customersTable,
            where: "phoneNumber='$phoneNumber'",
          );

      if (result.isNotEmpty) {
        // If the phone number already exists, return FailureModel
        return left(FailureModel("Phone number already exists"));
      }
      return right(true);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<CustomerModel> updateCustomer(
    CustomerModel customerModel,
  ) async {
    CustomerModel customer = CustomerModel.second();

    try {
      await ref
          .read(posDbProvider)
          .database
          .rawUpdate(
            "update ${TableConstant.customersTable} set name='${customerModel.name}', phoneNumber='${customerModel.phoneNumber}' ,  Address='${customerModel.address}',discount =${customerModel.discount}  where id=${customerModel.id}",
          )
          .then((value) {
            customer = customerModel;
          })
          .catchError((error) {
            debugPrint(error.toString());
            throw Exception(error);
          });
      return right(customer);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<CustomerModel>> fetchCustomersByBatch({
    required int offset,
    required int batchSize,
  }) async {
    List<CustomerModel> customers = [];

    try {
      await ref
          .read(posDbProvider)
          .database
          .query(TableConstant.customersTable, limit: batchSize, offset: offset)
          .then((response) {
            customers = List.from(
              (response).map((e) => CustomerModel.fromJson(e)),
            );
          });

      return right(customers);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid deleteCustomerById(int id) async {
    try {
      await ref
          .read(posDbProvider)
          .database
          .rawDelete("delete from ${TableConstant.customersTable} where id=?", [
            id,
          ])
          .then((value) async {});
      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid addBulkCustomers(List<CustomerModel> customers) async {
    try {
      final checkIexistRes = await isContainsSamePhoneNumberInDatabase(
        customers,
      );
      checkIexistRes.fold(
        (l) {
          throw Exception(l.message);
        },
        (r) {
          Batch batch = ref.read(posDbProvider).database.batch();

          for (var customer in customers) {
            batch.insert(TableConstant.customersTable, customer.toJson());
          }
          batch.commit();
        },
      );

      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  FutureEither<bool> isContainsSamePhoneNumberInDatabase(
    List<CustomerModel> customers,
  ) async {
    try {
      await ref
          .read(posDbProvider)
          .database
          .query(
            TableConstant.customersTable,
            where:
                "phoneNumber in  (${customers.map((e) => "'${e.phoneNumber}'").toList().join(',')})",
          )
          .then((value) {
            if (value.isNotEmpty) {
              throw Exception(
                "There are one or more phoneNumber already exist",
              );
            }
          });
      return right(true);
    } catch (e) {
      debugPrint(e.toString());
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<int> fetchCustomersCount() async {
    int count = 0;

    try {
      await ref
          .read(posDbProvider)
          .database
          .rawQuery(
            "select count(*) as count from ${TableConstant.customersTable}",
          )
          .then((value) {
            count = int.tryParse(value[0]["count"].toString()) ?? 0;
          });

      return right(count);
    } catch (e) {
      debugPrint(e.toString());
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<CustomerModel>> fetchTop10Customers(
    DashboardFilterEnum? view,
  ) async {
    try {
      DateTime currentDate = DateTime.now();

      List<CustomerModel> customers = [];
      String query =
          '''
    SELECT 
         c.id,
        c.name, 
        c.phoneNumber,
        SUM(r.foreignReceiptPrice) AS totalPurchases
    FROM 
        ${TableConstant.receiptTable} as r join ${TableConstant.customersTable} as c on r.customerId = c.id  
    ''';
      if (view != null) {
        switch (view) {
          case DashboardFilterEnum.lastYear:
            query +=
                " where CAST(SUBSTR(r.receiptDate, 1, 4) AS integer)=${currentDate.year - 1}";
            break;
          case DashboardFilterEnum.yesterday:
            DateTime yesterday = currentDate.subtract(const Duration(days: 1));
            query +=
                " where CAST(SUBSTR(r.receiptDate, 9, 11) AS integer)=${yesterday.day} and CAST(SUBSTR(r.receiptDate, 6, 8) AS integer)=${yesterday.month} and CAST(SUBSTR(r.receiptDate, 1, 4) AS integer)=${yesterday.year}";
            break;
          case DashboardFilterEnum.today:
            query +=
                " where CAST(SUBSTR(r.receiptDate, 9, 11) AS integer)=${currentDate.day} and CAST(SUBSTR(r.receiptDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(r.receiptDate, 1, 4) AS integer)=${currentDate.year}";
            break;
          case DashboardFilterEnum.thisWeek:
            String startDate =
                jiffy_library.Jiffy.parse(
                      currentDate.toString().split(' ').first,
                    )
                    .startOf(jiffy_library.Unit.week)
                    .dateTime
                    .toString()
                    .split(' ')
                    .first;

            String endDate =
                jiffy_library.Jiffy.parse(
                      currentDate.toString().split(' ').first,
                    )
                    .endOf(jiffy_library.Unit.week)
                    .dateTime
                    .toString()
                    .split(' ')
                    .first;
            query +=
                " where r.receiptDate>='$startDate' and r.receiptDate<='$endDate'";

            break;
          case DashboardFilterEnum.lastMonth:
            query +=
                "  where CAST(SUBSTR(r.receiptDate, 1, 4) AS integer)=${currentDate.year} and CAST(SUBSTR(r.receiptDate, 6, 8) AS integer)=${currentDate.month - 1}";
            break;
          case DashboardFilterEnum.thisMonth:
            query +=
                "  where CAST(SUBSTR(r.receiptDate, 1, 4) AS integer)=${currentDate.year} and CAST(SUBSTR(r.receiptDate, 6, 8) AS integer)=${currentDate.month}";
            break;
          case DashboardFilterEnum.thisYear:
            query +=
                " where CAST(SUBSTR(r.receiptDate, 1, 4) AS integer)=${currentDate.year}";
            break;
        }
      }
      query += "${view != null ? ' and' : ' where'}  r.customerId IS NOT NULL";
      query += ''' GROUP BY 
        c.id
    ORDER BY 
        totalPurchases DESC
    LIMIT 10;
  ''';
      final customersReponse = await ref
          .read(posDbProvider)
          .database
          .rawQuery(query);
      if (customersReponse.isNotEmpty) {
        customers = List.from(
          customersReponse,
        ).map((e) => CustomerModel.fromJson(e)).toList();
      }
      return right(customers);
    } catch (e) {
      print(e.toString());
      return left(FailureModel(e.toString()));
    }
  }
}
