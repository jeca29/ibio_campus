class UserData {
  String name;
  String email;
  String role;
  // Add other fields as needed

  UserData({required this.name, required this.email, required this.role});

  factory UserData.fromMap(Map<String, dynamic> data) {
    return UserData(
      name: data['name'],
      email: data['email'],
      role: data['role'],
      // Initialize other fields
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      // Convert other fields to map
    };
  }
}
