import 'package:flutter/material.dart';
import 'package:flutterlogin/core/constants/colors.dart';

class ZoomedImagePage extends StatelessWidget {
  final String title;
  final String imageUrl;

  ZoomedImagePage({required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Hero(
          tag: imageUrl, // Use the same tag as in SpeciesDetailsPage
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
