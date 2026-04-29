import 'package:injectable/injectable.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/constants/http_method.dart';
import '../../models/customer_model.dart';

abstract class CustomerRemoteDataSource {
  Future<List<CustomerModel>> getCustomers();
  Future<void> updateVisitStatus(int id, String status, String notes, String date);
  Future<void> createVisit(int customerId, String date, String status, String notes);
}

@LazySingleton(as: CustomerRemoteDataSource)
class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final ApiClient _apiClient;

  CustomerRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<CustomerModel>> getCustomers() async {
    final response = await _apiClient.request(
      url: 'customers',
      method: HttpMethod.get,
    );
    
    if (response is List) {
      return response.map((json) => CustomerModel.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<void> updateVisitStatus(int id, String status, String notes, String date) async {
    // Mapping to MockAPI schema: visitStatus, notes (as visitDetails or notes), lastVisitDate
    await _apiClient.request(
      url: 'customers/$id',
      method: HttpMethod.put,
      params: {
        'visitStatus': status,
        'notes': notes,
        'lastVisitDate': date,
      },
    );
  }

  @override
  Future<void> createVisit(int customerId, String date, String status, String notes) async {
    // Mapping to MockAPI schema: customerId, visitDate, visitStatus, visitDetails
    await _apiClient.request(
      url: 'visits',
      method: HttpMethod.post,
      params: {
        'customerId': customerId,
        'visitDate': date,
        'visitStatus': status,
        'visitDetails': notes,
      },
    );
  }
}
