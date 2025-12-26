// Example service showing how to add new API endpoints
// You can create similar services for different features

import 'api_service.dart';

class ExampleApiService {
  final ApiService apiService;

  ExampleApiService({required this.apiService});

  // Example: Get data
  Future<Map<String, dynamic>> getData() async {
    try {
      final response = await apiService.get('/example/data');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Example: Create data
  Future<Map<String, dynamic>> createData(Map<String, dynamic> data) async {
    try {
      final response = await apiService.post(
        '/example/data',
        data: data,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Example: Update data
  Future<Map<String, dynamic>> updateData(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await apiService.put(
        '/example/data/$id',
        data: data,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Example: Delete data
  Future<void> deleteData(String id) async {
    try {
      await apiService.delete('/example/data/$id');
    } catch (e) {
      rethrow;
    }
  }
}

