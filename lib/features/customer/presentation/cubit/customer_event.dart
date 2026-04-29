import 'package:equatable/equatable.dart';
import '../../../../../core/constants/visit_status.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomers extends CustomerEvent {
  final bool forceRefresh;
  const LoadCustomers({this.forceRefresh = false});
}

class SearchCustomers extends CustomerEvent {
  final String query;
  const SearchCustomers(this.query);
}

class FilterCustomers extends CustomerEvent {
  final VisitStatus? status;
  const FilterCustomers(this.status);
}

class UpdateVisitStatus extends CustomerEvent {
  final int customerId;
  final VisitStatus status;
  final String notes;

  const UpdateVisitStatus({
    required this.customerId,
    required this.status,
    required this.notes,
  });
}

class CreateVisit extends CustomerEvent {
  final int customerId;
  final VisitStatus status;
  final String notes;

  const CreateVisit({
    required this.customerId,
    required this.status,
    required this.notes,
  });
}
