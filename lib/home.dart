import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterlogin/core/constants/colors.dart';
import 'package:flutterlogin/data/api/firestore_helper.dart';
import 'package:flutterlogin/models/user_data.dart';
import 'package:flutterlogin/view/pages/favorites_page.dart';
import 'package:flutterlogin/view/pages/feedback_page.dart';
import 'package:flutterlogin/view/pages/monitoring_page.dart';
import 'package:flutterlogin/view/pages/monitoring_page2.dart';
import 'package:flutterlogin/view/pages/profile_page.dart';
import 'package:flutterlogin/view/pages/show_species_page.dart';
import 'package:flutterlogin/view/pages/species_page.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutterlogin/data/api/api.dart';
import 'package:flutterlogin/router/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  final User user;
  const Home({super.key, required this.user});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static const LatLng _schoolLatLng = LatLng(8.485855134178290, 124.65666145370070);
  UserData _userData = UserData(name: '', email: '', role: '');
  FirestoreHelper fh = FirestoreHelper();
  GoogleMapController? _controller;

  Set<Marker> _markers = {};

  static final CameraPosition _initialPosition = CameraPosition(
    target: _schoolLatLng,
    zoom: 17,
  );

  Future<void> _loadUserData() async {
    var snapshot = await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).get();

    if (snapshot.exists) {
      setState(() {
        _userData = UserData.fromMap(snapshot.data()!);
      });
    }
  }

  double ctd(dynamic value) {
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    } else {
      return 0.0; // Default value for non-convertible types
    }
  }

  Future<void> _loadSpeciesMarkers() async {
    _markers = {};
    try {
      final speciesList = await fh.readItemsWithAttributesMap('species', {}); // Assuming you have a method in FirestoreHelper to fetch all species

      for (final speciesData in speciesList) {
        final speciesName = speciesData['name'] ?? 'Unknown';
        final speciesDescription = speciesData['short_description'] ?? 'No description';
        final location = speciesData['location'] as List<dynamic>?;

        print(location);

        if (location != null && location.length >= 2) {
          final latitude = ctd(location[0]);
          final longitude = ctd(location[1]);

          final marker = Marker(
            markerId: MarkerId(speciesData['id']), // Assuming your Firestore document has an 'id' field
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(
              title: speciesName,
              snippet: speciesDescription,
            ),
            onTap: () {
              // Navigate to SpeciesDetailsPage when the marker is tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SpeciesDetailsPage(
                    speciesData: speciesData,
                    speciesId: speciesData['id'],
                    uid: widget.user.uid,
                  ),
                ),
              );
            },
          );

          setState(() {
            _markers.add(marker);
          });
        }
      }
    } catch (e) {
      print('Error loading species data: $e');
    }
  }

  void _onMapTapped(LatLng position) {
    print("#####################");
    print(position);
    print("#####################");
    // setState(() {
    //   _markers.add(
    //     Marker(
    //       markerId: MarkerId(position.toString()),
    //       position: position,
    //     ),
    //   );
    // });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUserData();
    _loadSpeciesMarkers(); // Load species markers when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        title: const Text("IBIO Campus"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer(); // Open the drawer
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/ustp.jpg'), // Replace with your image asset or network image
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(), // Keep it empty if you only want to show the image
            ),
            ListTile(
              leading: const Icon(Icons.account_circle), // Icon for the profile
              title: const Text('Profile'),
              onTap: () async {
                await Get.to(ProfilePage(uid: widget.user.uid));
                _loadSpeciesMarkers();
              },
            ),

            // if (_userData.role == "admin")
            ListTile(
              leading: const Icon(Icons.settings_applications_rounded), // Icon for the profile
              title: const Text('Inventory'),
              onTap: () async {
                await Get.to(SpeciesPage(uid: widget.user.uid, role: _userData.role));
                _loadSpeciesMarkers();
              },
            ),
            // if (_userData.role == "admin")
            ListTile(
              leading: const Icon(Icons.monitor), // Icon for the profile
              title: const Text('Monitoring'),
              onTap: () async {
                // await Get.to(MonitoringPage(uid: widget.user.uid));
                await Get.to(MonitoringPage2());
                _loadSpeciesMarkers();
              },
            ),
            if (_userData.role != "admin")
              ListTile(
                leading: const Icon(Icons.favorite), // Icon for the profile
                title: const Text('Favorites'),
                onTap: () async {
                  await Get.to(FavoritesPage(uid: widget.user.uid));
                },
              ),
            ListTile(
              leading: const Icon(Icons.feedback_rounded), // Icon for the profile
              title: const Text('Feedback'),
              onTap: () async {
                await Get.to(FeedbackPage(uid: widget.user.uid));
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red), // Icon for the logout, colored red
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onTap: () async {
                await Get.find<ApiClient>().logout();
                Get.toNamed(AppRoutes.login);
              },
            ),
            // Add more ListTile items here
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              mapType: MapType.terrain,
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                setState(() {
                  _controller = controller;
                });
                // Show the info window of a marker when the map loads
                if (_controller != null && _markers.isNotEmpty) {
                  _controller!.showMarkerInfoWindow(_markers.first.markerId);
                }
              },
              onTap: _onMapTapped,
            ),
          ),
        ],
      ),
    );
  }
}
