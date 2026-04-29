import 'package:hive/hive.dart';

part 'sync_queue_model.g.dart';

@HiveType(typeId: 1)
class SyncQueueModel extends HiveObject {
  @HiveField(0)
  final String entityType; // 'customer' or 'visit'
  
  @HiveField(1)
  final String entityId;
  
  @HiveField(2)
  final String operationType; // 'create' or 'update'
  
  @HiveField(3)
  final Map<String, dynamic> payload;
  
  @HiveField(4)
  final int retryCount;
  
  @HiveField(5)
  final String createdTime;
  
  @HiveField(6)
  final String? lastAttemptTime;
  
  @HiveField(7)
  final String syncStatus; // 'pending' or 'failed'

  SyncQueueModel({
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.payload,
    this.retryCount = 0,
    required this.createdTime,
    this.lastAttemptTime,
    required this.syncStatus,
  });

  SyncQueueModel copyWith({
    String? entityType,
    String? entityId,
    String? operationType,
    Map<String, dynamic>? payload,
    int? retryCount,
    String? createdTime,
    String? lastAttemptTime,
    String? syncStatus,
  }) {
    return SyncQueueModel(
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operationType: operationType ?? this.operationType,
      payload: payload ?? this.payload,
      retryCount: retryCount ?? this.retryCount,
      createdTime: createdTime ?? this.createdTime,
      lastAttemptTime: lastAttemptTime ?? this.lastAttemptTime,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
