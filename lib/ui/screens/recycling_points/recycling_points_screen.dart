import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/recycling_point_model.dart';
import '../../../core/models/material_type.dart' as eco;
import '../../../core/services/recycling_points_service.dart';
import '../../../core/providers/auth_provider.dart';
import '../../screens/camera/object_detection_screen.dart';

class RecyclingPointsScreen extends StatefulWidget {
  const RecyclingPointsScreen({super.key});

  @override
  State<RecyclingPointsScreen> createState() => _RecyclingPointsScreenState();
}

class _RecyclingPointsScreenState extends State<RecyclingPointsScreen> {
  List<RecyclingPointModel> _points = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = authProvider.apiService;
      final service = RecyclingPointsService(apiService: apiService);
      
      final points = await service.getAllPoints();
      setState(() {
        _points = points;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _selectPointAndMaterial(RecyclingPointModel point) {
    showModalBottomSheet(
      context: context,
      builder: (context) => MaterialSelectionSheet(
        point: point,
        onMaterialSelected: (material) {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ObjectDetectionScreen(
                recyclingPoint: point,
                objectType: material,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycling Points'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPoints,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPoints,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _points.isEmpty
                  ? const Center(child: Text('No recycling points available'))
                  : ListView.builder(
                      itemCount: _points.length,
                      itemBuilder: (context, index) {
                        final point = _points[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            leading: const Icon(Icons.location_on, color: Colors.green),
                            title: Text(point.name),
                            subtitle: Text(
                              'Materials: ${point.allowedMaterials.map((e) => e.value).join(', ')}\n'
                              'Radius: ${point.radius}m',
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () => _selectPointAndMaterial(point),
                          ),
                        );
                      },
                    ),
    );
  }
}

class MaterialSelectionSheet extends StatelessWidget {
  final RecyclingPointModel point;
  final Function(eco.MaterialType) onMaterialSelected;

  const MaterialSelectionSheet({
    super.key,
    required this.point,
    required this.onMaterialSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Material Type',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...point.allowedMaterials.map((material) {
            return ListTile(
              leading: Icon(_getMaterialIcon(material)),
              title: Text(material.value.toUpperCase()),
              onTap: () => onMaterialSelected(material),
            );
          }),
        ],
      ),
    );
  }

  IconData _getMaterialIcon(eco.MaterialType material) {
    switch (material) {
      case eco.MaterialType.cardboard:
        return Icons.inventory_2;
      case eco.MaterialType.glass:
        return Icons.wine_bar;
      case eco.MaterialType.metal:
        return Icons.build;
      case eco.MaterialType.paper:
        return Icons.description;
      case eco.MaterialType.plastic:
        return Icons.water_drop;
    }
  }
}

