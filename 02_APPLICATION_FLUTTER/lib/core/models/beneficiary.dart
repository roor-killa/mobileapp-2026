class Beneficiary {
  final String id;
  final String name;
  final String iban;
  final String bank;
  final String? avatarColor;
  bool isFavorite;

  Beneficiary({
    required this.id,
    required this.name,
    required this.iban,
    required this.bank,
    this.avatarColor,
    this.isFavorite = false,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  get displayIban =>
      iban.replaceRange(4, iban.length - 4, '*' * (iban.length - 8));
}
