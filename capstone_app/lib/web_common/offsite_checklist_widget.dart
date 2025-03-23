import 'package:flutter/material.dart';

class OffsiteChecklistWidget extends StatefulWidget {
  const OffsiteChecklistWidget({super.key});

  @override
  _OffsiteChecklistWidgetState createState() => _OffsiteChecklistWidgetState();
}

class _OffsiteChecklistWidgetState extends State<OffsiteChecklistWidget> {
  Map<String, bool> expandedSections = {
    "Administrative": false,
    "Safety Precautions": false,
  };

  Map<String, bool> checkedSections = {
    "Administrative": false,
    "Safety Precautions": false,
  };

  final Map<String, List<String>> checklistDetails = {
    "Administrative": [
      "a. Is the permit to work approved?",
      "b. Is the Toolbox meeting conducted and signed?",
      "c. Have the operatives been informed about the type of cargo and rigging requirements?",
      "d. Have all parties concerned been notified regarding the coordination information?",
      "e. Are all required personnel available for the operations?",
      "f. Ensure that a site-specific risk assessment is completed and communicated before work starts.",
      "g. Is an emergency response plan in place, and has the team been briefed?",
      "h. Is a first aid kit readily available, and are first aiders identified?",
      "i. Have all workers undergone the necessary competency checks (e.g., lifting supervisor, signalman, rigger)?",
      "j. Ensure fire extinguishers are accessible, especially near high-risk operations.",
    ],
    "Safety Precautions": [
      "a. Equipment",
      "   i. Are all workers equipped with required PPE, and has it been inspected for damage before use?",
      "   ii. Are all equipment functionally checked?",
      "   iii. Are all spare contingency equipment/materials available?",
      "   iv. Is all equipment checked for functionality, with spare materials and fully charged backup batteries available?",
      "   v. Are all workers aware of the SOPs for each equipment type?",
      "b. Route survey",
      "   i. Is the transportation path clear of obstacles, with pedestrian walkways separate from transport routes?",
      "   ii. Is the traffic control engaged to guide the traffic at lifting zone?",
      "   iii. Ensure proper warning signs and barricades are placed along high-risk routes.",
    ],
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: MediaQuery.of(context).size.height * 0.92,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Offsite Checklist",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: expandedSections.keys.map((key) {
                    return _buildChecklistItem(key);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Checkbox(
            value: checkedSections[title],
            onChanged: (bool? value) {
              setState(() {
                checkedSections[title] = value!;
              });
            },
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: IconButton(
            icon: Icon(
              expandedSections[title]! ? Icons.expand_less : Icons.expand_more,
            ),
            onPressed: () {
              setState(() {
                expandedSections[title] = !expandedSections[title]!;
              });
            },
          ),
        ),
        if (expandedSections[title]!)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: checklistDetails[title]!.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}




