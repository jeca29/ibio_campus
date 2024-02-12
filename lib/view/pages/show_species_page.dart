import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterlogin/core/constants/colors.dart';
import 'package:flutterlogin/view/pages/zoom_in_image_page.dart';

class SpeciesDetailsPage extends StatefulWidget {
  final Map<String, dynamic> speciesData;
  final String speciesId; // Add species ID here
  final String uid; // Add species ID here

  SpeciesDetailsPage({required this.speciesData, required this.speciesId, required this.uid});

  @override
  _SpeciesDetailsPageState createState() => _SpeciesDetailsPageState();
}

class _SpeciesDetailsPageState extends State<SpeciesDetailsPage> {
  final Set<String> favoriteSpeciesIds = {};
  int speciesCount = 0;

  Future<void> _toggleFavorite(BuildContext context, String userId) async {
    final userFavoritesRef = FirebaseFirestore.instance.collection('users').doc(userId).collection('favorites');
    final speciesRef = userFavoritesRef.doc(widget.speciesId);

    final isFavorite = await speciesRef.get().then((snapshot) => snapshot.exists);

    if (isFavorite) {
      await speciesRef.delete();
      setState(() {
        favoriteSpeciesIds.remove(widget.speciesId);
      });
    } else {
      await speciesRef.set(widget.speciesData);
      setState(() {
        favoriteSpeciesIds.add(widget.speciesId);
      });
    }
  }

  void _fetchSpeciesCount() async {
    String speciesName = widget.speciesData['name'] ?? '';
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('species').where('name', isEqualTo: speciesName).get();
    setState(() {
      speciesCount = querySnapshot.docs.length;
    });
  }

  @override
  void initState() {
    super.initState();

    // Check if the species is a favorite when opening the page
    final userId = widget.uid; // Get the user's ID after authentication
    FirebaseFirestore.instance.collection('users').doc(userId).collection('favorites').doc(widget.speciesId).get().then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          favoriteSpeciesIds.add(widget.speciesId);
        });
      }
    });

    _fetchSpeciesCount();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> imageUrls = List<String>.from(widget.speciesData['images'] ?? []);
    final String featuredImageUrl = imageUrls.isNotEmpty ? imageUrls[0] : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.speciesData['name'] ?? 'Species Details'),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              favoriteSpeciesIds.contains(widget.speciesId) ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: () async {
              final userId = widget.uid;
              await _toggleFavorite(context, userId);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (featuredImageUrl.isNotEmpty)
              GestureDetector(
                onTap: () {
                  // Implement code to enlarge the featured image here
                },
                child: Image.network(
                  featuredImageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            Text('Name: ${widget.speciesData['name'] ?? 'N/A'}'),
            Text('Category: ${widget.speciesData['category'] ?? 'N/A'}'), // Display family
            Text('Habitat: ${widget.speciesData['habitat'] ?? 'N/A'}'), // Display family
            Text('Family: ${widget.speciesData['family'] ?? 'N/A'}'), // Display family
            Text('Species Count: $speciesCount'), // Display species count
            Text('Description: ${widget.speciesData['description'] ?? 'N/A'}'),
            Text('Location: ${widget.speciesData['location_words'] ?? 'N/A'}'),
            SizedBox(height: 16),
            Text(
              'Gallery:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (imageUrls.isNotEmpty)
              Container(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    final imageUrl = imageUrls[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return ZoomedImagePage(
                              imageUrl: imageUrl,
                              title: '${widget.speciesData['name'] ?? 'N/A'}',
                            );
                          },
                        ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Hero(
                          tag: imageUrl,
                          child: Image.network(
                            imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
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
