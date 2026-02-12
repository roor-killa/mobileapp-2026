/// Modèle représentant un utilisateur
class User {
  final int id;
  final String name;
  final String email;
  final double balance;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.balance,
  });

  /// Factory pour créer un User depuis JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
    );
  }

  /// Convertir l'objet en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'balance': balance,
    };
  }
}
