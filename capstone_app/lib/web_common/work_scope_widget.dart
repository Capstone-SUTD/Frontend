import 'package:capstone_app/web_screens/msra_generation_screen.dart';
import 'package:flutter/material.dart';

class WorkScopeWidget extends StatefulWidget {
  final Function(String) onScopeSelected;
  final bool isNewProject;
  final Map<String, dynamic>? projectData; // 🔹 Add this for existing OOG projects

  const WorkScopeWidget({
    Key? key,
    required this.onScopeSelected,
    required this.isNewProject,
    this.projectData, // 🔹 Nullable, means it's a new project if null
  }) : super(key: key);

  @override
  _WorkScopeWidgetState createState() => _WorkScopeWidgetState();
}

class _WorkScopeWidgetState extends State<WorkScopeWidget> {
  late TextEditingController startDestinationController;
  late TextEditingController endDestinationController;

  @override
  void initState() {
    super.initState();

    // 🔹 Check if existing OOG project, then prefill with database values
    startDestinationController = TextEditingController(
      text: widget.projectData != null ? widget.projectData!['startDestination'] ?? '' : '',
    );
    endDestinationController = TextEditingController(
      text: widget.projectData != null ? widget.projectData!['endDestination'] ?? '' : '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Start & End Destination Fields
        Row(
          children: [
            Expanded(child: _buildTextField("Start Destination", startDestinationController)),
            SizedBox(width: 20),
            Expanded(child: _buildTextField("End Destination", endDestinationController)),
          ],
        ),
        SizedBox(height: 15),
        
        // 🔹 Work Scope Dropdown
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Work Scope",
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
          ),
          items: ["Scope 1", "Scope 2"].map((String option) {
            return DropdownMenuItem(value: option, child: Text(option));
          }).toList(),
          onChanged: (value) => widget.onScopeSelected(value!),
        ),
        SizedBox(height: 20),

        // 🔹 Work Scope Flow Layout
        _buildWorkScopeFlow(),
        
        SizedBox(height: 20),
        
        // 🔹 Upload Section & Run Button
        _buildUploadSection(),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
    );
  }

  Widget _buildWorkScopeFlow() {
    return Align(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildLocationField("Location"),
          _buildArrowWithText("Lifting only"),
          _buildLocationField("Location 2"),
          _buildArrowWithTextField(),
          _buildLocationField("Final Destination"),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Upload Vendor MSRA here"),
        SizedBox(height: 5),
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            children: [
              Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
              Text("Choose a file or drag & drop it here"),
              TextButton(
                onPressed: () {},
                child: Text("Browse File", style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),

        // 🔹 Run Button
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => MSRAGenerationScreen(),
                  ),
                );
              },
              child: Text("Run"),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField(String label) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        width: 180,
        child: TextField(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildArrowWithText(String label) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Container(width: 30, height: 2, color: Colors.black),
              Icon(Icons.arrow_right_alt, size: 36),
              Container(width: 30, height: 2, color: Colors.black),
            ],
          ),
          SizedBox(height: 5),
          SizedBox(
            width: 120,
            height: 25,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Crane",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              ),
              textAlign: TextAlign.center,
              style:TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrowWithTextField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          SizedBox(
            width: 120,
            height: 25,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Activity Scope",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              ),
              textAlign: TextAlign.center,
              style:TextStyle(fontSize: 12),
            ),
          ),
          Row(
            children: [
              Container(width: 30, height: 2, color: Colors.black),
              Icon(Icons.arrow_right_alt, size: 36),
              Container(width: 30, height: 2, color: Colors.black),
            ],
          ),
          SizedBox(height: 5),
          SizedBox(
            width: 120,
            height: 25,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Equipment List",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              ),
              textAlign: TextAlign.center,
              style:TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}














