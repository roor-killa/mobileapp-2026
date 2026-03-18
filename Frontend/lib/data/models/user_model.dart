class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String? phone;
  final int balance;
  final String balanceFormatted;
  final String? avatarUrl;
  final String status;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    this.phone,
    required this.balance,
    required this.balanceFormatted,
    this.avatarUrl,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:               json['id'] ?? '',
      firstName:        json['first_name'] ?? '',
      lastName:         json['last_name'] ?? '',
      fullName:         json['full_name'] ?? '',
      email:            json['email'] ?? '',
      phone:            json['phone'],
      balance:          json['balance'] ?? 0,
      balanceFormatted: json['balance_formatted'] ?? '0,00 €',
      avatarUrl:        json['avatar_url'],
      status:           json['status'] ?? 'active',
    );
  }

  /// Solde en euros (balance stockée en centimes)
  double get balanceEuros => balance / 100;
}

