import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutterlogin/core/constants/colors.dart';
import 'package:flutterlogin/data/api/firestore_helper.dart';
import 'package:flutterlogin/view/pages/select_location_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddFeedbackPage extends StatefulWidget {
  final String uid;

  const AddFeedbackPage({super.key, required this.uid}); // Pass the UID of the user

  @override
  _AddFeedbackPageState createState() => _AddFeedbackPageState();
}

class _AddFeedbackPageState extends State<AddFeedbackPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  LatLng location = const LatLng(0, 0);
  FirestoreHelper fh = FirestoreHelper();
  List<String> imageUrls = [];

  // Function to handle the form submission
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Create a map with species data
      final Map<String, dynamic> speciesData = {
        'uid': widget.uid,
        'title': _nameController.text,
        'description': _descriptionController.text,
        'location': [location.latitude, location.longitude],
        'images': imageUrls, // Add the image URLs to your Firestore data
      };

      try {
        // Add the species data to the Firestore collection
        await fh.createItem(speciesData, 'feedbacks'); // Replace 'species' with your collection path
        // Optionally, show a success message or navigate back to the previous page
        Navigator.pop(context);
      } catch (e) {
        // Handle any errors that occur during the creation process
        print('Error creating feedback: $e');
        // Optionally, show an error message to the user
      }
    }
  }

  String gen() {
    const String _chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    Random _rnd = Random();

    return String.fromCharCodes(Iterable.generate(13, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  // Function to select and upload images
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Upload the selected image to Firebase Storage
      final imageFile = File(pickedFile.path);
      final Reference storageRef = FirebaseStorage.instance.ref().child('feedback_images/' + gen());
      final UploadTask uploadTask = storageRef.putFile(imageFile);

      await uploadTask.whenComplete(() async {
        // Get the download URL of the uploaded image
        final String imageUrl = await storageRef.getDownloadURL();

        setState(() {
          // Add the image URL to the list of imageUrls
          imageUrls.add(imageUrl);
        });
      });
    }
  }

  void _removeImage(String imageUrl) {
    setState(() {
      imageUrls.remove(imageUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Feedback'),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                GestureDetector(
                  onTap: () async {
                    var res = await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SelectLocationPage(),
                    ));

                    if (res is LatLng) {
                      location = res;
                      _locationController.text = "${location.latitude.toString()} ${location.longitude.toString()}";
                    }
                  },
                  child: TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Select Location'),
                    enabled: false,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a location';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const SizedBox(
                  height: 15,
                ),
                Wrap(spacing: 1, runSpacing: 1, children: [
                  for (var imageUrl in imageUrls)
                    GestureDetector(
                      onTap: () => _removeImage(imageUrl), // Remove the image when tapped
                      child: Stack(
                        children: [
                          Image.network(
                            imageUrl,
                            width: (size.width - 35) / 3,
                            height: (size.width - 35) / 3,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Container(
                      width: (size.width - 35) / 3,
                      height: (size.width - 35) / 3,
                      color: mainColor,
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 45,
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Add Feedback'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
