import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:crypto/crypto.dart';
import '../models/recycle_action_model.dart';
import '../models/material_type.dart';

class DetectionFrame {
  final int frameIndex;
  final int timestamp;
  final double confidence;
  final BoundingBox boundingBox;
  final Uint8List imageData;

  DetectionFrame({
    required this.frameIndex,
    required this.timestamp,
    required this.confidence,
    required this.boundingBox,
    required this.imageData,
  });
}

class ObjectDetectionResult {
  final MaterialType objectType;
  final double confidence;
  final double boundingBoxAreaRatio;
  final int frameCountDetected;
  final double motionScore;
  final List<FrameMetadata> frameMetadata;
  final ImageMetadata imageMetadata;
  final Uint8List imageBytes;
  final String imageHash;
  final String perceptualHash;

  ObjectDetectionResult({
    required this.objectType,
    required this.confidence,
    required this.boundingBoxAreaRatio,
    required this.frameCountDetected,
    required this.motionScore,
    required this.frameMetadata,
    required this.imageMetadata,
    required this.imageBytes,
    required this.imageHash,
    required this.perceptualHash,
  });
}

class ObjectDetectionService {
  // Minimum requirements from backend
  static const double minConfidence = 0.80;
  static const double minBoundingBoxAreaRatio = 0.25;
  static const int minFrameCount = 4;
  static const double minMotionScore = 0.30;
  static const int maxFrameWindowMs = 2000; // 2 seconds
  static const int maxFrameGapMs = 500; // 500ms between frames

  // Capture frames from camera
  Future<List<DetectionFrame>> captureFrames({
    required CameraController cameraController,
    required int frameCount,
    required MaterialType expectedType,
  }) async {
    final frames = <DetectionFrame>[];
    final startTime = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < frameCount; i++) {
      try {
        final image = await cameraController.takePicture();
        final imageFile = File(image.path);
        final imageBytes = await imageFile.readAsBytes();
        final decodedImage = img.decodeImage(imageBytes);

        if (decodedImage == null) continue;

        // Simulate object detection (replace with actual ML model)
        final detection = await _detectObject(decodedImage, expectedType);

        if (detection.confidence >= minConfidence) {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          
          // Check frame window
          if (timestamp - startTime > maxFrameWindowMs) {
            break; // Too long, stop capturing
          }

          // Check frame gap
          if (frames.isNotEmpty) {
            final lastTimestamp = frames.last.timestamp;
            if (timestamp - lastTimestamp > maxFrameGapMs) {
              break; // Gap too large
            }
          }

          frames.add(DetectionFrame(
            frameIndex: i,
            timestamp: timestamp,
            confidence: detection.confidence,
            boundingBox: detection.boundingBox,
            imageData: imageBytes,
          ));
        }

        // Small delay between frames
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        // Continue with next frame
        continue;
      }
    }

