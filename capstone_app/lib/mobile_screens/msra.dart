// import 'package:flutter/material.dart';
// import 'onsite_checklist.dart'; // Import Onsite Checklist Screen
// import 'offsite_checklist.dart'; // Import Offsite Checklist Screen
// import 'package:intl/intl.dart'; // Import intl package for DateFormat

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Logistics Management System',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         scaffoldBackgroundColor: Colors.white,
//       ),
//       home: const MSRAGenerationScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class MSRAProject {
//   final String id;
//   final String title;
//   final String assignee;
//   final DateTime createdOn;
//   final String status; // 'pending', 'approved', 'denied'
//   final String task;
//   final String assignedTo;
//   DateTime? completionDate;
//   List<String> attachments;
//   bool isChecked;
//   String? comment; // Added comment field

//   MSRAProject({
//     required this.id,
//     required this.title,
//     required this.assignee,
//     required this.createdOn,
//     required this.status,
//     required this.task,
//     required this.assignedTo,
//     this.completionDate,
//     this.attachments = const [],
//     this.isChecked = false,
//     this.comment,
//   });
// }

// class MSRAGenerationScreen extends StatefulWidget {
//   const MSRAGenerationScreen({Key? key}) : super(key: key);

//   @override
//   State<MSRAGenerationScreen> createState() => _MSRAGenerationScreenState();
// }

// class _MSRAGenerationScreenState extends State<MSRAGenerationScreen>
//     with SingleTickerProviderStateMixin {
//   _MSRAGenerationScreenState(); // Add default constructor
//   late TabController _tabController;
//   int _selectedStatusTab = 0; // 0 for Pending, 1 for Approved, 2 for Denied

//   final List<MSRAProject> _pendingProjects = [
//     MSRAProject(
//       id: 'MSRA-001',
//       title: 'MSRA Approval by HSE Officer',
//       assignee: 'Alex Johnson',
//       createdOn: DateTime(2024, 11, 10, 23, 45),
//       status: 'pending',
//       task: "Ensure All Safety Protocols Are In Place",
//       assignedTo: "HSE Officer",
//       completionDate: DateTime(2024, 11, 10, 23, 45),
//       attachments: ["Attachment 1.jpg", "Attachment 2.jpg"],
//     ),
//   ];

//   final List<MSRAProject> _approvedProjects = [
//     MSRAProject(
//       id: 'MSRA-005',
//       title: 'MSRA Approval by HSE Officer',
//       assignee: 'James Wilson',
//       createdOn: DateTime(2024, 11, 8, 14, 20),
//       status: 'approved',
//       task: "Ensure All Safety Protocols Are In Place",
//       assignedTo: "HSE Officer",
//       completionDate: DateTime(2024, 11, 10, 23, 45),
//       attachments: ["Attachment 1.jpg", "Attachment 2.jpg"],
//     ),
//   ];

//   final List<MSRAProject> _deniedProjects = [
//     MSRAProject(
//       id: 'MSRA-007',
//       title: 'MSRA Approval by Operations Manager',
//       assignee: 'Robert Taylor',
//       createdOn: DateTime(2024, 11, 6, 9, 45),
//       status: 'denied',
//       task: "Ensure All Safety Protocols Are In Place",
//       assignedTo: "HSE Officer",
//       completionDate: DateTime(2024, 11, 10, 23, 45),
//       attachments: ["Attachment 1.jpg", "Attachment 2.jpg"],
//       comment: "Rejected due to incomplete safety protocols.", // Example comment
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _tabController.addListener(_handleTabChange);
//   }

//   void _handleTabChange() {
//   if (_tabController.indexIsChanging) {
//     setState(() {
//       _selectedStatusTab = _tabController.index;
//     });
//   }
// }

//   @override
//   void dispose() {
//     _tabController.removeListener(_handleTabChange);
//     _tabController.dispose();
//     super.dispose();
//   }

