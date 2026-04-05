class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String phone;
  final double balance;
  final String? avatar;
  final bool isVerified;
  final String kycStatus;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.balance,
    this.avatar,
    required this.isVerified,
    required this.kycStatus,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? '',
        firstName: json['first_name'] ?? '',
        lastName: json['last_name'] ?? '',
        fullName: json['full_name'] ??
            '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
        avatar: json['avatar'],
        isVerified: json['is_verified'] ?? false,
        kycStatus: json['kyc_status'] ?? 'pending',
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
      );

  UserModel copyWith({
    double? balance,
    String? avatar,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) {
    final fn = firstName ?? this.firstName;
    final ln = lastName ?? this.lastName;
    return UserModel(
      id: id,
      firstName: fn,
      lastName: ln,
      fullName: '$fn $ln',
      email: email ?? this.email,
      phone: phone ?? this.phone,
      balance: balance ?? this.balance,
      avatar: avatar ?? this.avatar,
      isVerified: isVerified,
      kycStatus: kycStatus,
      createdAt: createdAt,
    );
  }

  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
          .toUpperCase();
}
