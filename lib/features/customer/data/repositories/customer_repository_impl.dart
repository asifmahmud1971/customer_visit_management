import 'dart:async';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/sync_status.dart';
import '../../../../core/constants/visit_status.dart';
import '../../../../core/network/internet_connection_checker.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../models/customer_model.dart';
import '../models/sync_queue_model.dart';
import '../datasource/local/customer_local_data_source.dart';
import '../datasource/remote/customer_remote_data_source.dart';

@LazySingleton(as: CustomerRepository)
class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerLocalDataSource _localDataSource;
  final CustomerRemoteDataSource _remoteDataSource;
  final InternetConnectionChecker _connectionChecker;

  CustomerRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._connectionChecker,
  );

  @override
  Future<List<Customer>> getCustomers({bool forceRefresh = false}) async {
    // Always load from local first
    final localCustomers = await _localDataSource.getCustomers();

    if (forceRefresh || localCustomers.isEmpty) {
      if (await _connectionChecker.hasInternetConnection()) {
        try {
          final remoteCustomers = await _remoteDataSource.getCustomers();
          await _localDataSource.saveCustomers(remoteCustomers);
          return (await _localDataSource.getCustomers()).map(_mapModelToEntity).toList();
        } catch (_) {
          // Fallback to local if remote fails
        }
      }
    }

    return localCustomers.map(_mapModelToEntity).toList();
  }

  @override
  Future<void> updateCustomerVisit(int customerId, VisitStatus status, String notes) async {
    final now = DateTime.now().toIso8601String();
    
    // Get existing customer to preserve data
    final customers = await _localDataSource.getCustomers();
    final customerModel = customers.firstWhere((c) => c.id == customerId);
    
    final updatedModel = customerModel.copyWith(
      visitStatus: status.name.toLowerCase().replaceAll(' ', '_'),
      notes: notes,
      lastVisitDate: now.split('T')[0],
      syncStatus: 'pendingUpdate',
    );

    // 1. Save locally
    await _localDataSource.updateCustomer(updatedModel);

    // 2. Add to sync queue
    await _localDataSource.addToSyncQueue(SyncQueueModel(
      entityType: 'customer',
      entityId: customerId.toString(),
      operationType: 'update',
      payload: {
        'visitStatus': status.name.toLowerCase().replaceAll(' ', '_'),
        'notes': notes,
        'lastVisitDate': now.split('T')[0],
      },
      createdTime: now,
      syncStatus: 'pending',
    ));

    // 3. Try to sync immediately if online
    if (await _connectionChecker.hasInternetConnection()) {
      unawaited(syncPendingData());
    }
  }

  @override
  Future<void> createVisit(int customerId, VisitStatus status, String notes) async {
    final now = DateTime.now().toIso8601String();
    final today = now.split('T')[0];

    // 1. Update local customer record with new visit info
    final customers = await _localDataSource.getCustomers();
    final customerModel = customers.firstWhere((c) => c.id == customerId);
    final updatedModel = customerModel.copyWith(
      visitStatus: status.name.toLowerCase().replaceAll(' ', '_'),
      notes: notes,
      lastVisitDate: today,
      syncStatus: 'pendingCreate',
    );
    await _localDataSource.updateCustomer(updatedModel);

    // 2. Add POST /visits to sync queue
    await _localDataSource.addToSyncQueue(SyncQueueModel(
      entityType: 'visit',
      entityId: customerId.toString(),
      operationType: 'create',
      payload: {
        'customerId': customerId,
        'visitDate': today,
        'status': status.name.toLowerCase().replaceAll(' ', '_'),
        'notes': notes,
      },
      createdTime: now,
      syncStatus: 'pending',
    ));

    // 3. Try to sync immediately if online
    if (await _connectionChecker.hasInternetConnection()) {
      unawaited(syncPendingData());
    }
  }

  @override
  Future<void> syncPendingData() async {
    if (!await _connectionChecker.hasInternetConnection()) return;

    final pendingItems = await _localDataSource.getPendingSyncItems();
    for (var item in pendingItems) {
      try {
        if (item.entityType == 'customer' && item.operationType == 'update') {
          await _remoteDataSource.updateVisitStatus(
            int.parse(item.entityId),
            item.payload['visitStatus'],
            item.payload['notes'],
            item.payload['lastVisitDate'],
          );
        } else if (item.entityType == 'visit' && item.operationType == 'create') {
           await _remoteDataSource.createVisit(
            int.parse(item.entityId),
            item.payload['visitDate'],
            item.payload['status'],
            item.payload['notes'],
          );
        }

        // Mark as synced locally
        final customers = await _localDataSource.getCustomers();
        final customer = customers.firstWhere((c) => c.id.toString() == item.entityId);
        await _localDataSource.updateCustomer(customer.copyWith(
          syncStatus: 'synced',
          lastSyncedTime: DateTime.now().toIso8601String(),
        ));

        // Remove from queue
        await _localDataSource.removeFromSyncQueue(item.entityId);
      } catch (e) {
        // Update retry count and mark as failed if needed
        await _localDataSource.updateSyncQueueItem(item.copyWith(
          retryCount: item.retryCount + 1,
          lastAttemptTime: DateTime.now().toIso8601String(),
          syncStatus: 'failed',
        ));
      }
    }
  }

  @override
  Stream<int> getPendingSyncCount() async* {
    // This is a bit naive, better to use a reactive DB like Drift or a StreamController
    // But for Hive, we can poll or use a ValueListenable
    while (true) {
      final items = await _localDataSource.getPendingSyncItems();
      yield items.length;
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  Customer _mapModelToEntity(CustomerModel model) {
    return Customer(
      id: model.id,
      name: model.name,
      phone: model.phone,
      email: model.email,
      address: model.address,
      lastVisitDate: model.lastVisitDate,
      visitStatus: VisitStatus.fromString(model.visitStatus),
      notes: model.notes,
      lastSyncedTime: model.lastSyncedTime,
      syncStatus: _mapStringToSyncStatus(model.syncStatus),
    );
  }

  SyncStatus _mapStringToSyncStatus(String status) {
    switch (status) {
      case 'synced':
        return SyncStatus.synced;
      case 'pendingCreate':
        return SyncStatus.pendingCreate;
      case 'pendingUpdate':
        return SyncStatus.pendingUpdate;
      case 'failed':
        return SyncStatus.failed;
      default:
        return SyncStatus.synced;
    }
  }
}
