import 'package:flutter/material.dart';
import 'msra.dart';
import 'package:file_picker/file_picker.dart';

class CargoDetailPage extends StatelessWidget {
  final String cargoId;
  final String client;
  final String startLocation;
  final String endLocation;
  final String status;
  final String startDate;
  final String length;
  final String width;
  final String height;
  final String weight;

  const CargoDetailPage({
    Key? key,
    required this.cargoId,
    required this.client,
    required this.startLocation,
    required this.endLocation,
    required this.status,
    required this.startDate,
    required this.length,
    required this.width,
    required this.height,
    required this.weight,
  }) : super(key: key);

  Color getStatusColor() {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.blue;
      case 'On Hold':
        return Colors.orange;
      case 'In Review':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 7, 23, 114),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Project Details',
          style: TextStyle(color: Colors.white),
        ),
        
    
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Project: ${client} Transport',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Client: $client',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                        'Start Date: $startDate',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cargo ID: $cargoId',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: getStatusColor().withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: getStatusColor(),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Route Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRouteCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'Cargo Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCargoDetailsCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'Equipment Recommendation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildEquipmentRecommendationCard(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      label: const Text('View MS/RA Dashboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        // First pop the current route
                        Navigator.pop(context);
                        // Then push the new route with a slight delay to avoid animation issues
                        Future.delayed(const Duration(milliseconds: 100), () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MSRAGenerationScreen(),
                            ),
                          );
                        });
                      },
                    ),
                      //),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.upload),
                        label: const Text('Upload MS/RA'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.any,
                      );

                      if (result != null) {
                        PlatformFile file = result.files.first;
                        // Handle the selected file
                        print('File selected: ${file.name}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('File uploaded: ${file.name}')),
                        );
                      } else {
                        // User canceled the picker
                        print('File selection canceled.');
                      }
                    },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

   Widget _buildRouteCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Origin (Left side)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.place, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text(
                        'Origin',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 28),
                    child: Text(
                      startLocation,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow in the middle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.blue,
                    size: 20,
                  ),
                ],
              ),
            ),
            
            // Destination (Right side)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Destination',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.flag, color: Colors.green),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(right: 28),
                    child: Text(
                      endLocation,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCargoDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDimensionItem('Length', length, Icons.straighten),
            const Divider(),
            _buildDimensionItem('Width', width, Icons.border_horizontal),
            const Divider(),
            _buildDimensionItem('Height', height, Icons.height),
            const Divider(),
            _buildDimensionItem('Weight', weight, Icons.line_weight),
          ],
        ),
      ),
    );
  }

  Widget _buildDimensionItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[800]),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentRecommendationCard() {
    return Column(
      children: [
        _buildEquipmentCategoryCard('Crane', [
          {'name': 'X Crane', 'spec': 'max capacity: x ton', 'icon': Icons.construction},
          {'name': 'Y Crane', 'spec': 'max capacity: x ton', 'icon': Icons.construction},
          {'name': 'Z Crane', 'spec': 'max capacity: x ton', 'icon': Icons.construction},
        ]),
        const SizedBox(height: 16),
        _buildEquipmentCategoryCard('Trailer Bed', [
          {'name': 'X Bed', 'spec': 'Length: x metres', 'icon': Icons.local_shipping},
          {'name': 'Y Bed', 'spec': 'Length: x metres', 'icon': Icons.local_shipping},
          {'name': 'Z Bed', 'spec': 'Length: x metres', 'icon': Icons.local_shipping},
        ]),
        const SizedBox(height: 16),
        _buildEquipmentCategoryCard('Trailer Bed', [
          {'name': 'X Bed', 'spec': 'Length: x metres', 'icon': Icons.local_shipping},
          {'name': 'Y Bed', 'spec': 'Length: x metres', 'icon': Icons.local_shipping},
          {'name': 'Z Bed', 'spec': 'Length: x metres', 'icon': Icons.local_shipping},
        ]),
      ],
    );
  }

  Widget _buildEquipmentCategoryCard(String category, List<Map<String, dynamic>> items) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => _buildEquipmentItem(
                  item['name'] as String,
                  item['spec'] as String,
                  item['icon'] as IconData,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentItem(String name, String spec, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[800]),
          const SizedBox(width: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            spec,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

