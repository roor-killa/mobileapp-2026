class Wallet {
  double _solde;
  final String devise;
  final double tauxConversion;

  Wallet({
    required double solde,
    this.devise = 'BKN',
    this.tauxConversion = 1.0,
  }) : _solde = solde;

  double get solde => _solde;
  double get enEuros => _solde * tauxConversion;

  bool crediter(double montant) {
    if (montant <= 0) return false;
    _solde += montant;
    return true;
  }

  bool debiter(double montant) {
    if (montant <= 0) return false;
    if (_solde < montant) return false;
    _solde -= montant;
    return true;
  }

  bool peutDebiter(double montant) => _solde >= montant;

  Wallet copyWith({double? solde}) {
    return Wallet(
      solde: solde ?? _solde,
      devise: devise,
      tauxConversion: tauxConversion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'solde': _solde,
      'devise': devise,
      'tauxConversion': tauxConversion,
    };
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      solde: json['solde']?.toDouble() ?? 0.0,
      devise: json['devise'] ?? 'BKN',
      tauxConversion: json['tauxConversion']?.toDouble() ?? 1.0,
    );
  }
}