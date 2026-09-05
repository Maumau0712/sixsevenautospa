class UserModel {
  final int? id;
  final String name;
  final String email;
  final String phone;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  factory UserModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
    );
  }
}