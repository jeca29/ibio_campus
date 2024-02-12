import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterlogin/core/constants/colors.dart';
import 'package:flutterlogin/data/api/firestore_helper.dart';
import 'package:flutterlogin/models/user_data.dart';
import 'package:flutterlogin/view/pages/zoom_in_image_page.dart';

var fh = FirestoreHelper();

class FeedbackDetailsPage extends StatefulWidget {
  final Map<String, dynamic> speciesData;
  final String speciesId; // Add species ID here
  final String uid; // Add species ID here

  FeedbackDetailsPage({required this.speciesData, required this.speciesId, required this.uid});

  @override
  _FeedbackDetailsPageState createState() => _FeedbackDetailsPageState();
}

class _FeedbackDetailsPageState extends State<FeedbackDetailsPage> {
  final Set<String> favoriteSpeciesIds = {};
  UserData _userData = UserData(name: '', email: '', role: '');

  Future<void> _loadUserData() async {
    var snapshot = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();

    if (snapshot.exists) {
      setState(() {
        _userData = UserData.fromMap(snapshot.data()!);
      });
    }
  }

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> imageUrls = List<String>.from(widget.speciesData['images'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.speciesData['name'] ?? 'Feedback Details'),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // if (featuredImageUrl.isNotEmpty)
            //   GestureDetector(
            //     onTap: () {
            //       // Implement code to enlarge the featured image here
            //     },
            //     child: Image.network(
            //       featuredImageUrl,
            //       width: double.infinity,
            //       height: 200,
            //       fit: BoxFit.cover,
            //     ),
            //   ),
            Text('Title: ${widget.speciesData['title'] ?? 'N/A'}'),
            Text('Description: ${widget.speciesData['description'] ?? 'N/A'}'),
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
                              title: '${widget.speciesData['title'] ?? 'N/A'}',
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

            if (_userData.role == "admin")
              Container(
                padding: const EdgeInsets.only(
                  top: 25,
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    var is_approved = widget.speciesData['status'] ?? false;
                    await fh.updateItem(widget.speciesData['id'], {"status": !is_approved}, "feedbacks");
                    Navigator.pop(context);
                  },
                  child: Text(widget.speciesData['status'] != true ? 'Approve' : 'Disapprove'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
