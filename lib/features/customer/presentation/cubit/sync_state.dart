import 'package:equatable/equatable.dart';

class SyncState extends Equatable {
  final int pendingCount;
  final bool isSyncing;
  final String? lastSyncedTime;

  const SyncState({
    this.pendingCount = 0,
    this.isSyncing = false,
    this.lastSyncedTime,
  });

  SyncState copyWith({
    int? pendingCount,
    bool? isSyncing,
    String? lastSyncedTime,
  }) {
    return SyncState(
      pendingCount: pendingCount ?? this.pendingCount,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncedTime: lastSyncedTime ?? this.lastSyncedTime,
    );
  }

  @override
  List<Object?> get props => [pendingCount, isSyncing, lastSyncedTime];
}
