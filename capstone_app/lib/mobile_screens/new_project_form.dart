import 'package:flutter/material.dart';
import 'package:capstone_app/common/nav_bar.dart';
import 'dashboard_screen.dart';
import 'package:capstone_app/common/settings.dart';
import 'my_projects_list.dart';

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
      home: const NewProjectForm(),
      routes: {
        '/dashboard': (context) => DashboardScreen(),
        '/settings': (context) => SettingsScreen(),
        '/my-projects': (context) => MyProjectsList(),
      },
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
  DateTime? startDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'New Project',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
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
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Cargo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),

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
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('No of Units')),
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

            const SizedBox(height: 20),

            // Work Scope Section
            // const Text(
            //   'Work Scope',
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
            //const SizedBox(height: 10),
            // _buildWorkScopeTimeline(),
            // const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Vendor MSRA File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Run'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('View Offsite Checklist'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavBar(), 
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
        Text(label, style: const TextStyle(color: Colors.grey)),
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

  // Widget _buildWorkScopeTimeline() {
  //   return Column(
  //     children: [
  //       ElevatedButton(
  //         onPressed: () {},
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: Colors.grey[300],
  //           foregroundColor: Colors.black,
  //           minimumSize: const Size(double.infinity, 40),
  //         ),
  //         child: const Text('Add Work +'),
  //       ),
  //       const SizedBox(height: 5),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         children: [
  //           _buildTimelineItem(true, 'Location'),
  //           _buildTimelineConnector(true),
  //           _buildTimelineItem(true, 'Transport'),
  //           _buildTimelineConnector(true),
  //           _buildTimelineItem(true, 'Current State'),
  //           _buildTimelineConnector(false),
  //           _buildTimelineItem(false, '+ Work'),
  //         ],
  //       ),
  //     ],
  //   );
  // }

//   Widget _buildTimelineItem(bool isCompleted, String label) {
//     return Column(
//       children: [
//         Container(
//           width: 30,
//           height: 30,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: isCompleted ? Colors.grey : Colors.grey[200],
//           ),
//         ),
//         Text(label),
//       ],
//     );
//   }

//   Widget _buildTimelineConnector(bool isCompleted) {
//     return Container(
//       height: 1,
//       width: 20,
//       color: isCompleted ? Colors.grey : Colors.grey[200],
//     );
// }
}
