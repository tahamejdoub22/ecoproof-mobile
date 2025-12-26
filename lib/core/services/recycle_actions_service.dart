import 'dart:io';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/recycle_action_model.dart';
import '../models/api_response.dart';
import '../models/material_type.dart';
import 'api_service.dart';

class RecycleActionsService {
  final ApiService apiService;

  RecycleActionsService({required this.apiService});

  // Submit recycling action
  Future<SubmitActionResponse> submitAction({
    required String recyclingPointId,
    required MaterialType objectType,
    required double confidence,
    required double boundingBoxAreaRatio,
    required int frameCountDetected,
    required double motionScore,
    required String imageHash,
    required String perceptualHash,
    required List<FrameMetadata> frameMetadata,
    required ImageMetadata imageMetadata,
    required double gpsLat,
    required double gpsLng,
    required double gpsAccuracy,
    double? gpsAltitude,
    required int capturedAt,
    required String idempotencyKey,
    required File imageFile,
  }) async {
    try {
      // Create form data
      final formData = FormData.fromMap({
        'recyclingPointId': recyclingPointId,
        'objectType': objectType.value,
        'confidence': confidence,
        'boundingBoxAreaRatio': boundingBoxAreaRatio,
        'frameCountDetected': frameCountDetected,
        'motionScore': motionScore,
        'imageHash': imageHash,
        'perceptualHash': perceptualHash,
        'frameMetadata': frameMetadata.map((e) => e.toJson()).toList(),
        'imageMetadata': imageMetadata.toJson(),
        'gpsLat': gpsLat,
        'gpsLng': gpsLng,
        'gpsAccuracy': gpsAccuracy,
        if (gpsAltitude != null) 'gpsAltitude': gpsAltitude,
        'capturedAt': capturedAt,
        'idempotencyKey': idempotencyKey,
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'recycle_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await apiService.post(
        AppConfig.submitActionEndpoint,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => SubmitActionResponse.fromJson(json),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data as SubmitActionResponse;
      }

      throw Exception(apiResponse.error?.message ?? 'Failed to submit action');
    } catch (e) {
      throw Exception('Error submitting action: ${e.toString()}');
    }
  }

  // Get user's recycle actions
  Future<PaginatedResponse<RecycleActionModel>> getMyActions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await apiService.get(
        AppConfig.myActionsEndpoint,
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      return PaginatedResponse.fromJson(
        response.data,
        (json) => RecycleActionModel.fromJson(json),
      );
    } catch (e) {
      throw Exception('Error fetching actions: ${e.toString()}');
    }
  }
}

