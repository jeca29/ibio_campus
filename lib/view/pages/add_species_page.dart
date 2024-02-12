import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterlogin/core/constants/colors.dart';
import 'package:flutterlogin/data/api/firestore_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math';

class AddSpeciesPage extends StatefulWidget {
  final String uid;

  const AddSpeciesPage({super.key, required this.uid}); // Pass the UID of the user

  @override
  _AddSpeciesPageState createState() => _AddSpeciesPageState();
}

class _AddSpeciesPageState extends State<AddSpeciesPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _shortDescriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _familyController = TextEditingController(); // New controller for family field
  final TextEditingController _locationWordsController = TextEditingController(); // New controller for family field
  LatLng location = const LatLng(0, 0);
  FirestoreHelper fh = FirestoreHelper();
  List<String> imageUrls = [];

  String _selectedCategory = 'Flora'; // Initial selection for category
  String _selectedHabitat = 'Aerial'; // Initial selection for habitat

  // Function to handle the form submission
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      var coordinates = _locationController.text.split(" ");

      // Create a map with species data
      final Map<String, dynamic> speciesData = {
        'name': _nameController.text,
        'family': _familyController.text,
        'description': _descriptionController.text,
        'short_description': _shortDescriptionController.text,
        'location_words': _locationWordsController.text,
        'category': _selectedCategory,
        'habitat': _selectedHabitat,
        // 'location': [location.latitude, location.longitude],
        'location': coordinates,
        'images': imageUrls, // Add the image URLs to your Firestore data
      };

      try {
        // Add the species data to the Firestore collection
        await fh.createItem(speciesData, 'species'); // Replace 'species' with your collection path
        // Optionally, show a success message or navigate back to the previous page
        Navigator.pop(context);
      } catch (e) {
        // Handle any errors that occur during the creation process
        print('Error creating species: $e');
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
      final Reference storageRef = FirebaseStorage.instance.ref().child('species_images/' + gen());
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
        title: const Text('Add Specie'),
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
                // Dropdown for category (Flora, Fauna)
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                  items: <String>['Flora', 'Fauna'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),

                // Dropdown for habitat (Aerial, Aquatic, Terrestrial)
                DropdownButtonFormField<String>(
                  value: _selectedHabitat,
                  decoration: const InputDecoration(labelText: 'Habitat'),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedHabitat = newValue!;
                    });
                  },
                  items: <String>['Aerial', 'Aquatic', 'Terrestrial'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _familyController,
                  decoration: const InputDecoration(labelText: 'Family'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a family name';
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
                TextFormField(
                  controller: _shortDescriptionController,
                  decoration: const InputDecoration(labelText: 'Short Description'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a short description';
                    }
                    return null;
                  },
                ),
                // GestureDetector(
                //   onTap: () async {
                //     var res = await Navigator.of(context).push(MaterialPageRoute(
                //       builder: (context) => const SelectLocationPage(),
                //     ));

                //     if (res is LatLng) {
                //       location = res;
                //       _locationController.text = "${location.latitude.toString()} ${location.longitude.toString()}";
                //     }
                //   },
                //   child:
                TextFormField(
                  controller: _locationWordsController,
                  decoration: const InputDecoration(labelText: 'Location in words'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a location';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Select Location'),
                  // enabled: false,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a location';
                    } else {
                      var is_valid = value.contains(" ");
                      var is_valid2 = value.split(" ");

                      if (!is_valid && is_valid2.length == 2) {
                        return 'Please enter a valid coordinates';
                      }
                    }
                    return null;
                  },
                ),
                // ),
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
                  child: const Text('Add Species'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
