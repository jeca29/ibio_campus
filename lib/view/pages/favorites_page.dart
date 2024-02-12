import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterlogin/core/constants/colors.dart';
import 'package:flutterlogin/view/pages/show_species_page.dart';

class FavoritesPage extends StatefulWidget {
  final String uid; // User ID

  FavoritesPage({required this.uid});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(widget.uid).collection('favorites').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No favorites found.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final favoriteSpeciesDoc = snapshot.data!.docs[index];
              final favoriteSpeciesData = favoriteSpeciesDoc.data() as Map<String, dynamic>;
              final speciesId = favoriteSpeciesDoc.id;

              return Container(
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
                    // Navigate to the SpeciesDetailsPage with the species data and ID
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SpeciesDetailsPage(
                          speciesData: favoriteSpeciesData,
                          speciesId: speciesId,
                          uid: widget.uid,
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(favoriteSpeciesData['name'] ?? 'N/A'),
                    subtitle: Text(favoriteSpeciesData['description'] ?? 'N/A'),
                    // Add more information to display as needed
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