//   List<MSRAProject> get _activeProjects {
//     switch (_selectedStatusTab) {
//       case 0:
//         return _pendingProjects;
//       case 1:
//         return _approvedProjects;
//       case 2:
//         return _deniedProjects;
//       default:
//         return _pendingProjects;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: Colors.indigo[900],
//         elevation: 0,
//         leading: const BackButton(color: Colors.white),
//         title: const Text(
//           'MS/RA Generation',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: Column(
//         children: [
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: TabBar(
//               controller: _tabController,
//               indicator: BoxDecoration(
//                 color: Colors.orange,
//                 borderRadius: BorderRadius.horizontal(
//                   left: Radius.circular(5),
//                   right: Radius.circular(5),
//                 ),
//                 border: Border.all(color: Colors.orange, width: 2),
//               ),
//               indicatorSize: TabBarIndicatorSize.tab,
//               labelPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//               labelColor: Colors.white,
//               unselectedLabelColor: Colors.black54,
//               tabs: const [
//                 Tab(text: "MS/RA"),
//                 Tab(text: "Offsite Checklist"),
//                 Tab(text: "Onsite Checklist"),
//               ],
//             ),
//           ),
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 Center(child: _buildMSRATabContent()),
//                 Center(child: OffsiteChecklistScreen()), // Navigate to Offsite Checklist
//                 Center(child: OnsiteChecklistScreen()), // Navigate to Onsite Checklist
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMSRATabContent() {
//     return Column(
//       children: [
//         const Divider(height: 32),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildDownloadButton("Download MS", Icons.download_outlined),
//               _buildDownloadButton("Download RA", Icons.download_outlined),
//             ],
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildCreationInfo("Created on: 23:45\n10 Nov 2024"),
//               _buildCreationInfo("Created on: 23:45\n10 Nov 2024"),
//             ],
//           ),
//         ),
//         const Divider(height: 32),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Row(
//             children: [
//               _buildStatusTab("Pending (${_pendingProjects.length})", index: 0),
//               _buildStatusTab("Approved (${_approvedProjects.length})", index: 1),
//               _buildStatusTab("Denied (${_deniedProjects.length})", index: 2),
//             ],
//           ),
//         ),
//         Expanded(
//           child: _activeProjects.isEmpty
//               ? Center(
//                   child: Text(
//                     "No ${_selectedStatusTab == 0 ? 'pending' : _selectedStatusTab == 1 ? 'approved' : 'denied'} projects found",
//                     style: const TextStyle(color: Colors.grey),
//                   ),
//                 )
//               : ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: _activeProjects.length,
//                   itemBuilder: (context, index) {
//                     final project = _activeProjects[index];
//                     return _buildProjectItem(project);
//                   },
//                 ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDownloadButton(String text, IconData icon) {
//     return InkWell(
//       onTap: () {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('$text clicked')),
//         );
//       },
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.purple.shade300, size: 20),
//           const SizedBox(width: 8),
//           Text(
//             text,
//             style: TextStyle(
//               color: Colors.purple.shade300,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCreationInfo(String text) {
//     return Text(
//       text,
//       style: const TextStyle(
//         fontSize: 12,
//         color: Colors.grey,
//       ),
//       textAlign: TextAlign.center,
//     );
//   }

//   Widget _buildStatusTab(String text, {required int index}) {
//     final isActive = _selectedStatusTab == index;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             _selectedStatusTab = index;
//           });
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             border: Border(
//               bottom: BorderSide(
//                 color: isActive ? Colors.orange : Colors.transparent,
//                 width: 2,
//               ),
//             ),
//           ),
//           child: Text(
//             text,
//             style: TextStyle(
//               color: isActive ? Colors.black : Colors.grey,
//               fontSize: 13,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProjectItem(MSRAProject project) {
//     final Color statusColor = project.status == 'pending'
//         ? Colors.orange
//         : project.status == 'approved'
//             ? Colors.green
//             : Colors.red;

//     return GestureDetector(
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 16),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           border: Border(
//             bottom: BorderSide(
//               color: Colors.grey.shade300,
//             ),
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   project.title,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: statusColor),
//                   ),
//                   child: Text(
//                     project.status.toUpperCase(),
//                     style: TextStyle(
//                       color: statusColor,
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
//                 const SizedBox(width: 4),
//                 Text(
//                   "Action required by ${project.assignee}",
//                   style: TextStyle(
//                     color: Colors.grey.shade600,
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//             if (project.status == 'denied') ...[
//   const SizedBox(height: 8),
//   Text(
//     "Rejected by ${project.assignee}",
//     style: TextStyle(
//       color: Colors.red.shade600,
//       fontSize: 12,
//     ),
//   ),
//   const SizedBox(height: 8),
//   Text(
//     "Created on: ${DateFormat('HH:mm dd-MM-yyyy').format(project.createdOn)}",
//     style: const TextStyle(
//       color: Colors.grey,
//       fontSize: 12,
//     ),
//   ),
//   const SizedBox(height: 8),
//   Row(
//     children: [
//       ElevatedButton(
//         onPressed: () {
//           showDialog(
//             context: context,
//             builder: (context) {
//               return AlertDialog(
//                 title: const Text("Re-upload MS/RA"),
//                 content: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         // Logic to upload MS document
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text("MS document uploaded")),
//                         );
//                       },
//                       icon: const Icon(Icons.upload_file),
//                       label: const Text("Upload MS Document"),
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         // Logic to upload RA document
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text("RA document uploaded")),
//                         );
//                       },
//                       icon: const Icon(Icons.upload_file),
//                       label: const Text("Upload RA Document"),
//                     ),
//                   ],
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text("Close"),
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.orange,
//         ),
//         child: const Text(
//           "Re-upload MS/RA",
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//       const SizedBox(width: 8),
//       ElevatedButton(
//         onPressed: () {
//           if (project.comment == null) {
//             _showCommentDialog(project); // Open the "Leave Comment" dialog
//           } else {
//             _showViewCommentDialog(project); // Open the "View Comment" dialog
//           }
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.orange,
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (project.comment != null) const Icon(Icons.comment, size: 16),
//             const SizedBox(width: 8),
//             Text(
//               project.comment == null ? "Leave Comment" : "View Comment",
//               style: const TextStyle(color: Colors.white),
//             ),
//           ],
//         ),
//       ),
//     ],
//   ),
// ],
//             if (project.status == 'approved') ...[
//               const SizedBox(height: 8),
//               ElevatedButton(
//                 onPressed: () {
//               if (project.comment == null) {
//                 _showCommentDialog(project); // Open the "Leave Comment" dialog
//               } else {
//                 _showViewCommentDialog(project); // Open the "View Comment" dialog
//               }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.orange,
//                 ),
//                 child: const Text(
//                   "View Comment",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ],
//             if (project.status == 'pending')
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   _buildActionButton("Approve", Colors.green, onTap: () {
//                     _handleApprove(project);
//                   }),
//                   const SizedBox(width: 8),
//                   _buildActionButton("Reject", Colors.red, onTap: () {
//                     _handleReject(project);
//                   }),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//  void _showCommentDialog(MSRAProject project) {
//   TextEditingController commentController = TextEditingController(text: project.comment);
//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Text("Leave Comment"),
//         content: TextField(
//           controller: commentController,
//           decoration: const InputDecoration(hintText: "Enter your comment"),
//           maxLines: null, // Allows multiple lines for the comment
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 project.comment = commentController.text; // Save the comment
//               });
//               Navigator.pop(context);
//             },
//             child: const Text("Save"),
//           ),
//         ],
//       );
//     },
//   );
// }
// void _showViewCommentDialog(MSRAProject project) {
//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Text("View Comment"),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 project.comment ?? "No comment available", // Display the comment
//                 style: const TextStyle(fontSize: 16),
//               ),
//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context), // Close the dialog
//             child: const Text("Close"),
//           ),
//           IconButton(
//             icon: const Icon(Icons.edit, size: 20),
//             onPressed: () {
//               Navigator.pop(context); // Close the view dialog
//               _showCommentDialog(project); // Open the edit dialog
//             },
//           ),
//         ],
//       );
//     },
//   );
// }
//   Widget _buildActionButton(String text, Color color, {required Function() onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(
//           text,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 12,
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleApprove(MSRAProject project) {
//     setState(() {
//       _pendingProjects.removeWhere((p) => p.id == project.id);
//       _approvedProjects.add(
//         MSRAProject(
//           id: project.id,
//           title: project.title,
//           assignee: project.assignee,
//           createdOn: project.createdOn,
//           status: 'approved',
//           task: project.task,
//           assignedTo: project.assignedTo,
//           completionDate: DateTime.now(),
//           attachments: project.attachments,
//         ),
//       );
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('${project.title} has been approved')),
//     );
//   }

//   void _handleReject(MSRAProject project) {
//     setState(() {
//       _pendingProjects.removeWhere((p) => p.id == project.id);
//       _deniedProjects.add(
//         MSRAProject(
//           id: project.id,
//           title: project.title,
//           assignee: project.assignee,
//           createdOn: project.createdOn,
//           status: 'denied',
//           task: project.task,
//           assignedTo: project.assignedTo,
//           completionDate: DateTime.now(),
//           attachments: project.attachments,
//         ),
//       );
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('${project.title} has been rejected')),
//     );
//   }
// }