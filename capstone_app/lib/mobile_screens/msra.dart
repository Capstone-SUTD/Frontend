import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('MSRA Checklist'),
          actions: [
            Icon(Icons.account_circle),
            SizedBox(width: 10),
            Icon(Icons.settings),
          ],
        ),
        body: MSRAUI(),
      ),
    );
  }
}

class MSRAUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(onPressed: () {}, child: Text('Generate MSRA')),
              ElevatedButton(onPressed: () {}, child: Text('Approve MSRA')),
            ],
          ),
          SizedBox(height: 20),
          Text('Assigned To: John Doe'),
          Text('Completion Date: DD/MM/YYYY'),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.download),
                label: Text('Download Method Statement'),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.download),
                label: Text('Download Risk Assessment'),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Onsite Checklist',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 3, // Number of checklist items
              itemBuilder: (context, index) {
                return ChecklistItem();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChecklistItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(value: false, onChanged: (value) {}),
                Expanded(child: Text('Ensure All Safety Protocols Are In Place')),
              ],
            ),
            SizedBox(height: 5),
            Text('Assigned To: HSE Officer'),
            Text('Completion Date: 23:45 10 Nov 2024'),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(onPressed: () {}, child: Text('View')),
                ElevatedButton(onPressed: () {}, child: Text('Edit')),
                ElevatedButton(onPressed: () {}, child: Text('Edit Comment')),
                ElevatedButton(onPressed: () {}, style:
                  ElevatedButton.styleFrom(backgroundColor:
                      Colors.orange),child:
                      Text('View Comment')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
