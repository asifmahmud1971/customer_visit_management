import 'package:equatable/equatable.dart';
import '../../../../core/constants/sync_status.dart';
import '../../../../core/constants/visit_status.dart';

class Customer extends Equatable {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String? lastVisitDate;
  final VisitStatus visitStatus;
  final String? notes;
  final String? lastSyncedTime;
  final SyncStatus syncStatus;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    this.lastVisitDate,
    required this.visitStatus,
    this.notes,
    this.lastSyncedTime,
    required this.syncStatus,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        email,
        address,
        lastVisitDate,
        visitStatus,
        notes,
        lastSyncedTime,
        syncStatus,
      ];
}
