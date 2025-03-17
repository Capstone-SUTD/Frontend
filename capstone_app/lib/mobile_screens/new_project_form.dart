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
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const NewProjectScreen(),
    );
  }
}

// API service class to handle network calls
class ApiService {
  final String baseUrl = 'YOUR_API_ENDPOINT';
  
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
  Future<void> saveProjectData(String projectId, Map<String, dynamic> data) async {
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
  final TextEditingController startDestinationController = TextEditingController();
  final TextEditingController endDestinationController = TextEditingController();

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
    if (projectNameController.text.isEmpty || clientController.text.isEmpty || 
        cargoNameController.text.isEmpty || lengthController.text.isEmpty || 
        breadthController.text.isEmpty || heightController.text.isEmpty || 
        weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields'))
      );
      return;
    }
    
    setState(() {
      isLoading = true;
    });
    
    try {
      // Step 1: Create project in DB and get project ID
      final projectResponse = await http.post(
        Uri.parse('YOUR_API_ENDPOINT/project'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'projectname': projectNameController.text,
          'client': clientController.text,
          'stakeholders': stakeholders,
          'cargo': {
            'cargoname': cargoNameController.text,
            'length': lengthController.text,
            'breadth': breadthController.text,
            'height': heightController.text,
            'weight': weightController.text,
            'quantity': unitsController.text,
          }
        }),
      );
      
      if (projectResponse.statusCode == 200) {
        final projectData = json.decode(projectResponse.body);
        projectId = projectData['projectid'];
        
        // Step 2: Run OOG classification algorithm
        final classifyResponse = await http.get(
          Uri.parse('YOUR_API_ENDPOINT/classify/$projectId'),
        );
        
        if (classifyResponse.statusCode == 200) {
          final responseData = json.decode(classifyResponse.body);
          
          setState(() {
            resultData = responseData;
            classificationResult = responseData['result'];
            showResults = true;
            isLoading = false;
          });
        } else {
          throw Exception('Failed to classify cargo');
        }
      } else {
        throw Exception('Failed to create project');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'))
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showResults ? 'New Project' : 'New Project'),
        leading: showResults ? BackButton(
          onPressed: () {
            setState(() {
              showResults = false;
            });
          },
        ) : null,
      ),
      body: showResults ? _buildResultScreen() : _buildInputForm(),
    );
  }
  
  // Input form screen
  Widget _buildInputForm() {
    return SingleChildScrollView(
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
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: stakeholders.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(right: 8),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(stakeholders[index]['userid'] ?? ''),
                          Text(stakeholders[index]['role'] ?? '', 
                               style: TextStyle(fontSize: 12, color: Colors.grey)),
                          SizedBox(height: 4),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                stakeholders.removeAt(index);
                              });
                            },
                            icon: Icon(Icons.delete, size: 16),
                            label: Text('Remove', style: TextStyle(fontSize: 12)),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size(0, 0),
                            ),
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
          
          //Start Destination
          Text('Start Destination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          TextFormField(
            controller: startDestinationController,
            decoration: InputDecoration(
              labelText: 'Start Destination',
              hintText: 'Enter the start destination',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),

          // End Destination
          Text('End Destination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          TextFormField(
            controller: endDestinationController,
            decoration: InputDecoration(
              labelText: 'End Destination',
              hintText: 'Enter the end destination',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          
          // Special Notes
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.insert_drive_file),
                  label: Text('Upload Vendor MS/RA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
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
          SizedBox(height: 24),
          
          // Run button
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
        ],
      ),
    );
  }
  
  // Result screen
  Widget _buildResultScreen() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project and client info (carried over from previous screen)
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
          
          // Stakeholders (carried over)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Stakeholder', style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: addStakeholder, // Allow adding stakeholders in results view too
                icon: Icon(Icons.add),
                label: Text('Add Stakeholder'),
              ),
            ],
          ),
          if (stakeholders.isNotEmpty)
            Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: stakeholders.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(right: 8),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(stakeholders[index]['userid'] ?? ''),
                          Text(stakeholders[index]['role'] ?? '', 
                               style: TextStyle(fontSize: 12, color: Colors.grey)),
                          SizedBox(height: 4),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                stakeholders.removeAt(index);
                              });
                            },
                            icon: Icon(Icons.delete, size: 16),
                            label: Text('Remove', style: TextStyle(fontSize: 12)),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size(0, 0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          SizedBox(height: 16),
          
          // Start Date (carried over)
          TextFormField(
            controller: startDateController,
            decoration: InputDecoration(
              labelText: 'Start Date',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
          ),
          SizedBox(height: 24),
          
          // Cargo Details with "X" button
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
          
          // Classification Result Box
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Cargo Name', style: TextStyle(fontWeight: FontWeight.bold),
                     textAlign: TextAlign.center),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text('Weight', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${weightController.text} tons'),
                      ],
                    ),
                    Column(
                      children: [
                        Text('No of Units', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(unitsController.text),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      Text('Result: OOG or OOG',
                           style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(classificationResult ?? 'Normal/OOG',
                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          
          // Work Scope (carried over)
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
          
          // Start Destination (carried over)
          Text('Start Destination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          TextFormField(
            controller: startDestinationController,
            decoration: InputDecoration(
              labelText: 'Start Destination',
              hintText: 'Select Destination',
            ),
          ),
          SizedBox(height: 16),

          // End Destination (carried over)
          Text('End Destination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          TextFormField(
            controller: endDestinationController,
            decoration: InputDecoration(
              labelText: 'End Destination',
              hintText: 'Select Destination',
            ),
          ),
          SizedBox(height: 16),
          
          // Special Notes (carried over)
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
                  onPressed: () {},
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
    );
  }
}