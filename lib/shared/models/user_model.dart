class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String companyId;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.companyId,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      companyId: data['companyId'] ?? '',
    );
  }
}
