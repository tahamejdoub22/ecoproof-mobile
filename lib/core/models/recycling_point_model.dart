import 'material_type.dart';

class RecyclingPointModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int radius;
  final double? altitude;
  final List<MaterialType> allowedMaterials;
  final double multiplier;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecyclingPointModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.altitude,
    required this.allowedMaterials,
    required this.multiplier,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecyclingPointModel.fromJson(Map<String, dynamic> json) {
    return RecyclingPointModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      radius: json['radius'] ?? 0,
      altitude: json['altitude'] != null
          ? (json['altitude'] as num).toDouble()
          : null,
      allowedMaterials: (json['allowedMaterials'] as List<dynamic>?)
              ?.map((e) =>
                  MaterialType.fromString(e.toString()) ?? MaterialType.plastic)
              .toList() ??
          [],
      multiplier: (json['multiplier'] ?? 1.0).toDouble(),
      isActive: json['isActive'] ?? true,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'altitude': altitude,
      'allowedMaterials': allowedMaterials.map((e) => e.value).toList(),
      'multiplier': multiplier,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
