import 'package:capstone_app/mobile_screens/cargo_detail_page.dart';
import 'package:capstone_app/web_screens/msra_generation_screen.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

// Main App Widget
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const NewProjectScreen(),
    );
  }
}

// API service class to handle network calls
class ApiService {
  final String baseUrl = 'http://127.0.0.1:5000/projectstakeholders';

  // Create new project and get project ID
  Future<String> createProject(Map<String, dynamic> projectData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/project'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(projectData),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['projectid'];
    } else {
      throw Exception('Failed to create project');
    }
  }

  // Get cargo classification result
  Future<Map<String, dynamic>> classifyCargo(String projectId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/classify/$projectId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to classify cargo');
    }
  }

  // Save project data to frontend
  Future<void> saveProjectData(
      String projectId, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/project/$projectId/save'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save project data');
    }
  }
}

// Model classes
class Project {
  final String? id;
  final String name;
  final String client;
  final List<Stakeholder> stakeholders;
  final Cargo cargo;
  final String startDate;
  final List<WorkScope> workScopes;
  final String? startDestination;
  final String? endDestination;

  Project({
    this.id,
    required this.name,
    required this.client,
    required this.stakeholders,
    required this.cargo,
    required this.startDate,
    required this.workScopes,
    this.startDestination,
    this.endDestination,
  });

  Map<String, dynamic> toJson() {
    return {
      'projectid': id,
      'projectname': name,
      'client': client,
      'stakeholders': stakeholders.map((s) => s.toJson()).toList(),
      'cargo': cargo.toJson(),
      'startDate': startDate,
      'workScopes': workScopes.map((w) => w.toJson()).toList(),
      'startDestination': startDestination,
      'endDestination': endDestination,
    };
  }
}

class Stakeholder {
  final String userId;
  final String role;

  Stakeholder({required this.userId, required this.role});

  Map<String, dynamic> toJson() {
    return {
      'userid': userId,
      'role': role,
    };
  }
}

class Cargo {
  final String name;
  final double length;
  final double breadth;
  final double height;
  final double weight;
  final int quantity;
  final String? result;

  Cargo({
    required this.name,
    required this.length,
    required this.breadth,
    required this.height,
    required this.weight,
    required this.quantity,
    this.result,
  });

  Map<String, dynamic> toJson() {
    return {
      'cargoname': name,
      'length': length,
      'breadth': breadth,
      'height': height,
      'weight': weight,
      'quantity': quantity,
      'result': result,
    };
  }
}

class WorkScope {
  final String location;
  final String workType;

  WorkScope({required this.location, required this.workType});

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'workType': workType,
    };
  }
}

class NewProjectScreen extends StatefulWidget {
  const NewProjectScreen({Key? key}) : super(key: key);

