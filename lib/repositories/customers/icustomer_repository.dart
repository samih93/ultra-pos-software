import 'package:desktoppossystem/models/customers_model.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';

abstract class ICustomerRepository {
  FutureEither<CustomerModel> addCustomer(CustomerModel customerModel);
  FutureEither<CustomerModel> updateCustomer(CustomerModel customerModel);
  FutureEither<List<CustomerModel>> getCustomersByNameOrPhone(String query);

  FutureEitherVoid deleteCustomerById(int id);

  FutureEitherVoid addBulkCustomers(List<CustomerModel> customers);
  FutureEither<List<CustomerModel>> fetchCustomersByBatch(
      {required int offset, required int batchSize});
  FutureEither<int> fetchCustomersCount();
  FutureEither<List<CustomerModel>> fetchTop10Customers(
      DashboardFilterEnum? view);
}
