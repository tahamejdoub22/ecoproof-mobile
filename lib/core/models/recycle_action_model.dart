import 'material_type.dart';
import 'action_status.dart';

class FrameMetadata {
  final int frameIndex;
  final int timestamp;
  final double confidence;
  final BoundingBox boundingBox;

  FrameMetadata({
    required this.frameIndex,
    required this.timestamp,
    required this.confidence,
    required this.boundingBox,
  });

  factory FrameMetadata.fromJson(Map<String, dynamic> json) {
    return FrameMetadata(
      frameIndex: json['frameIndex'] ?? 0,
      timestamp: json['timestamp'] ?? 0,
      confidence: (json['confidence'] ?? 0).toDouble(),
      boundingBox: BoundingBox.fromJson(json['boundingBox'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frameIndex': frameIndex,
      'timestamp': timestamp,
      'confidence': confidence,
      'boundingBox': boundingBox.toJson(),
    };
  }
}

class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
      width: (json['width'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
  }

  double get area => width * height;
}

class ImageMetadata {
  final int width;
  final int height;
  final String format;
  final int capturedAt;

  ImageMetadata({
    required this.width,
    required this.height,
    required this.format,
    required this.capturedAt,
  });

  factory ImageMetadata.fromJson(Map<String, dynamic> json) {
    return ImageMetadata(
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      format: json['format'] ?? 'jpeg',
      capturedAt: json['capturedAt'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'format': format,
      'capturedAt': capturedAt,
    };
  }
}

class RecycleActionModel {
  final String id;
  final String userId;
  final String recyclingPointId;
  final MaterialType objectType;
  final double confidence;
  final String imageHash;
  final String perceptualHash;
  final String imageUrl;
  final double gpsLat;
  final double gpsLng;
  final double gpsAccuracy;
  final double? gpsAltitude;
  final double? verificationScore;
  final double? aiVerificationScore;
  final ActionStatus status;
  final int? pointsAwarded;
  final List<FrameMetadata>? frameMetadata;
  final int frameCountDetected;
  final double motionScore;
  final double boundingBoxAreaRatio;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecycleActionModel({
    required this.id,
    required this.userId,
    required this.recyclingPointId,
    required this.objectType,
    required this.confidence,
    required this.imageHash,
    required this.perceptualHash,
    required this.imageUrl,
    required this.gpsLat,
    required this.gpsLng,
    required this.gpsAccuracy,
    this.gpsAltitude,
    this.verificationScore,
    this.aiVerificationScore,
    required this.status,
    this.pointsAwarded,
    this.frameMetadata,
    required this.frameCountDetected,
    required this.motionScore,
    required this.boundingBoxAreaRatio,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecycleActionModel.fromJson(Map<String, dynamic> json) {
    return RecycleActionModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      recyclingPointId: json['recyclingPointId'] ?? '',
      objectType: MaterialType.fromString(json['objectType'] ?? 'plastic') ?? MaterialType.plastic,
      confidence: (json['confidence'] ?? 0).toDouble(),
      imageHash: json['imageHash'] ?? '',
      perceptualHash: json['perceptualHash'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      gpsLat: (json['gpsLat'] ?? 0).toDouble(),
      gpsLng: (json['gpsLng'] ?? 0).toDouble(),
      gpsAccuracy: (json['gpsAccuracy'] ?? 0).toDouble(),
      gpsAltitude: json['gpsAltitude'] != null ? (json['gpsAltitude']).toDouble() : null,
      verificationScore: json['verificationScore'] != null ? (json['verificationScore']).toDouble() : null,
      aiVerificationScore: json['aiVerificationScore'] != null ? (json['aiVerificationScore']).toDouble() : null,
      status: ActionStatus.fromString(json['status'] ?? 'PENDING') ?? ActionStatus.pending,
      pointsAwarded: json['pointsAwarded'],
      frameMetadata: json['frameMetadata'] != null
          ? (json['frameMetadata'] as List)
              .map((e) => FrameMetadata.fromJson(e))
              .toList()
          : null,
      frameCountDetected: json['frameCountDetected'] ?? 0,
      motionScore: (json['motionScore'] ?? 0).toDouble(),
      boundingBoxAreaRatio: (json['boundingBoxAreaRatio'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'recyclingPointId': recyclingPointId,
      'objectType': objectType.value,
      'confidence': confidence,
      'imageHash': imageHash,
      'perceptualHash': perceptualHash,
      'imageUrl': imageUrl,
      'gpsLat': gpsLat,
      'gpsLng': gpsLng,
      'gpsAccuracy': gpsAccuracy,
      'gpsAltitude': gpsAltitude,
      'verificationScore': verificationScore,
      'aiVerificationScore': aiVerificationScore,
      'status': status.value,
      'pointsAwarded': pointsAwarded,
      'frameMetadata': frameMetadata?.map((e) => e.toJson()).toList(),
      'frameCountDetected': frameCountDetected,
      'motionScore': motionScore,
      'boundingBoxAreaRatio': boundingBoxAreaRatio,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class SubmitActionResponse {
  final bool verified;
  final int? points;
  final String? reason;
  final String actionId;
  final String status;
  final double? verificationScore;

  SubmitActionResponse({
    required this.verified,
    this.points,
    this.reason,
    required this.actionId,
    required this.status,
    this.verificationScore,
  });

  factory SubmitActionResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return SubmitActionResponse(
      verified: data['verified'] ?? false,
      points: data['points'],
      reason: data['reason'],
      actionId: data['actionId'] ?? '',
      status: data['status'] ?? 'PENDING',
      verificationScore: data['verificationScore'] != null ? (data['verificationScore']).toDouble() : null,
    );
  }
}

