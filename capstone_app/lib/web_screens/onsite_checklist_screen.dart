import 'package:flutter/material.dart';
import '../web_common/project_tab_widget.dart';
import '../web_common/project_stepper_widget.dart';
import '../web_common/attachment_popup.dart';
import '../web_common/comment_popup.dart';
import 'msra_generation_screen.dart';

class OnsiteChecklistScreen extends StatefulWidget {
  const OnsiteChecklistScreen({super.key});

  @override
  _OnsiteChecklistScreenState createState() => _OnsiteChecklistScreenState();
}

class _OnsiteChecklistScreenState extends State<OnsiteChecklistScreen> {
  int _currentStep = 12; // Stepper starts from step 12 (Unloading)

  void _onTabSelected(int index) {
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MSRAGenerationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Onsite Checklist")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // **Project Tabs**
            ProjectTabWidget(
              selectedTabIndex: 2,
              onTabSelected: _onTabSelected,
            ),

            const SizedBox(height: 20),

            // **Stepper Widget**
            ProjectStepperWidget(
              currentStep: _currentStep,
              onStepTapped: (step) {},
            ),

            const SizedBox(height: 20),
            const Divider(),

            // **Onsite Checklist Header**
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Onsite Checklist",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            // **Placeholder Checklist Items (Temporary)**
            Expanded(
              child: ListView.builder(
                itemCount: 3, // Placeholder for now
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Checkbox(value: false, onChanged: (bool? value) {}),
                              Text(
                                "Placeholder Checklist Item ${index + 1}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Text("Assigned To: Placeholder"),
                          const Text("Completion Date: TBD"),

                          // **Attachments Section**
                          Row(
                            children: [
                              const Text("Attachments: "),
                              ElevatedButton(
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const AttachmentPopup();
                                  },
                                ),
                                child: const Text("View"),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const AttachmentPopup();
                                  },
                                ),
                                child: const Text("Edit"),
                              ),
                            ],
                          ),

                          // **Comment Buttons**
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CommentPopup(
                                      initialComment: "",
                                      onCommentAdded: (commentText){
                                        print("Comment added: $commentText");
                                      },
                                    );
                                  },
                                ),
                                child: const Text("Leave Comment"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: null,
                                child: const Text("View Comment"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  foregroundColor: Colors.black,
                                ),
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
          ],
        ),
      ),
    );
  }
}

