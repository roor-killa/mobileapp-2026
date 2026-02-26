class User {
  final int id;
  final String name;
  final String prenom;
  final String email;
  final String? telephone;
  final double solde;

  User({
    required this.id,
    required this.name,
    required this.prenom,
    required this.email,
    this.telephone,
    required this.solde,
  });

  // Cette fonction transforme le JSON reçu de Laravel en objet utilisable par Flutter
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      prenom: json['prenom'],
      email: json['email'],
      telephone: json['telephone'],
      // On convertit le solde de la DB en nombre décimal pour Flutter
      solde: double.parse(json['solde'].toString()),
    );
  }
}