  @override
  _NewProjectScreenState createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends State<NewProjectScreen> {
  // Form controllers
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController clientController = TextEditingController();
  final TextEditingController cargoNameController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController breadthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController unitsController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController startDestinationController =
      TextEditingController();
  final TextEditingController endDestinationController =
      TextEditingController();

  List<Map<String, String>> stakeholders = [];
  List<Map<String, dynamic>> workScopes = [];

  // States
  bool isLoading = false;
  bool showResults = false;
  String? projectId;
  Map<String, dynamic>? resultData;
  String? classificationResult;

  // Work type options for dropdown
  final List<String> workTypeOptions = ['Lifting', 'Loading', 'Transportation'];
  String? selectedWorkType;

  @override
  void initState() {
    super.initState();
    // Initialize with default date
    startDateController.text = DateTime.now().toString().split(' ')[0];
  }

  @override
  void dispose() {
    // Dispose all controllers
    projectNameController.dispose();
    clientController.dispose();
    cargoNameController.dispose();
    lengthController.dispose();
    breadthController.dispose();
    heightController.dispose();
    weightController.dispose();
    unitsController.dispose();
    startDateController.dispose();
    startDestinationController.dispose();
    endDestinationController.dispose();
    super.dispose();
  }

  // Add a stakeholder
  void addStakeholder() {
    TextEditingController nameController = TextEditingController();
    TextEditingController roleController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Stakeholder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: roleController,
                decoration: InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  stakeholders.add({
                    'userid': nameController.text,
                    'role': roleController.text,
                  });
                });
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Add work scope
  void addWorkScope() {
    TextEditingController locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Work Scope'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Work Type'),
                value: selectedWorkType,
                items: workTypeOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedWorkType = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  workScopes.add({
                    'location': locationController.text,
                    'workType': selectedWorkType,
                  });
                });
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        startDateController.text = picked.toString().split(' ')[0];
      });
    }
  }

  // Run cargo classification
  Future<void> runClassification() async {
    if (projectNameController.text.isEmpty ||
        clientController.text.isEmpty ||
        cargoNameController.text.isEmpty ||
        lengthController.text.isEmpty ||
        breadthController.text.isEmpty ||
        heightController.text.isEmpty ||
        weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill all required fields')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Step 1: Create project in DB and get project ID
      // final projectResponse = await http.post(
      //   Uri.parse('YOUR_API_ENDPOINT/project'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode({
      //     'projectname': projectNameController.text,
      //     'client': clientController.text,
      //     'stakeholders': stakeholders,
      //     'cargo': {
      //       'cargoname': cargoNameController.text,
      //       'length': lengthController.text,
      //       'breadth': breadthController.text,
      //       'height': heightController.text,
      //       'weight': weightController.text,
      //       'quantity': unitsController.text,
      //     }
      //   }),
      // );

      final projectResponse = http.Response(
        json.encode({'projectid': 'dummy_project_id'}),
        200,
      );

      if (projectResponse.statusCode == 200) {
        final projectData = json.decode(projectResponse.body);
        projectId = projectData['projectid'];

        // Step 2: Run OOG classification algorithm
        await Future.delayed(Duration(seconds: 2)); // Simulate network delay

        setState(() {
          resultData = {
            'result': 'OOG', // Dummy classification result
          };
          classificationResult = 'OOG'; // Set dummy result
          showResults = true;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to create project');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showResults ? 'New Project' : 'New Project', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo[900],
        iconTheme: const IconThemeData(color: Colors.white),
        leading: showResults
            ? BackButton(
                onPressed: () {
                  setState(() {
                    showResults = false;
                  });
                },
              )
            : null,
      ),
      body: showResults ? _buildResultScreen() : _buildInputForm(),
    );
  }

  // Input form screen
  Widget _buildInputForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: projectNameController,
              decoration: InputDecoration(labelText: 'Project Name'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: clientController,
              decoration: InputDecoration(labelText: 'Client'),
            ),
            SizedBox(height: 16),

            // Stakeholders section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Stakeholder', style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: addStakeholder,
                  icon: Icon(Icons.add),
                  label: Text('Add Stakeholder'),
                ),
              ],
            ),
            if (stakeholders.isNotEmpty)
              Container(
              height: 120,
              child: ListView.builder(
                itemCount: stakeholders.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Stakeholder: ${stakeholders[index]['userId']}'),
                              Text('Role: ${stakeholders[index]['role']}'),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                stakeholders.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),

            // Start Date
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: startDateController,
                  decoration: InputDecoration(
                    labelText: 'Start Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Cargo Details
            Text('Cargo Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            TextFormField(
              controller: cargoNameController,
              decoration: InputDecoration(labelText: 'Cargo Name'),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 16),

            // Dimensions
            Text('Dimensions', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: lengthController,
                    decoration: InputDecoration(labelText: 'Length (m)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: breadthController,
                    decoration: InputDecoration(labelText: 'Breadth (m)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: heightController,
                    decoration: InputDecoration(labelText: 'Height (m)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Weight & Units
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: weightController,
                    decoration: InputDecoration(labelText: 'Weight (tons)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: unitsController,
                    decoration: InputDecoration(labelText: 'No. of Units'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'Result: $classificationResult',
              style:TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16,),
            Center(
              child: SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: isLoading ? null : runClassification,
                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('Run'),
                ),
              ),
            ),

            // Work Scope
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Work Scope', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(
                  onPressed: addWorkScope,
                  icon: Icon(Icons.add),
                  label: Text('Add Work'),
                ),
              ],
            ),
            if (workScopes.isNotEmpty)
              Container(
                height: 120,
                child: ListView.builder(
                  itemCount: workScopes.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Location: ${workScopes[index]['location']}'),
                                Text('Work: ${workScopes[index]['workType']}'),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  workScopes.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 16),

            // Start Destination
            Text('Start Destination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            TextFormField(
                    controller: startDestinationController,
                    decoration: InputDecoration(labelText: 'Start Destination'),
                    keyboardType: TextInputType.text,
                  ),
                //),
            SizedBox(height: 16),

            // End Destination
            Text('End Destination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            TextFormField(
                    controller: endDestinationController,
                    decoration: InputDecoration(labelText: 'End Destination'),
                    keyboardType: TextInputType.text,
                  ),
                //),
            SizedBox(height: 16),

            // File Upload Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
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
                    icon: Icon(Icons.insert_drive_file),
                    label: Text('Upload MS/RA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context); // Close the current screen
          //Navigator.push(
            //context,
            //MaterialPageRoute(
              //builder: (context) => CargoDetailPage(), // Navigate to the CargoDetailPage
            //),
          //);

          // Show a SnackBar after navigation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('MS/RA Generated')),
          );
        },
        label: Text('Generate MS/RA'), 
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          foregroundColor: Colors.black,
        ),
      ),
    ),
  ],
),
            SizedBox(height: 24),
          ], 
        ),
      ),
    );
  }

  // Result screen
  Widget _buildResultScreen() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project and client info
            TextFormField(
              controller: projectNameController,
              decoration: InputDecoration(labelText: 'Project Name'),
              readOnly: true,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: clientController,
              decoration: InputDecoration(labelText: 'Client'),
              readOnly: true,
            ),
            SizedBox(height: 16),

            // Stakeholders
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Stakeholder', style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: addStakeholder,
                  icon: Icon(Icons.add),
                  label: Text('Add Stakeholder'),
                ),
              ],
            ),
            if (stakeholders.isNotEmpty)
              Container(
                height: 120,
                child: ListView.builder(
                  itemCount: workScopes.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                            Text(stakeholders[index]['userid'] ?? ''),
                            SizedBox(width: 10),
                            Text(stakeholders[index]['role'] ?? ''),
                            SizedBox(width: 20),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  workScopes.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 16),

            // Start Date
            TextFormField(
              controller: startDateController,
              decoration: InputDecoration(
                labelText: 'Start Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
            ),
            SizedBox(height: 24),

            // Cargo Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cargo Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    // Handle removal of cargo
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: cargoNameController,
              decoration: InputDecoration(labelText: 'Cargo Name'),
              readOnly: true,
            ),
            SizedBox(height: 16),

            // Dimensions
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: lengthController,
                    decoration: InputDecoration(labelText: 'Length'),
                    readOnly: true,
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: TextFormField(
                    controller: breadthController,
                    decoration: InputDecoration(labelText: 'Breadth'),
                    readOnly: true,
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: TextFormField(
                    controller: heightController,
                    decoration: InputDecoration(labelText: 'Height'),
                    readOnly: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Classification Result
            Text('Result: OOG or Not OOG', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(classificationResult ?? 'Normal/OOG',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),

            // Work Scope
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Work Scope', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(
                  onPressed: addWorkScope,
                  icon: Icon(Icons.add),
                  label: Text('Add Work'),
                ),
              ],
            ),
            if (workScopes.isNotEmpty)
              Container(
                height: 120,
                child: ListView.builder(
                  itemCount: workScopes.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Location: ${workScopes[index]['location']}'),
                                Text('Work: ${workScopes[index]['workType']}'),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  workScopes.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 16),

            // Start Destination
          //Text('Start Destination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          TextFormField(
            controller: startDestinationController,
            decoration: InputDecoration(labelText: 'Start Destination'),
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 16),

          // End Destination
          //Text('End Destination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          TextFormField(
            controller: endDestinationController,
            decoration: InputDecoration(labelText: 'End Destination'),
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 16),

            // File Upload Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
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
                    icon: Icon(Icons.insert_drive_file),
                    label: Text('Upload MS/RA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Generate MS/RA logic here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('MS/RA Generated')),
                      );
                    },
                    icon: Icon(Icons.text_format),
                    label: Text('Generate MS/RA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}