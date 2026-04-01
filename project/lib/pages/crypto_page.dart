import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CryptoPage extends StatefulWidget {
  const CryptoPage({super.key});

  @override
  State<CryptoPage> createState() => _CryptoPageState();
}

class _CryptoPageState extends State<CryptoPage> {
  List<dynamic> assets = [];
  bool isLoading = true;
  String errorMessage = '';

  final TextEditingController buyAmountController = TextEditingController();
  final TextEditingController sellQuantityController = TextEditingController();

  String selectedBuySymbol = 'BTC';
  String selectedSellSymbol = 'BTC';

  @override
  void initState() {
    super.initState();
    loadAssets();
  }

  Future<void> loadAssets() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final data = await ApiService.getCryptoAssets();

      setState(() {
        assets = data;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> buyCrypto() async {
    final double? amount = double.tryParse(
      buyAmountController.text.replaceAll(',', '.'),
    );

    if (amount == null || amount <= 0) {
      setState(() {
        errorMessage = 'Veuillez entrer un montant valide pour l’achat.';
      });
      return;
    }

    try {
      setState(() {
        errorMessage = '';
      });

      await ApiService.buyCrypto(
        symbol: selectedBuySymbol,
        amount: amount,
      );

      buyAmountController.clear();
      await loadAssets();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Achat crypto effectué avec succès'),
        ),
      );
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> sellCrypto() async {
    final double? quantity = double.tryParse(
      sellQuantityController.text.replaceAll(',', '.'),
    );

    if (quantity == null || quantity <= 0) {
      setState(() {
        errorMessage = 'Veuillez entrer une quantité valide pour la vente.';
      });
      return;
    }

    try {
      setState(() {
        errorMessage = '';
      });

      await ApiService.sellCrypto(
        symbol: selectedSellSymbol,
        quantity: quantity,
      );

      sellQuantityController.clear();
      await loadAssets();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vente crypto effectuée avec succès'),
        ),
      );
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  void dispose() {
    buyAmountController.dispose();
    sellQuantityController.dispose();
    super.dispose();
  }

  Widget buildAssetCard(dynamic asset) {
    final symbol = asset['symbol'] ?? '';
    final quantity = double.tryParse(asset['quantity'].toString()) ?? 0.0;
    final averageBuyPrice =
        double.tryParse(asset['average_buy_price'].toString()) ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.orange.shade100,
            child: Text(
              symbol,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symbol,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Quantité : ${quantity.toStringAsFixed(8)}'),
                Text('Prix moyen : ${averageBuyPrice.toStringAsFixed(2)} €'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBuySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acheter une crypto',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: selectedBuySymbol,
            decoration: const InputDecoration(
              labelText: 'Crypto',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'BTC', child: Text('BTC')),
              DropdownMenuItem(value: 'ETH', child: Text('ETH')),
              DropdownMenuItem(value: 'SOL', child: Text('SOL')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedBuySymbol = value;
                });
              }
            },
          ),
          const SizedBox(height: 14),
          TextField(
            controller: buyAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Montant en euros',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.euro),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: buyCrypto,
              icon: const Icon(Icons.add),
              label: const Text('Acheter'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSellSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vendre une crypto',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: selectedSellSymbol,
            decoration: const InputDecoration(
              labelText: 'Crypto',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'BTC', child: Text('BTC')),
              DropdownMenuItem(value: 'ETH', child: Text('ETH')),
              DropdownMenuItem(value: 'SOL', child: Text('SOL')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedSellSymbol = value;
                });
              }
            },
          ),
          const SizedBox(height: 14),
          TextField(
            controller: sellQuantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Quantité à vendre',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: sellCrypto,
              icon: const Icon(Icons.sell),
              label: const Text('Vendre'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Portefeuille Crypto'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadAssets,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    buildBuySection(),
                    const SizedBox(height: 16),
                    buildSellSection(),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Mes cryptos',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (assets.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          'Aucune crypto détenue pour le moment.',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    else
                      ...assets.map(buildAssetCard),
                  ],
                ),
              ),
            ),
    );
  }
}