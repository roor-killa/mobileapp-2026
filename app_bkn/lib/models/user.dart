class User {
  final String id;
  final String lastName;
  final String firstName;
  final String email;
  final String phone;
  final double bknBalance;
  final DateTime registeredAt;
  final String? avatar;
  final String verificationLevel;

  User({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.email,
    required this.phone,
    this.bknBalance = 1500.0,
    required this.registeredAt,
    this.avatar,
    this.verificationLevel = 'Niveau 1',
  });

  String get fullName => '$firstName $lastName';
  
  String get formattedRegisteredDate {
    return '${registeredAt.month}/${registeredAt.year}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lastName': lastName,
      'firstName': firstName,
      'email': email,
      'phone': phone,
      'bknBalance': bknBalance,
      'registeredAt': registeredAt.toIso8601String(),
      'avatar': avatar,
      'verificationLevel': verificationLevel,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      lastName: json['lastName'],
      firstName: json['firstName'],
      email: json['email'],
      phone: json['phone'],
      bknBalance: json['bknBalance']?.toDouble() ?? 0.0,
      registeredAt: DateTime.parse(json['registeredAt']),
      avatar: json['avatar'],
      verificationLevel: json['verificationLevel'] ?? 'Niveau 1',
    );
  }
}