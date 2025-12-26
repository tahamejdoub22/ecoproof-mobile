import '../config/app_config.dart';
import '../models/recycling_point_model.dart';
import '../models/api_response.dart';
import 'api_service.dart';

class RecyclingPointsService {
  final ApiService apiService;

  RecyclingPointsService({required this.apiService});

  // Get all recycling points
  Future<List<RecyclingPointModel>> getAllPoints() async {
    try {
      final response = await apiService.get(AppConfig.recyclingPointsEndpoint);
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => RecyclingPointModel.fromJson(json),
      );

      if (apiResponse.success && apiResponse.data != null) {
        if (apiResponse.data is List) {
          return (apiResponse.data as List)
              .map((e) => RecyclingPointModel.fromJson(e))
              .toList();
        }
        return [apiResponse.data as RecyclingPointModel];
      }

      throw Exception(apiResponse.error?.message ?? 'Failed to fetch recycling points');
    } catch (e) {
      throw Exception('Error fetching recycling points: ${e.toString()}');
    }
  }

  // Get nearest recycling points
  Future<List<RecyclingPointModel>> getNearestPoints({
    required double latitude,
    required double longitude,
    double radius = 5.0, // km
  }) async {
    try {
      final response = await apiService.get(
        AppConfig.nearestPointsEndpoint,
        queryParameters: {
          'lat': latitude.toString(),
          'lng': longitude.toString(),
          'radius': radius.toString(),
        },
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => RecyclingPointModel.fromJson(json),
      );

      if (apiResponse.success && apiResponse.data != null) {
        if (apiResponse.data is List) {
          return (apiResponse.data as List)
              .map((e) => RecyclingPointModel.fromJson(e))
              .toList();
        }
        return [apiResponse.data as RecyclingPointModel];
      }

      throw Exception(apiResponse.error?.message ?? 'Failed to fetch nearest points');
    } catch (e) {
      throw Exception('Error fetching nearest points: ${e.toString()}');
    }
  }

  // Get single recycling point by ID
  Future<RecyclingPointModel> getPointById(String id) async {
    try {
      final response = await apiService.get('${AppConfig.recyclingPointsEndpoint}/$id');
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => RecyclingPointModel.fromJson(json),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data as RecyclingPointModel;
      }

      throw Exception(apiResponse.error?.message ?? 'Failed to fetch recycling point');
    } catch (e) {
      throw Exception('Error fetching recycling point: ${e.toString()}');
    }
  }
}

