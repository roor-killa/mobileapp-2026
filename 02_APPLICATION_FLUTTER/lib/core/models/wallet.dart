class CoinWallet {
  int totalCoins;
  int adsWatchedToday;
  DateTime lastWheelDate;
  int scratchTicketsToday;
  DateTime lastBtcPredictionTime;
  double balanceEuros;

  CoinWallet({
    this.totalCoins = 0,
    this.adsWatchedToday = 0,
    DateTime? lastWheelDate,
    this.scratchTicketsToday = 0,
    DateTime? lastBtcPredictionTime,
    this.balanceEuros = 0,
  }) : lastWheelDate = lastWheelDate ?? DateTime.now(),
       lastBtcPredictionTime = lastBtcPredictionTime ?? DateTime.now();

  bool get canWatchAd => adsWatchedToday < 10;
  bool get canUseScratchTicket => scratchTicketsToday < 3;
  bool get canSpinWheel {
    final today = DateTime.now();
    return lastWheelDate.year != today.year ||
        lastWheelDate.month != today.month ||
        lastWheelDate.day != today.day;
  }

  bool get canPredictBtc {
    return DateTime.now().difference(lastBtcPredictionTime).inMinutes >= 60;
  }

  int get coinsToEuros => (totalCoins / 1000).toInt();
}
