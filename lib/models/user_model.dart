class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? token;
  final String parentAccountId;
  final String subscription;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.token,
    this.parentAccountId = '#977119044',
    this.subscription = 'Calley Personal',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '68626f9497757cb741f449b0',
      name: json['name']?.toString() ?? 'Swati S',
      email: json['email']?.toString() ?? 'swati@getcalley.com',
      phone: json['phone']?.toString() ?? json['mobile']?.toString() ?? '+91 977119044',
      token: json['token']?.toString() ?? 'calley_mock_token_jwt_xyz789',
      parentAccountId: json['parentAccountId']?.toString() ?? '#977119044',
      subscription: json['subscription']?.toString() ?? 'Calley Personal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'token': token,
      'parentAccountId': parentAccountId,
      'subscription': subscription,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? token,
    String? parentAccountId,
    String? subscription,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      token: token ?? this.token,
      parentAccountId: parentAccountId ?? this.parentAccountId,
      subscription: subscription ?? this.subscription,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, phone: $phone)';
  }
}
