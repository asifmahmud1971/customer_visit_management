import 'package:equatable/equatable.dart';

abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

class StartSyncPolling extends SyncEvent {}

class ManualSyncNow extends SyncEvent {}
