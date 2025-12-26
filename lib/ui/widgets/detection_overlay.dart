import 'package:flutter/material.dart';
import '../../core/services/object_detection_service.dart';

class DetectionOverlay extends StatelessWidget {
  final ObjectDetectionResult result;
  final List<String> errors;

  const DetectionOverlay({
    super.key,
    required this.result,
    required this.errors,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: errors.isEmpty
              ? Colors.green.withValues(alpha: 0.9)
              : Colors.orange.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Detection Status',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            _buildStat('Confidence',
                '${(result.confidence * 100).toStringAsFixed(1)}%'),
            _buildStat('Object Size',
                '${(result.boundingBoxAreaRatio * 100).toStringAsFixed(1)}%'),
            _buildStat('Frames', '${result.frameCountDetected}/4'),
            _buildStat(
                'Motion', '${(result.motionScore * 100).toStringAsFixed(1)}%'),
            if (errors.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(color: Colors.white),
              const SizedBox(height: 8),
              ...errors.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $e',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
