// import 'package:capstone_app/common/splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'new_project_form.dart';
// import 'package:capstone_app/common/login_signup_screen.dart';
// import 'cargo_detail_page.dart';
// import 'package:capstone_app/models/data_service.dart';

// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({Key? key}) : super(key: key);

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         toolbarHeight: 90,
//         backgroundColor: const Color.fromARGB(255, 7, 23, 114),
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Welcome Back, User',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         bottom: TabBar(
//           controller: _tabController,
//           labelColor: Colors.white,
//           unselectedLabelColor: Colors.white70,
//           indicatorColor: Colors.white,
//           tabs: const [
//             Tab(text: 'All Projects'),
//             Tab(text: 'Active'),
//             Tab(text: 'Completed'),
//           ],
//         ),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
        
//             ListTile(
//               leading: const Icon(Icons.add),
//               title: const Text('New Project'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(context, MaterialPageRoute(
//                 builder: (context) => const NewProjectScreen()));
//               },
//             ),
//             ElevatedButton(
//                 onPressed: () {
//                   showDialog(
//                     context: context,
//                     builder: (context) => const EquipmentRecommendationDialog(),
//                   );
//                 },
//                 child: const Text("Get Equipment Recommendation"),
//               ),
            
//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: const Text('Logout'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(context, MaterialPageRoute(
//                 builder: (context) => SplashScreen()));
//               },
//             ),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           AllProjectsPage(),
//           ActiveProjectsPage(),
//           CompletedProjectsPage(),
//         ],
//       ),
//     );
//   }
// }

// // Utility class for shared methods
// class ProjectUtils {
//   static String getClientForProject(String projectName) {
//     switch (projectName) {
//       case 'Global Logistics Shipment':
//         return 'DB Schenker';
//       case 'International Cargo Transport':
//         return 'Maersk Line';
//       case 'European Distribution Chain':
//         return 'DHL Freight';
//       case 'Cross-Continental Freight':
//         return 'FedEx Global';
//       case 'Asian Supply Chain':
//         return 'Nippon Express';
//       case 'Mediterranean Shipping':
//         return 'MSC Cargo';
//       case 'African Logistics Network':
//         return 'Bolloré Logistics';
//       default:
//         return 'Client Company';
//     }
//   }
 
    
//   static String getRandomDimension(String type) {
//     if (type == "length") {
//       return "${4.0 + (DateTime.now().microsecond % 4)} m";
//     } else if (type == "width") {
//       return "${2.0 + (DateTime.now().microsecond % 2)} m";
//     } else { // height
//       return "${2.5 + (DateTime.now().microsecond % 3)} m";
//     }
//   }

//   static String getRandomWeight() {
//     return "${15 + (DateTime.now().microsecond % 15)} tons";
//   }

//   static Widget buildSearchBar(String hintText) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.search, color: Colors.grey),
//           const SizedBox(width: 8),
//           Expanded(
//             child: TextField(
//               decoration: InputDecoration(
//                 border: InputBorder.none,
//                 hintText: hintText,
//                 hintStyle: const TextStyle(color: Colors.grey),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   static Widget buildProjectItem(
//     BuildContext context, 
//     String projectName,
//     String cargoId, 
//     String route, 
//     String dateInfo, 
//     String status, 
//     Color statusColor
//   ) {
//     // Extract cargo ID number from the string
//     String cargoIdNumber = cargoId.split(': ')[1];
//     String dateValue = dateInfo.split(': ')[1];
    
