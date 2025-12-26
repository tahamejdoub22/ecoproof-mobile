class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? avatar;
  final Map<String, dynamic>? additionalData;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.avatar,
    this.additionalData,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? json['username'],
      avatar: json['avatar'] ?? json['profilePicture'],
      additionalData: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
      ...?additionalData,
    };
  }
}

