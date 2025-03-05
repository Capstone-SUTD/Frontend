import 'package:flutter/material.dart';
import 'offsite_checklist_screen.dart';
import 'dashboard_screen.dart';
import 'my_projects_list.dart';
import 'package:file_picker/file_picker.dart';

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
    );
  }
}

// New Project Form (Stateful Widget)
class NewProjectForm extends StatefulWidget {
  // ignore: use_super_parameters
  const NewProjectForm({Key? key}) : super(key: key);

  @override
  State<NewProjectForm> createState() => _NewProjectFormState();
}

class _NewProjectFormState extends State<NewProjectForm> {
  final List<Widget> _cargoDetailsSections = [];
  DateTime? startDate;
  DateTime? endDate;
  bool _showOffsiteChecklistButton = false;

  @override
  void initState() {
    super.initState();
    // Add the first cargo details section by default
    _cargoDetailsSections.add(_buildCargoDetailsSection());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[900],
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'New Project',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Project Name'),
            _buildTextField('Client'),
            _buildTextField('Email Subject Header'),

            const Text(
              'Start Date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() => startDate = date);
                }
              },
          
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Text(
                      startDate != null
                          ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                          : 'DD/MM/YYYY',
                      style: TextStyle(
                        color: startDate != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'End Date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() => endDate = date);
                }
              },

              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Text(
                      endDate != null
                          ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                          : 'DD/MM/YYYY',
                      style: TextStyle(
                        color: endDate != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cargo Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      // Add a new cargo details section
                      _cargoDetailsSections.add(_buildCargoDetailsSection());
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Cargo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            
            // This is where we display all cargo details sections
            ...List.generate(_cargoDetailsSections.length, (index) => _cargoDetailsSections[index]),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['jpg', 'png', 'pdf', 'doc', 'docx'],
                );

                if (result != null) {
                  String? filePath = result.files.single.path;
                  print('Selected file: $filePath');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('File Selected: ${result.files.single.name}')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No file selected')),
                  );
                }
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Vendor MSRA File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            
           
            const SizedBox(height: 20),
            if (_showOffsiteChecklistButton)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => OffsiteChecklistScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('View Offsite Checklist'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showOffsiteChecklistButton = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Run'),
            ),
          ],
        ),
      ),
    );
  }

  // Create a complete cargo details section
  Widget _buildCargoDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(),
        _buildTextField('Cargo Name'),

        const Text(
          'Dimensions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildDimensionField('Length', 'm')),
            const SizedBox(width: 8),
            Expanded(child: _buildDimensionField('Breadth', 'm')),
            const SizedBox(width: 8),
            Expanded(child: _buildDimensionField('Height', 'm')),
          ],
        ),

        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildDimensionField('Weight', 'tons')),
            const SizedBox(width: 8),
            Expanded(child: _buildDimensionField('No of Units', 'nos.')),
          ],
        ),

        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildDropdownField('Start Destination')),
            const SizedBox(width: 16),
            Expanded(child: _buildDropdownField('End Destination')),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDimensionField(String label, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            suffixText: unit,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            underline: Container(),
            hint: const Text('Select'),
            items: const [],
            onChanged: (value) {},
          ),
        ),
      ],
    );
  }
}