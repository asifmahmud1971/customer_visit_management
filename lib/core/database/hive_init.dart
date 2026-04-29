import 'package:hive_flutter/hive_flutter.dart';
import '../../features/customer/data/models/customer_model.dart';
import '../../features/customer/data/models/sync_queue_model.dart';

class HiveInit {
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CustomerModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SyncQueueModelAdapter());
    }

    // Open Boxes
    await Hive.openBox<CustomerModel>('customers');
    await Hive.openBox<SyncQueueModel>('sync_queue');
  }
}
