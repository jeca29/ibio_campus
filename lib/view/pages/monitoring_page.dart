import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterlogin/core/constants/colors.dart';
import 'package:flutterlogin/data/api/firestore_helper.dart';

class MonitoringPage extends StatefulWidget {
  final String uid;

  MonitoringPage({required this.uid});

  @override
  _MonitoringPageState createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  FirestoreHelper fh = FirestoreHelper();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monitoring'),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: StreamBuilder<QuerySnapshot>(
          stream: fh.stream('species'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              // Group species by name and count them
              var groupedSpecies = {};
              snapshot.data!.docs.forEach((doc) {
                var data = doc.data() as Map<String, dynamic>;
                var name = data['name'] ?? '';
                if (!groupedSpecies.containsKey(name)) {
                  groupedSpecies[name] = {'count': 1, 'image': data['images'].length > 0 ? data['images'][0] : ''};
                } else {
                  groupedSpecies[name]['count']++;
                }
              });

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: groupedSpecies.keys.length,
                itemBuilder: (context, index) {
                  String name = groupedSpecies.keys.elementAt(index);
                  String imageUrl = groupedSpecies[name]['image'];
                  int count = groupedSpecies[name]['count'];

                  return Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: (imageUrl == "")
                              ? Image.asset(
                                  "assets/images/leaf.jpg",
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            '$name ($count)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