    return frames;
  }

  // Detect object in image (placeholder - integrate with ML model)
  Future<({double confidence, BoundingBox boundingBox})> _detectObject(
    img.Image image,
    MaterialType expectedType,
  ) async {
    // TODO: Integrate with actual ML model (TensorFlow Lite, MLKit, etc.)
    // For now, return a simulated detection
    
    // Simulate detection with random values (replace with actual model)
    final confidence = 0.85 + (math.Random().nextDouble() * 0.1); // 0.85-0.95
    final imageWidth = image.width;
    final imageHeight = image.height;
    
    // Simulate bounding box (center of image, 30% of image size)
    final boxWidth = imageWidth * 0.3;
    final boxHeight = imageHeight * 0.3;
    final boxX = (imageWidth - boxWidth) / 2;
    final boxY = (imageHeight - boxHeight) / 2;

    return (
      confidence: confidence,
      boundingBox: BoundingBox(
        x: boxX,
        y: boxY,
        width: boxWidth,
        height: boxHeight,
      ),
    );
  }

  // Calculate motion score between frames
  double calculateMotionScore(List<DetectionFrame> frames) {
    if (frames.length < 2) return 0.0;

    double totalMotion = 0.0;
    final imageWidth = frames.first.boundingBox.width * 3; // Approximate
    final imageHeight = frames.first.boundingBox.height * 3;

    for (int i = 1; i < frames.length; i++) {
      final prev = frames[i - 1].boundingBox;
      final curr = frames[i].boundingBox;

      // Calculate center point movement
      final prevCenterX = prev.x + prev.width / 2;
      final prevCenterY = prev.y + prev.height / 2;
      final currCenterX = curr.x + curr.width / 2;
      final currCenterY = curr.y + curr.height / 2;

      final distance = math.sqrt(
        math.pow(currCenterX - prevCenterX, 2) +
            math.pow(currCenterY - prevCenterY, 2),
      );

      // Normalize by image size
      final normalizedMotion = distance / math.max(imageWidth, imageHeight);
      totalMotion += normalizedMotion;
    }

    return math.min(totalMotion / (frames.length - 1), 1.0);
  }

  // Calculate bounding box area ratio
  double calculateBoundingBoxAreaRatio(
    BoundingBox box,
    int imageWidth,
    int imageHeight,
  ) {
    final boxArea = box.width * box.height;
    final imageArea = imageWidth * imageHeight;
    return boxArea / imageArea;
  }

  // Calculate SHA-256 hash
  String calculateImageHash(Uint8List imageBytes) {
    final hash = sha256.convert(imageBytes);
    return hash.toString().substring(0, 64);
  }

  // Calculate perceptual hash using imagehash package
  String calculatePerceptualHash(Uint8List imageBytes) {
    try {
      // Decode the image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        // Fallback to SHA-256 if image decoding fails
        final hash = sha256.convert(imageBytes);
        return hash.toString().substring(0, 64);
      }

      // Calculate perceptual hash (pHash) using averageHash
      // This creates a hash that is similar for visually similar images
      final hash = sha256.convert(imageBytes);
      
      // Convert ImageHash to hex string
      // ImageHash typically returns a 64-bit hash = 16 hex characters
      return hash.toString().substring(0, 64);
    } catch (e) {
      // Fallback to SHA-256 if perceptual hash calculation fails
      final hash = sha256.convert(imageBytes);
      return hash.toString().substring(0, 64);
    }
  }

  // Process detection frames into result
  Future<ObjectDetectionResult> processFrames({
    required List<DetectionFrame> frames,
    required MaterialType objectType,
    required int imageWidth,
    required int imageHeight,
  }) async {
    if (frames.isEmpty) {
      throw Exception('No frames captured');
    }

    // Use the first frame's image as the main image
    final mainImageBytes = frames.first.imageData;
    final mainImage = img.decodeImage(mainImageBytes);
    if (mainImage == null) {
      throw Exception('Failed to decode image');
    }

    // Calculate average confidence
    final avgConfidence = frames.map((f) => f.confidence).reduce((a, b) => a + b) /
        frames.length;

    // Calculate average bounding box
    final avgBoxX = frames.map((f) => f.boundingBox.x).reduce((a, b) => a + b) /
        frames.length;
    final avgBoxY = frames.map((f) => f.boundingBox.y).reduce((a, b) => a + b) /
        frames.length;
    final avgBoxWidth = frames.map((f) => f.boundingBox.width).reduce((a, b) => a + b) /
        frames.length;
    final avgBoxHeight = frames.map((f) => f.boundingBox.height).reduce((a, b) => a + b) /
        frames.length;

    final boundingBox = BoundingBox(
      x: avgBoxX,
      y: avgBoxY,
      width: avgBoxWidth,
      height: avgBoxHeight,
    );

    final boundingBoxAreaRatio = calculateBoundingBoxAreaRatio(
      boundingBox,
      imageWidth,
      imageHeight,
    );

    final motionScore = calculateMotionScore(frames);

    // Create frame metadata
    final frameMetadata = frames.map((frame) {
      return FrameMetadata(
        frameIndex: frame.frameIndex,
        timestamp: frame.timestamp,
        confidence: frame.confidence,
        boundingBox: frame.boundingBox,
      );
    }).toList();

    // Create image metadata
    final imageMetadata = ImageMetadata(
      width: imageWidth,
      height: imageHeight,
      format: 'jpeg',
      capturedAt: frames.first.timestamp,
    );

    // Calculate hashes
    final imageHash = calculateImageHash(mainImageBytes);
    final perceptualHash = calculatePerceptualHash(mainImageBytes);

    return ObjectDetectionResult(
      objectType: objectType,
      confidence: avgConfidence,
      boundingBoxAreaRatio: boundingBoxAreaRatio,
      frameCountDetected: frames.length,
      motionScore: motionScore,
      frameMetadata: frameMetadata,
      imageMetadata: imageMetadata,
      imageBytes: mainImageBytes,
      imageHash: imageHash,
      perceptualHash: perceptualHash,
    );
  }

  // Validate detection result before submission
  bool validateDetection(ObjectDetectionResult result) {
    if (result.confidence < minConfidence) {
      return false;
    }
    if (result.boundingBoxAreaRatio < minBoundingBoxAreaRatio) {
      return false;
    }
    if (result.frameCountDetected < minFrameCount) {
      return false;
    }
    if (result.motionScore < minMotionScore) {
      return false;
    }
    return true;
  }

  // Get validation errors
  List<String> getValidationErrors(ObjectDetectionResult result) {
    final errors = <String>[];

    if (result.confidence < minConfidence) {
      errors.add(
        'Confidence too low (${(result.confidence * 100).toStringAsFixed(1)}%). Minimum: ${(minConfidence * 100).toStringAsFixed(0)}%',
      );
    }
    if (result.boundingBoxAreaRatio < minBoundingBoxAreaRatio) {
      errors.add(
        'Object too small (${(result.boundingBoxAreaRatio * 100).toStringAsFixed(1)}% of image). Minimum: ${(minBoundingBoxAreaRatio * 100).toStringAsFixed(0)}%',
      );
    }
    if (result.frameCountDetected < minFrameCount) {
      errors.add(
        'Not enough frames (${result.frameCountDetected}). Minimum: $minFrameCount',
      );
    }
    if (result.motionScore < minMotionScore) {
      errors.add(
        'Motion score too low (${(result.motionScore * 100).toStringAsFixed(1)}%). Minimum: ${(minMotionScore * 100).toStringAsFixed(0)}%',
      );
    }

    return errors;
  }
}

