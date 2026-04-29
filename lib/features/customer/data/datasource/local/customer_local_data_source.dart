import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import '../../models/customer_model.dart';
import '../../models/sync_queue_model.dart';

abstract class CustomerLocalDataSource {
  Future<List<CustomerModel>> getCustomers();
  Future<void> saveCustomers(List<CustomerModel> customers);
  Future<void> updateCustomer(CustomerModel customer);
  
  // Sync Queue
  Future<List<SyncQueueModel>> getPendingSyncItems();
  Future<void> addToSyncQueue(SyncQueueModel item);
  Future<void> removeFromSyncQueue(String entityId);
  Future<void> updateSyncQueueItem(SyncQueueModel item);
}

@LazySingleton(as: CustomerLocalDataSource)
class CustomerLocalDataSourceImpl implements CustomerLocalDataSource {
  static const String customerBoxName = 'customers';
  static const String syncQueueBoxName = 'sync_queue';

  @override
  Future<List<CustomerModel>> getCustomers() async {
    final box = await Hive.openBox<CustomerModel>(customerBoxName);
    return box.values.toList();
  }

  @override
  Future<void> saveCustomers(List<CustomerModel> customers) async {
    final box = await Hive.openBox<CustomerModel>(customerBoxName);
    // Don't overwrite pending changes
    for (var customer in customers) {
      final existing = box.get(customer.id);
      if (existing != null && (existing.syncStatus == 'pendingUpdate' || existing.syncStatus == 'pendingCreate')) {
        continue;
      }
      await box.put(customer.id, customer);
    }
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    final box = await Hive.openBox<CustomerModel>(customerBoxName);
    await box.put(customer.id, customer);
  }

  @override
  Future<List<SyncQueueModel>> getPendingSyncItems() async {
    final box = await Hive.openBox<SyncQueueModel>(syncQueueBoxName);
    return box.values.toList();
  }

  @override
  Future<void> addToSyncQueue(SyncQueueModel item) async {
    final box = await Hive.openBox<SyncQueueModel>(syncQueueBoxName);
    await box.put(item.entityId, item);
  }

  @override
  Future<void> removeFromSyncQueue(String entityId) async {
    final box = await Hive.openBox<SyncQueueModel>(syncQueueBoxName);
    await box.delete(entityId);
  }

  @override
  Future<void> updateSyncQueueItem(SyncQueueModel item) async {
    final box = await Hive.openBox<SyncQueueModel>(syncQueueBoxName);
    await box.put(item.entityId, item);
  }
}