//     return GestureDetector(
//       onTap: () {
//         // Navigate to the specific cargo detail page
//         Navigator.push(
//           context, 
//           MaterialPageRoute(builder: (context) => CargoDetailPage(
//             cargoId: cargoIdNumber,
//             client: getClientForProject(projectName),
//             startLocation: route.split(' → ')[0],
//             endLocation: route.split(' → ')[1],
//             status: status,
//             startDate: dateValue,
//             length: getRandomDimension("length"),
//             width: getRandomDimension("width"),
//             height: getRandomDimension("height"),
//             weight: getRandomWeight(),
//           )),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey[300]!),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               spreadRadius: 1,
//               blurRadius: 2,
//               offset: const Offset(0, 1),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               projectName,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       cargoId,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       dateInfo,
//                       style: const TextStyle(color: Colors.grey),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       route,
//                       style: const TextStyle(color: Colors.grey),
//                     ),
//                   ],
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Text(
//                     status,
//                     style: TextStyle(
//                       color: statusColor,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // All Projects Tab
// class AllProjectsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ProjectUtils.buildSearchBar('Search projects'),
//               const SizedBox(height: 16),
//               ProjectUtils.buildProjectItem(
//                 context, 
//                 'Global Logistics Shipment', 
//                 'Cargo ID: 12345', 
//                 'Jakarta → Singapore', 
//                 'Start Date: 12/02/2025', 
//                 'Completed', 
//                 Colors.green
//               ),
//               const SizedBox(height: 8),
//               ProjectUtils.buildProjectItem(
//                 context, 
//                 'International Cargo Transport', 
//                 'Cargo ID: 23456', 
//                 'Shanghai → Singapore', 
//                 'Start Date: 15/02/2025', 
//                 'In Progress', 
//                 Colors.blue
//               ),
//               const SizedBox(height: 8),
//               ProjectUtils.buildProjectItem(
//                 context, 
//                 'European Distribution Chain', 
//                 'Cargo ID: 34567', 
//                 'Rotterdam → Singapore', 
//                 'Start Date: 10/02/2025', 
//                 'On Hold', 
//                 Colors.orange
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Active Projects Tab
// class ActiveProjectsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ProjectUtils.buildSearchBar('Search active projects'),
//               const SizedBox(height: 16),
//               const Text(
//                 'Active Projects',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ProjectUtils.buildProjectItem(
//                 context, 
//                 'International Cargo Transport', 
//                 'Cargo ID: 23456', 
//                 'Shanghai → Singapore', 
//                 'Start Date: 15/02/2025', 
//                 'In Progress', 
//                 Colors.blue
//               ),
//               const SizedBox(height: 8),
//               ProjectUtils.buildProjectItem(
//                 context, 
//                 'Cross-Continental Freight', 
//                 'Cargo ID: 34578', 
//                 'New York → London', 
//                 'Start Date: 20/02/2025', 
//                 'In Progress', 
//                 Colors.blue
//               ),
//               const SizedBox(height: 8),
//               ProjectUtils.buildProjectItem(
//                 context, 
//                 'Asian Supply Chain', 
//                 'Cargo ID: 45678', 
//                 'Tokyo → Seoul', 
//                 'Start Date: 18/02/2025', 
//                 'In Review', 
//                 Colors.purple
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Completed Projects Tab
// class CompletedProjectsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ProjectUtils.buildSearchBar('Search completed projects'),
//               const SizedBox(height: 16),
//               const Text(
//                 'Completed Projects',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ProjectUtils.buildProjectItem(
//                 context, 
//                 'Global Logistics Shipment', 
//                 'Cargo ID: 12345', 
//                 'Jakarta → Singapore', 
//                 'Start Date: 12/02/2025', 
//                 'Completed', 
//                 Colors.green
//               ),
//               const SizedBox(height: 8),
//               ProjectUtils.buildProjectItem(
//                 context, 
//                 'Mediterranean Shipping', 
//                 'Cargo ID: 56789', 
//                 'Barcelona → Naples', 
//                 'Start Date: 05/02/2025', 
//                 'Completed', 
//                 Colors.green
//               ),
//               const SizedBox(height: 8),
//               ProjectUtils.buildProjectItem(
//                 context, 
//                 'African Logistics Network', 
//                 'Cargo ID: 67890', 
//                 'Cape Town → Lagos', 
//                 'Start Date: 01/02/2025', 
//                 'Completed', 
//                 Colors.green
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }