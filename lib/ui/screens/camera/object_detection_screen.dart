import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../../../core/models/material_type.dart' as eco;
import '../../../core/models/recycling_point_model.dart';
import '../../../core/services/object_detection_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/recycle_actions_service.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/providers/auth_provider.dart';
import '../../widgets/detection_overlay.dart';

class ObjectDetectionScreen extends StatefulWidget {
  final RecyclingPointModel recyclingPoint;
  final eco.MaterialType objectType;

  const ObjectDetectionScreen({
    super.key,
    required this.recyclingPoint,
    required this.objectType,
  });

  @override
  State<ObjectDetectionScreen> createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _isProcessing = false;
  
  final ObjectDetectionService _detectionService = ObjectDetectionService();
  final LocationService _locationService = LocationService();
  
  ObjectDetectionResult? _detectionResult;
  String? _errorMessage;
  List<String> _validationErrors = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras available';
        });
        return;
      }

      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: ${e.toString()}';
      });
    }
  }

  Future<void> _captureAndDetect() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isCapturing = true;
      _errorMessage = null;
      _detectionResult = null;
      _validationErrors = [];
    });

    try {
      // Request location permission
      final hasPermission = await _locationService.requestPermission();
      if (!hasPermission) {
        throw Exception('Location permission denied');
      }

      // Get current location
      final position = await _locationService.getCurrentLocation();

      // Capture frames
      final frames = await _detectionService.captureFrames(
        cameraController: _cameraController!,
        frameCount: 5,
        expectedType: widget.objectType,
      );

      if (frames.length < 4) {
        throw Exception('Not enough frames captured. Please try again.');
      }

      // Process frames
      final result = await _detectionService.processFrames(
        frames: frames,
        objectType: widget.objectType,
        imageWidth: _cameraController!.value.previewSize?.height.toInt() ?? 1920,
        imageHeight: _cameraController!.value.previewSize?.width.toInt() ?? 1080,
      );

      // Validate
      final isValid = _detectionService.validateDetection(result);
      final errors = _detectionService.getValidationErrors(result);

      setState(() {
        _detectionResult = result;
        _validationErrors = errors;
        _isCapturing = false;
      });

      if (isValid) {
        // Submit action
        await _submitAction(result, position);
      } else {
        // Show validation errors
        _showValidationErrors(errors);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isCapturing = false;
      });
    }
  }

  Future<void> _submitAction(
    ObjectDetectionResult result,
    Position position,
  ) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final actionsService = RecycleActionsService(apiService: authProvider.apiService);

      // Save image to temporary file
      final tempDir = Directory.systemTemp;
      final imageFile = File('${tempDir.path}/recycle_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await imageFile.writeAsBytes(result.imageBytes);

      // Generate idempotency key
      final idempotencyKey = DateTime.now().millisecondsSinceEpoch.toString();

      // Submit action
      final response = await actionsService.submitAction(
        recyclingPointId: widget.recyclingPoint.id,
        objectType: result.objectType,
        confidence: result.confidence,
        boundingBoxAreaRatio: result.boundingBoxAreaRatio,
        frameCountDetected: result.frameCountDetected,
        motionScore: result.motionScore,
        imageHash: result.imageHash,
        perceptualHash: result.perceptualHash,
        frameMetadata: result.frameMetadata,
        imageMetadata: result.imageMetadata,
        gpsLat: position.latitude,
        gpsLng: position.longitude,
        gpsAccuracy: position.accuracy,
        gpsAltitude: position.altitude,
        capturedAt: result.imageMetadata.capturedAt,
        idempotencyKey: idempotencyKey,
        imageFile: imageFile,
      );

      // Clean up temp file
      if (await imageFile.exists()) {
        await imageFile.delete();
      }

      if (!mounted) return;

      // Show success/result
      if (response.verified) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Action verified! Points awarded: ${response.points}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showValidationErrors([response.reason ?? 'Action not verified']);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to submit action: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showValidationErrors(List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validation Failed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: errors.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('• $e'),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Object Detection')),
        body: Center(
          child: _errorMessage != null
              ? Text(_errorMessage!)
              : const CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Detect ${widget.objectType.value}'),
      ),
      body: Stack(
        children: [
          // Camera preview
          CameraPreview(_cameraController!),
          
          // Detection overlay
          if (_detectionResult != null)
            DetectionOverlay(
              result: _detectionResult!,
              errors: _validationErrors,
            ),
          
          // Capture button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: (_isCapturing || _isProcessing) ? null : _captureAndDetect,
                backgroundColor: Colors.green,
                child: (_isCapturing || _isProcessing)
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.camera_alt),
              ),
            ),
          ),
          
          // Error message
          if (_errorMessage != null)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

