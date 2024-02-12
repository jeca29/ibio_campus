import 'package:cloud_firestore/cloud_firestore.dart';

class Species {
  final String category;
  final String habitat;

  Species({required this.category, required this.habitat});

  factory Species.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Species(
      category: data['category'] ?? '',
      habitat: data['habitat'] ?? '',
    );
  }
}
