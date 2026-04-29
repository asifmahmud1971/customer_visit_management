import '../../../../core/constants/visit_status.dart';
import '../entities/customer.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getCustomers({bool forceRefresh = false});
  Future<void> updateCustomerVisit(int customerId, VisitStatus status, String notes);
  Future<void> createVisit(int customerId, VisitStatus status, String notes);
  Future<void> syncPendingData();
  Stream<int> getPendingSyncCount();
}
