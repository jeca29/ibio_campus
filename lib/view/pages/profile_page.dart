import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterlogin/core/constants/colors.dart';
import 'package:flutterlogin/models/user_data.dart';

class ProfilePage extends StatefulWidget {
  final String uid; // Pass the UID of the user

  ProfilePage({required this.uid});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  UserData _userData = UserData(name: '', email: '', role: '');
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();

  @override
  void initState() {
    super.initState();
    print("######################");
    print(widget.uid);
    print("######################");
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    var snapshot = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
    if (snapshot.exists) {
      setState(() {
        _userData = UserData.fromMap(snapshot.data()!);
        name.text = _userData.name;
        email.text = _userData.email;
      });
    }
  }

  Future<void> _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).update(_userData.toMap());
      // Handle successful update (e.g., show a message)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
              controller: name,
              decoration: InputDecoration(labelText: 'Name'),
              onSaved: (value) => _userData.name = value!,
              // Add validation if needed
            ),
            TextFormField(
              controller: email,
              decoration: InputDecoration(labelText: 'Email'),
              onSaved: (value) => _userData.email = value!,
              // Add validation if needed
            ),
            // Add other fields
            SizedBox(
              height: 15,
            ),
            ElevatedButton(
              onPressed: _saveUserData,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
