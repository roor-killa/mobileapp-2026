/// Données de la carte virtuelle NodEX.
class UserCard {
  final String cardNumber;
  final String last4;
  final String expiry;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;
  final String pin;
  final String holderName;

  UserCard({
    required this.cardNumber,
    required this.last4,
    required this.expiry,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
    required this.pin,
    required this.holderName,
  });

  factory UserCard.fromJson(Map<String, dynamic> json) {
    return UserCard(
      cardNumber: json['cardNumber'] as String? ?? '',
      last4: json['last4'] as String? ?? '',
      expiry: json['expiry'] as String? ?? '',
      expiryMonth: json['expiryMonth'] as String? ?? '',
      expiryYear: json['expiryYear'] as String? ?? '',
      cvv: json['cvv'] as String? ?? '',
      pin: json['pin'] as String? ?? '',
      holderName: json['holderName'] as String? ?? 'TITULAIRE',
    );
  }

  /// Carte factice quand l’API est indisponible : garde l’aspect « vraie carte » dans l’UI.
  factory UserCard.preview({required String holderName}) {
    final h = holderName.trim().isNotEmpty ? holderName.trim() : 'NodEX';
    return UserCard(
      cardNumber: '4532 1488 0343 8842',
      last4: '8842',
      expiry: '12/29',
      expiryMonth: '12',
      expiryYear: '29',
      cvv: '•••',
      pin: '••••',
      holderName: h,
    );
  }
}
