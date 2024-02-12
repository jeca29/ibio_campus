import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterlogin/core/constants/colors.dart';
import 'package:flutterlogin/data/api/firestore_helper.dart';
import 'package:flutterlogin/view/pages/add_species_page.dart';
import 'package:flutterlogin/view/pages/edit_species_page.dart';
import 'package:flutterlogin/view/pages/show_species_page.dart';

class SpeciesPage extends StatefulWidget {
  final String uid;
  final String role;

  SpeciesPage({required this.uid, required this.role});

  @override
  _SpeciesPageState createState() => _SpeciesPageState();
}

class _SpeciesPageState extends State<SpeciesPage> {
  FirestoreHelper fh = FirestoreHelper();

  @override
  void initState() {
    super.initState();
  }

  void _handleAddSpecies() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddSpeciesPage(uid: widget.uid)));
  }

  void _handleDeleteSpecies(String speciesId) async {
    try {
      await fh.deleteItem(speciesId, 'species');
    } catch (e) {
      print('Error deleting species: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory'),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        actions: [
          if (widget.role == "admin")
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _handleAddSpecies,
            ),
        ],
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
              final speciesList = snapshot.data!.docs;

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Number of cards in a row
                  crossAxisSpacing: 10, // Spacing between the cards
                  mainAxisSpacing: 10, // Spacing on the main axis
                ),
                itemCount: speciesList.length,
                itemBuilder: (context, index) {
                  final speciesData = speciesList[index].data() as Map<String, dynamic>;
                  final speciesId = speciesList[index].id;
                  final name = speciesData['name'] ?? '';
                  final imageUrl = speciesData['images'].length > 0 ? speciesData['images'][0] : '';

                  return Card(
                    child: Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            if (widget.role == "admin") {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EditSpeciesPage(
                                    speciesId: speciesId,
                                    uid: widget.uid,
                                  ),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SpeciesDetailsPage(
                                    speciesData: speciesData,
                                    speciesId: speciesId,
                                    uid: widget.uid,
                                  ),
                                ),
                              );
                            }
                          },
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
                                  name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.role == "admin") // Show delete icon for admin only
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                // Confirm deletion with the user before actually deleting
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Confirm Delete"),
                                      content: Text("Are you sure you want to delete this species?"),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          child: Text("Cancel"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        ElevatedButton(
                                          child: Text("Delete"),
                                          onPressed: () {
                                            _handleDeleteSpecies(speciesId);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
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
