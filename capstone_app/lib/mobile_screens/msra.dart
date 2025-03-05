import 'package:flutter/material.dart';
import 'cargo_detail_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logistics Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MSRAGenerationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Model class for MSRA projects
class MSRAProject {
  final String id;
  final String title;
  final String assignee;
  final DateTime createdOn;
  final String status; // 'pending', 'approved', 'denied'
  // final String cargoType;
  // final String destination;

  MSRAProject({
    required this.id,
    required this.title,
    required this.assignee,
    required this.createdOn,
    required this.status,
    // required this.cargoType,
    // required this.destination,
  });
}

class MSRAGenerationScreen extends StatefulWidget {
  const MSRAGenerationScreen({Key? key}) : super(key: key);

  @override
  State<MSRAGenerationScreen> createState() => _MSRAGenerationScreenState();
}

class _MSRAGenerationScreenState extends State<MSRAGenerationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentStage = 0;
  int _selectedStatusTab = 0; // 0 for Pending, 1 for Approved, 2 for Denied

  // Sample data for each tab
  final List<MSRAProject> _pendingProjects = [
    MSRAProject(
      id: 'MSRA-001',
      title: 'MSRA Approval by HSE Officer',
      assignee: 'Alex Johnson',
      createdOn: DateTime(2024, 11, 10, 23, 45),
      status: 'pending',
      // cargoType: 'Hazardous Materials',
      // destination: 'Hamburg Port',
    ),
    MSRAProject(
      id: 'MSRA-002',
      title: 'MSRA Approval by Product Manager',
      assignee: 'Sarah Williams',
      createdOn: DateTime(2024, 11, 10, 23, 45),
      status: 'pending',
      // cargoType: 'Electronics',
      // destination: 'Rotterdam Port',
    ),
    MSRAProject(
      id: 'MSRA-003',
      title: 'MSRA Approval by Operation Manager',
      assignee: 'Michael Chen',
      createdOn: DateTime(2024, 11, 10, 23, 45),
      status: 'pending',
      // cargoType: 'Automotive Parts',
      // destination: 'Singapore Port',
    ),
    MSRAProject(
      id: 'MSRA-004',
      title: 'MSRA Approval by Logistics Supervisor',
      assignee: 'Emily Roberts',
      createdOn: DateTime(2024, 11, 9, 16, 30),
      status: 'pending',
      // cargoType: 'Perishable Goods',
      // destination: 'Dubai Port',
    ),
  ];

  final List<MSRAProject> _approvedProjects = [
    MSRAProject(
      id: 'MSRA-005',
      title: 'MSRA Approval by HSE Officer',
      assignee: 'James Wilson',
      createdOn: DateTime(2024, 11, 8, 14, 20),
      status: 'approved',
      // cargoType: 'Consumer Goods',
      // destination: 'Los Angeles Port',
    ),
    MSRAProject(
      id: 'MSRA-006',
      title: 'MSRA Approval by Product Manager',
      assignee: 'Linda Garcia',
      createdOn: DateTime(2024, 11, 7, 10, 15),
      status: 'approved',
      // cargoType: 'Textile Products',
      // destination: 'New York Port',
    ),
  ];

  final List<MSRAProject> _deniedProjects = [
    MSRAProject(
      id: 'MSRA-007',
      title: 'MSRA Approval by Operation Manager',
      assignee: 'Robert Taylor',
      createdOn: DateTime(2024, 11, 6, 9, 45),
      status: 'denied',
      // cargoType: 'Chemical Products',
      // destination: 'Shanghai Port',
    ),
    MSRAProject(
      id: 'MSRA-008',
      title: 'MSRA Approval by Logistics Supervisor',
      assignee: 'Patricia Martinez',
      createdOn: DateTime(2024, 11, 5, 15, 30),
      status: 'denied',
      // cargoType: 'Construction Materials',
      // destination: 'Sydney Port',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.index = 1; // Start on the middle tab (MS/RA Generation)
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper to get the active project list based on selected tab
  List<MSRAProject> get _activeProjects {
    switch (_selectedStatusTab) {
      case 0:
        return _pendingProjects;
      case 1:
        return _approvedProjects;
      case 2:
        return _deniedProjects;
      default:
        return _pendingProjects;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.indigo[900],
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'MS/RA Generation',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.horizontal(left: Radius.circular(5), right: Radius.circular(5)),
              ),
              
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black54,
              tabs: const [
                Tab(text: "Offsite"),
                Tab(text: "MS/RA"),
                Tab(text: "Onsite"),
              ],
            ),
          ),
          
          const Divider(height: 32),
          
          // Document download section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDownloadButton("Download MS", Icons.download_outlined),
                _buildDownloadButton("Download RA", Icons.download_outlined),
              ],
            ),
          ),
          
          // Creation date info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCreationInfo("Created on: 23:45\n10 Nov 2024"),
                _buildCreationInfo("Created on: 23:45\n10 Nov 2024"),
              ],
            ),
          ),
          
          const Divider(height: 32),
          
          // Status tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildStatusTab(
                  "Pending (${_pendingProjects.length})", 
                  index: 0,
                ),
                _buildStatusTab(
                  "Approved (${_approvedProjects.length})", 
                  index: 1,
                ),
                _buildStatusTab(
                  "Denied (${_deniedProjects.length})", 
                  index: 2,
                ),
              ],
            ),
          ),
          
          // Project items list based on selected tab
          Expanded(
            child: _activeProjects.isEmpty
                ? Center(
                    child: Text(
                      "No ${_selectedStatusTab == 0 ? 'pending' : _selectedStatusTab == 1 ? 'approved' : 'denied'} projects found",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _activeProjects.length,
                    itemBuilder: (context, index) {
                      final project = _activeProjects[index];
                      return _buildProjectItem(project);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
        onPressed: () {
          // Add new MSRA project functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create new MSRA project')),
          );
        },
      ),
    );
  }
  
  Widget _buildDownloadButton(String text, IconData icon) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$text clicked')),
        );
      },
      child: Row(
        children: [
          Icon(icon, color: Colors.purple.shade300, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.purple.shade300,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCreationInfo(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
      textAlign: TextAlign.center,
    );
  }
  
  Widget _buildStatusTab(String text, {required int index}) {
    final isActive = _selectedStatusTab == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedStatusTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? Colors.orange : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isActive ? Colors.black : Colors.grey,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
  
  Widget _buildProjectItem(MSRAProject project) {
    // Define colors based on status
    final Color statusColor = project.status == 'pending'
        ? Colors.orange
        : project.status == 'approved'
            ? Colors.green
            : Colors.red;
            
    final bool showActions = project.status == 'pending';
    
    return GestureDetector(
      onTap: () {
        // Navigate to detail page (assumed to be implemented in cargo_detail_page.dart)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CargoDetailPage(projectId: project.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  project.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    project.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  "Action required by ${project.assignee}",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Row(
            //   children: [
            //     Icon(Icons.local_shipping_outlined, size: 14, color: Colors.grey.shade600),
            //     const SizedBox(width: 4),
            //     Text(
            //       "Cargo: ${project.cargoType}",
            //       style: TextStyle(
            //         color: Colors.grey.shade600,
            //         fontSize: 12,
            //       ),
            //     ),
            //     const SizedBox(width: 12),
            //     Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
            //     const SizedBox(width: 4),
            //     Text(
            //       project.destination,
            //       style: TextStyle(
            //         color: Colors.grey.shade600,
            //         fontSize: 12,
            //       ),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 8),
            if (showActions)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton("Approve", Colors.green, onTap: () {
                    _handleApprove(project);
                  }),
                  const SizedBox(width: 8),
                  _buildActionButton("Reject", Colors.red, onTap: () {
                    _handleReject(project);
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButton(String text, Color color, {required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
  
  void _handleApprove(MSRAProject project) {
    setState(() {
      // Remove from pending
      _pendingProjects.removeWhere((p) => p.id == project.id);
      
      // Add to approved with updated status
      _approvedProjects.add(
        MSRAProject(
          id: project.id,
          title: project.title,
          assignee: project.assignee,
          createdOn: project.createdOn,
          status: 'approved',
          // cargoType: project.cargoType,
          // destination: project.destination,
        ),
      );
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${project.title} has been approved')),
    );
  }
  
  void _handleReject(MSRAProject project) {
    setState(() {
      // Remove from pending
      _pendingProjects.removeWhere((p) => p.id == project.id);
      
      // Add to denied with updated status
      _deniedProjects.add(
        MSRAProject(
          id: project.id,
          title: project.title,
          assignee: project.assignee,
          createdOn: project.createdOn,
          status: 'denied',
          // cargoType: project.cargoType,
          // destination: project.destination,
        ),
      );
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${project.title} has been rejected')),
    );
  }
}

// Stub implementation for the CargoDetailPage
class CargoDetailPage extends StatelessWidget {
  final String projectId;
  
  const CargoDetailPage({Key? key, required this.projectId}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project $projectId Details'),
        backgroundColor: Colors.indigo[900],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Cargo Details for $projectId', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to List'),
            ),
          ],
        ),
      ),
    );
  }
}