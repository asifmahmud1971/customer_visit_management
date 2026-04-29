import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/customer_repository.dart';
import 'sync_event.dart';
import 'sync_state.dart';

@injectable
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final CustomerRepository _repository;
  StreamSubscription? _pendingCountSub;
  StreamSubscription? _connectivitySub;

  SyncBloc(this._repository) : super(const SyncState()) {
    on<StartSyncPolling>(_onStartSyncPolling);
    on<ManualSyncNow>(_onManualSyncNow);
    on<_UpdateCount>(_onUpdateCount);
  }

  Future<void> _onStartSyncPolling(StartSyncPolling event, Emitter<SyncState> emit) async {
    // Poll for pending count
    await _pendingCountSub?.cancel();
    _pendingCountSub = _repository.getPendingSyncCount().listen((count) {
      add(_UpdateCount(count));
    });

    // Auto-sync when internet reconnects
    await _connectivitySub?.cancel();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      if (!result.contains(ConnectivityResult.none)) {
        add(ManualSyncNow());
      }
    });
  }

  void _onUpdateCount(_UpdateCount event, Emitter<SyncState> emit) {
    emit(state.copyWith(pendingCount: event.count));
  }

  Future<void> _onManualSyncNow(ManualSyncNow event, Emitter<SyncState> emit) async {
    if (state.isSyncing) return;
    
    emit(state.copyWith(isSyncing: true));
    try {
      await _repository.syncPendingData();
      emit(state.copyWith(
        isSyncing: false,
        lastSyncedTime: DateTime.now().toIso8601String(),
      ));
    } catch (_) {
      emit(state.copyWith(isSyncing: false));
    }
  }

  @override
  Future<void> close() {
    _pendingCountSub?.cancel();
    _connectivitySub?.cancel();
    return super.close();
  }
}

class _UpdateCount extends SyncEvent {
  final int count;
  const _UpdateCount(this.count);
}
