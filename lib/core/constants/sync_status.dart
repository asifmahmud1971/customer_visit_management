enum SyncStatus {
  synced,
  pendingCreate,
  pendingUpdate,
  failed;

  String get name {
    switch (this) {
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.pendingCreate:
        return 'Pending Create';
      case SyncStatus.pendingUpdate:
        return 'Pending Update';
      case SyncStatus.failed:
        return 'Failed';
    }
  }
}
