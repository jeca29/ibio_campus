import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterlogin/core/constants/colors.dart';
import 'package:flutterlogin/data/api/firestore_helper.dart';
import 'package:flutterlogin/models/user_data.dart';
import 'package:flutterlogin/view/pages/add_feedback_page.dart';
import 'package:flutterlogin/view/pages/show_feedback_page.dart';

class FeedbackPage extends StatefulWidget {
  final String uid; // Pass the UID of the user

  FeedbackPage({required this.uid});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  FirestoreHelper fh = FirestoreHelper();
  UserData _userData = UserData(name: '', email: '', role: '');

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Function to handle the action button tap
  void _handleAddSpecies() {
    // Add your code to navigate to the screen for adding a new species
    // For example, you can use Navigator to push a new page for adding species.
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddFeedbackPage(uid: widget.uid)));
  }

  // Function to handle the delete action for a species
  void _handleDeleteSpecies(String speciesId) async {
    try {
      await fh.deleteItem(speciesId, 'feedbacks'); // Use your FirestoreHelper method to delete the species
      // Optionally, show a success message or update the UI to remove the deleted species
    } catch (e) {
      // Handle any errors that occur during the deletion process
      print('Error deleting feedback: $e');
      // Optionally, show an error message to the user
    }
  }

  Future<void> _loadUserData() async {
    var snapshot = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();

    if (snapshot.exists) {
      setState(() {
        _userData = UserData.fromMap(snapshot.data()!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback'),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        actions: [
          if (_userData.role != "admin")
            // Action button for adding a new species
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _handleAddSpecies,
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fh.streamWithAttributes('feedbacks', (_userData.role == "admin") ? {} : {'uid': widget.uid}),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Display a loading indicator while data is loading
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            // Extract species data from the snapshot
            final speciesList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: speciesList.length,
              itemBuilder: (context, index) {
                final speciesData = speciesList[index].data() as Map<String, dynamic>;
                final speciesId = speciesList[index].id;
                speciesData['id'] = speciesId;
                final name = speciesData['title'] ?? '';
                final description = speciesData['description'] ?? '';
                final status = speciesData['status'];

                return Dismissible(
                  key: Key(speciesId),
                  onDismissed: (direction) {
                    // Handle the delete action when swiped
                    _handleDeleteSpecies(speciesId);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.5), // Set the divider color
                          width: 1.0, // Set the divider width
                        ),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FeedbackDetailsPage(
                              speciesData: speciesData,
                              speciesId: speciesId,
                              uid: widget.uid,
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text(name),
                        // subtitle: Text(description),
                        subtitle: Text(status == null
                            ? "Under Review"
                            : (status
                                ? "DEAR USER, THE REPORT YOU HAVE BEEN SENT HAS BEEN ACCEPTED! THANK YOU!"
                                : "DEAR USER, THE REPORT YOU HAVE BEEN SENT HAS BEEN DECLINED! THANK YOU!")),
                        // Add more information to display as needed
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
