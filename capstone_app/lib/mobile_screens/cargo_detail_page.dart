// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// class CargoDetailPage extends StatefulWidget {
//   final String cargoId;
//   final String client;
//   final String startLocation;
//   final String endLocation;
//   final String status;
//   final String startDate;
//   final String length;
//   final String width;
//   final String height;
//   final String weight;

//   const CargoDetailPage({
//     Key? key,
//     required this.cargoId,
//     required this.client,
//     required this.startLocation,
//     required this.endLocation,
//     required this.status,
//     required this.startDate,
//     required this.length,
//     required this.width,
//     required this.height,
//     required this.weight,
//   }) : super(key: key);

//   @override
//   _CargoDetailPageState createState() => _CargoDetailPageState();
// }

// class _CargoDetailPageState extends State<CargoDetailPage> {
//   bool _isLoading = false;
//   String? crane;
//   String? threshold;
//   String? vehicle;

//   final TextEditingController _weightController = TextEditingController();
//   final TextEditingController _lengthController = TextEditingController();
//   final TextEditingController _widthController = TextEditingController();
//   final TextEditingController _heightController = TextEditingController();

//   @override
//   void dispose() {
//     _weightController.dispose();
//     _lengthController.dispose();
//     _widthController.dispose();
//     _heightController.dispose();
//     super.dispose();
//   }

//   Future<void> _callBackendApi(BuildContext context) async {
//     final url = Uri.parse('http://127.0.0.1:3000/equipment');
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('auth_token');

//       if (token == null) {
//         throw Exception("Token not found");
//       }

//       final response = await http.post(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           "weight": double.parse(_weightController.text),
//           "length": double.parse(_lengthController.text),
//           "width": double.parse(_widthController.text),
//           "height": double.parse(_heightController.text),
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           crane = data['crane'] ?? "N/A";
//           threshold = data['threshold']?.toString() ?? "N/A";
//           trailer = data['trailer'] ?? "N/A";
//         });

//         if (mounted) {
//           _showResultsDialog(context); // Show results
//         }
//       } else {
//         _showErrorSnackbar("Failed to get recommendation. (${response.statusCode})");
//       }
//     } catch (e) {
//       _showErrorSnackbar("Error: ${e.toString()}");
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _showErrorSnackbar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message)),
//       );
//     }
//   }

//   void _showResultsDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Equipment Recommendation'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Crane: $crane'),
//               Text('Threshold: $threshold'),
//               Text('Trailer: $trailer'),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Color getStatusColor() {
//     switch (widget.status) {
//       case 'Completed':
//         return Colors.green;
//       case 'In Progress':
//         return Colors.blue;
//       case 'On Hold':
//         return Colors.orange;
//       case 'In Review':
//         return Colors.purple;
//       default:
//         return Colors.grey;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 7, 23, 114),
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text(
//           'Project Details',
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     color: Colors.grey[100],
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Project: ${widget.client} Transport',
//                           style: const TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Client: ${widget.client}',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Start Date: ${widget.startDate}',
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Cargo ID: ${widget.cargoId}',
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 6,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: getStatusColor().withOpacity(0.2),
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                               child: Text(
//                                 widget.status,
//                                 style: TextStyle(
//                                   color: getStatusColor(),
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Route Information',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         _buildRouteCard(),
//                         const SizedBox(height: 24),
//                         const Text(
//                           'Cargo Details',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         _buildCargoDetailsCard(),
//                         const SizedBox(height: 24),
//                         const Text(
//                           'Equipment Recommendation',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         _buildEquipmentRecommendationCard(),
//                         const SizedBox(height: 24),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             ElevatedButton(
//                               onPressed: () {
//                                 _callBackendApi(context); // Trigger API call
//                               },
//                               child: Text('Get Equipment Recommendation'),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildRouteCard() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             // Origin (Left side)
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       const Icon(Icons.place, color: Colors.red),
//                       const SizedBox(width: 8),
//                       const Text(
//                         'Origin',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Padding(
//                     padding: const EdgeInsets.only(left: 28),
//                     child: Text(
//                       widget.startLocation,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Arrow in the middle
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   const Icon(
//                     Icons.arrow_forward,
//                     color: Colors.blue,
//                     size: 20,
//                   ),
//                 ],
//               ),
//             ),
//             // Destination (Right side)
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       const Text(
//                         'Destination',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       const Icon(Icons.flag, color: Colors.green),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Padding(
//                     padding: const EdgeInsets.only(right: 28),
//                     child: Text(
//                       widget.endLocation,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCargoDetailsCard() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             _buildDimensionItem('Length', widget.length, Icons.straighten),
//             const Divider(),
//             _buildDimensionItem('Width', widget.width, Icons.border_horizontal),
//             const Divider(),
//             _buildDimensionItem('Height', widget.height, Icons.height),
//             const Divider(),
//             _buildDimensionItem('Weight', widget.weight, Icons.line_weight),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDimensionItem(String label, String value, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.blue[800]),
//           const SizedBox(width: 16),
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Colors.grey,
//             ),
//           ),
//           const Spacer(),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEquipmentRecommendationCard() {
//     return Column(
//       children: [
//         _buildEquipmentCategoryCard('Crane', [
//           {'name': 'X Crane', 'spec': 'max capacity: x ton', 'icon': Icons.construction},
//           {'name': 'Y Crane', 'spec': 'max capacity: x ton', 'icon': Icons.construction},
//           {'name': 'Z Crane', 'spec': 'max capacity: x ton', 'icon': Icons.construction},
//         ]),
//         const SizedBox(height: 16),
//         _buildEquipmentCategoryCard('Trailer Bed', [
//           {'name': 'X Bed', 'spec': 'Length: x metres', 'icon': Icons.local_shipping},
//           {'name': 'Y Bed', 'spec': 'Length: x metres', 'icon': Icons.local_shipping},
//           {'name': 'Z Bed', 'spec': 'Length: x metres', 'icon': Icons.local_shipping},
//         ]),
//       ],
//     );
//   }

//   Widget _buildEquipmentCategoryCard(String category, List<Map<String, dynamic>> items) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               category,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 12),
//             ...items.map((item) => _buildEquipmentItem(
//                   item['name'] as String,
//                   item['spec'] as String,
//                   item['icon'] as IconData,
//                 )),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEquipmentItem(String name, String spec, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.blue[800]),
//           const SizedBox(width: 16),
//           Text(
//             name,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const Spacer(),
//           Text(
//             spec,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Colors.grey,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }