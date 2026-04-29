import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/customer_repository.dart';
import 'customer_event.dart';
import 'customer_state.dart';

@injectable
class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository _repository;

  CustomerBloc(this._repository) : super(CustomerInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<SearchCustomers>(_onSearchCustomers);
    on<FilterCustomers>(_onFilterCustomers);
    on<UpdateVisitStatus>(_onUpdateVisitStatus);
    on<CreateVisit>(_onCreateVisit);
  }

  Future<void> _onLoadCustomers(LoadCustomers event, Emitter<CustomerState> emit) async {
    emit(CustomerLoading());
    try {
      final customers = await _repository.getCustomers(forceRefresh: event.forceRefresh);
      emit(CustomerLoaded(customers: customers, filteredCustomers: customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  void _onSearchCustomers(SearchCustomers event, Emitter<CustomerState> emit) {
    if (state is CustomerLoaded) {
      final currentState = state as CustomerLoaded;
      final filtered = currentState.customers.where((c) {
        final query = event.query.toLowerCase();
        return c.name.toLowerCase().contains(query) || c.phone.contains(query);
      }).toList();
      emit(CustomerLoaded(
        customers: currentState.customers,
        filteredCustomers: filtered,
        searchQuery: event.query,
      ));
    }
  }

  void _onFilterCustomers(FilterCustomers event, Emitter<CustomerState> emit) {
     if (state is CustomerLoaded) {
      final currentState = state as CustomerLoaded;
      if (event.status == null) {
        emit(CustomerLoaded(customers: currentState.customers, filteredCustomers: currentState.customers));
      } else {
        final filtered = currentState.customers.where((c) => c.visitStatus == event.status).toList();
        emit(CustomerLoaded(customers: currentState.customers, filteredCustomers: filtered));
      }
    }
  }

  Future<void> _onUpdateVisitStatus(UpdateVisitStatus event, Emitter<CustomerState> emit) async {
    try {
      await _repository.updateCustomerVisit(event.customerId, event.status, event.notes);
      add(const LoadCustomers());
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onCreateVisit(CreateVisit event, Emitter<CustomerState> emit) async {
    try {
      await _repository.createVisit(event.customerId, event.status, event.notes);
      add(const LoadCustomers());
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }
}
