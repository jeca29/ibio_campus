import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterlogin/core/constants/colors.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late final CollectionReference speciesCollection;
  late final CollectionReference usersCollection;
  late final CollectionReference feedbacksCollection;

  @override
  void initState() {
    super.initState();
    speciesCollection = FirebaseFirestore.instance.collection('species');
    usersCollection = FirebaseFirestore.instance.collection('users');
    feedbacksCollection = FirebaseFirestore.instance.collection('feedbacks');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report'),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            FutureBuilder<QuerySnapshot>(
              future: speciesCollection.get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text("Error fetching users");
                }

                // Count the number of documents in the users collection
                int speciesCount = snapshot.data?.docs.length ?? 0;

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                  title: Text('Total Species'),
                  trailing: Text('$speciesCount'),
                );
              },
            ),
            FutureBuilder<QuerySnapshot>(
              future: usersCollection.get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text("Error fetching users");
                }

                // Count the number of documents in the users collection
                int userCount = snapshot.data?.docs.length ?? 0;

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                  title: Text('Total Users'),
                  trailing: Text('$userCount'),
                );
              },
            ),
            FutureBuilder<QuerySnapshot>(
              future: feedbacksCollection.get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text("Error fetching feedbacks");
                }

                // Count the number of documents in the feedbacks collection
                int feedbackCount = snapshot.data?.docs.length ?? 0;

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                  title: Text('Total Reports'),
                  trailing: Text('$feedbackCount'),
                );
              },
            ),
            SizedBox(
              height: 50,
            ),
            Text("SPECIES DATA"),
            FutureBuilder<QuerySnapshot>(
              future: speciesCollection.get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error fetching data"));
                }

                if (snapshot.data?.docs == null || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No data found"));
                }

                List<DataRow> rows = snapshot.data!.docs.map((doc) {
                  final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  return DataRow(cells: [
                    DataCell(Text(data.containsKey('name') ? data['name'] : 'N/A')),
                    // DataCell(Text(data.containsKey('category') ? data['category'] : 'N/A')),
                    // DataCell(Text(data.containsKey('habitat') ? data['habitat'] : 'N/A')),
                    DataCell(Text(data.containsKey('category') ? (data['category'] == "Flora" ? data['habitat'] : "") : 'N/A')),
                    DataCell(Text(data.containsKey('category') ? (data['category'] == "Fauna" ? data['habitat'] : "") : 'N/A')),
                    // DataCell(Text(data.containsKey('family') ? data['family'] : 'N/A')),
                    DataCell(Text(data.containsKey('location_words') ? data['location_words'] : 'N/A')),
                  ]);
                }).toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Name')),
                      // DataColumn(label: Text('Category')),
                      // DataColumn(label: Text('Habitat')),
                      DataColumn(label: Text('Flora')),
                      DataColumn(label: Text('Fauna')),
                      // DataColumn(label: Text('Family')),
                      DataColumn(label: Text('Location')),
                    ],
                    rows: rows,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
