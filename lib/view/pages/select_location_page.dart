import 'package:flutter/material.dart';
import 'package:flutterlogin/core/constants/colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectLocationPage extends StatefulWidget {
  const SelectLocationPage({super.key});

  @override
  _SelectLocationPageState createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static final LatLng _schoolLatLng = LatLng(8.485855134178290, 124.65666145370070);

  final Set<Marker> _markers = {};

  static final CameraPosition _initialPosition = CameraPosition(
    target: _schoolLatLng,
    zoom: 17,
  );

  void _onMapTapped(LatLng position) {
    print("#####################");
    print(position);
    print("#####################");

    Navigator.pop(context, position);

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
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: mainColor,
          foregroundColor: Colors.white,
          title: const Text("Select Location"),
          // automaticallyImplyLeading: false,
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
                onTap: _onMapTapped,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
