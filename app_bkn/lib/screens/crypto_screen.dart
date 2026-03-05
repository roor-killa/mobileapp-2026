import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../providers/crypto_provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../models/crypto.dart';

class CryptoScreen extends StatefulWidget {
  const CryptoScreen({super.key});

  @override
  State<CryptoScreen> createState() => _CryptoScreenState();
}

class _CryptoScreenState extends State<CryptoScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CryptoCurrency? _selectedCrypto;
  final _amountController = TextEditingController();
  final _walletController = TextEditingController();
  bool _isBuyMode = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _walletController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    final cryptoProvider = context.read<CryptoProvider>();
    await cryptoProvider.loadPrices();
    
    if (!mounted) return;
    
    if (ApiService.currentUserId != null) {
      await cryptoProvider.loadBalances(ApiService.currentUserId!);
      if (!mounted) return;
      await cryptoProvider.loadHistory(ApiService.currentUserId!);
    }
    
    if (mounted && CryptoCurrency.supportedCryptos.isNotEmpty) {
      setState(() {
        _selectedCrypto = CryptoCurrency.supportedCryptos.first;
      });
    }
  }

  Future<void> _handleTransaction() async {
    if (_selectedCrypto == null || _amountController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      if (mounted) {
        _showError('Montant invalide');
        setState(() => _isLoading = false);
      }
      return;
    }
    
    final cryptoProvider = context.read<CryptoProvider>();
    final userProvider = context.read<UserProvider>();
    Map<String, dynamic> result;
    
    if (_isBuyMode) {
      // Vérifier solde BKN
      if (amount > userProvider.solde) {
        if (mounted) {
          _showError('Solde BKN insuffisant (${userProvider.solde.toStringAsFixed(0)} BKN disponible)');
          setState(() => _isLoading = false);
        }
        return;
      }
      
      result = await cryptoProvider.buyCrypto(
        userId: ApiService.currentUserId!,
        crypto: _selectedCrypto!.id,
        amountBKN: amount,
        walletAddress: _walletController.text.isNotEmpty ? _walletController.text : null,
      );
    } else {
      // Vérifier solde crypto
      final balance = cryptoProvider.getBalance(_selectedCrypto!.id);
      final cryptoAmount = cryptoProvider.estimateCrypto(_selectedCrypto!.id, amount);
      
      if (cryptoAmount > balance) {
        if (mounted) {
          _showError('Solde ${_selectedCrypto!.symbol} insuffisant (${balance.toStringAsFixed(8)} disponible)');
          setState(() => _isLoading = false);
        }
        return;
      }
      
      result = await cryptoProvider.sellCrypto(
        userId: ApiService.currentUserId!,
        crypto: _selectedCrypto!.id,
        amountCrypto: cryptoAmount,
        walletAddress: _walletController.text.isNotEmpty ? _walletController.text : null,
      );
    }
    
    if (!mounted) return;
    
    setState(() => _isLoading = false);
    
    if (result['success'] == true) {
      await context.read<UserProvider>().refreshSolde();
      if (!mounted) return;
      _showSuccessDialog(result);
      _amountController.clear();
      _walletController.clear();
    } else {
      _showError(result['error'] ?? 'Transaction échouée');
    }
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.secondaryGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Transaction réussie !', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(result['crypto_amount'] ?? 0).toStringAsFixed(8)} ${_selectedCrypto!.symbol}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
            ),
            const SizedBox(height: 8),
            Text(
              _isBuyMode 
                  ? 'achetés avec ${(result['bkn_spent'] ?? 0).toStringAsFixed(0)} BKN'
                  : 'vendus pour ${(result['bkn_received'] ?? 0).toStringAsFixed(0)} BKN',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text('Prix au moment de la transaction', 
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    '\$${(result['price'] ?? 0).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ $message'),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _refreshData() async {
    if (ApiService.currentUserId == null) return;
    
    await context.read<CryptoProvider>().refreshAll(ApiService.currentUserId!);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Données actualisées'),
          backgroundColor: AppTheme.secondaryGreen,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto BKN'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryBlue,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'TRADER'),
            Tab(text: 'PORTEFEUILLE'),
            Tab(text: 'HISTORIQUE'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildTradeView(),
            _buildPortfolioView(),
            _buildHistoryView(),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeView() {
    return Consumer2<CryptoProvider, UserProvider>(
      builder: (context, cryptoProvider, userProvider, child) {
        if (cryptoProvider.prices.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.primaryBlue),
                SizedBox(height: 16),
                Text('Chargement des prix...', style: TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sélecteur de crypto
              const Text('Sélectionner une crypto', 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))
                .animate().fadeIn(duration: 300.ms),
              
              const SizedBox(height: 12),
              
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: CryptoCurrency.supportedCryptos.length,
                  itemBuilder: (context, index) {
                    final crypto = CryptoCurrency.supportedCryptos[index];
                    final isSelected = _selectedCrypto?.id == crypto.id;
                    final currentPrice = cryptoProvider.prices[crypto.id] ?? crypto.price;
                    
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCrypto = crypto),
                      child: Container(
                        width: 90,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: isSelected 
                              ? const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [AppTheme.primaryBlue, AppTheme.primaryPink],
                                )
                              : null,
                          color: isSelected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : Colors.grey.shade200,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              crypto.symbol,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${currentPrice.toStringAsFixed(currentPrice < 1 ? 4 : 2)}',
                              style: TextStyle(
                                color: isSelected ? Colors.white70 : AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Mode Achat/Vente
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isBuyMode = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: _isBuyMode ? AppTheme.successGradient : null,
                            color: _isBuyMode ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              'ACHETER',
                              style: TextStyle(
                                color: _isBuyMode ? Colors.white : AppTheme.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isBuyMode = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: !_isBuyMode 
                                ? const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFFFF6B6B), Color(0xFFFF3B30)],
                                  )
                                : null,
                            color: !_isBuyMode ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              'VENDRE',
                              style: TextStyle(
                                color: !_isBuyMode ? Colors.white : AppTheme.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Carte de conversion
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Montant BKN
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Montant en BKN',
                        prefixIcon: const Icon(Icons.euro, color: AppTheme.primaryBlue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Icône de conversion
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.swap_vert, color: AppTheme.primaryBlue, size: 32),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Estimation crypto
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Vous recevrez :',
                            style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                          ),
                          if (_selectedCrypto != null)
                            Expanded(
                              child: Text(
                                textAlign: TextAlign.right,
                                '${cryptoProvider.estimateCrypto(
                                  _selectedCrypto!.id,
                                  double.tryParse(_amountController.text) ?? 0
                                ).toStringAsFixed(8)} ${_selectedCrypto!.symbol}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    if (!_isBuyMode) ...[
                      const SizedBox(height: 16),
                      
                      // Solde crypto disponible
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Solde disponible :', 
                              style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                            if (_selectedCrypto != null)
                              Text(
                                '${cryptoProvider.getBalance(_selectedCrypto!.id).toStringAsFixed(8)} ${_selectedCrypto!.symbol}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                              ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Adresse wallet (optionnel)
                    TextField(
                      controller: _walletController,
                      decoration: InputDecoration(
                        labelText: 'Adresse wallet (optionnel)',
                        hintText: 'Ex: 0x... ou bc1...',
                        prefixIcon: const Icon(Icons.wallet, color: AppTheme.primaryBlue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Solde BKN
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Solde BKN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    Text(
                      '${userProvider.solde.toStringAsFixed(0)} BKN',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Bouton de transaction
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  gradient: _isBuyMode 
                      ? AppTheme.successGradient 
                      : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF3B30)],
                        ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (_isBuyMode ? AppTheme.secondaryGreen : const Color(0xFFFF3B30)).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _isBuyMode ? 'ACHETER CRYPTO' : 'VENDRE CRYPTO',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPortfolioView() {
    return Consumer<CryptoProvider>(
      builder: (context, cryptoProvider, child) {
        final balances = cryptoProvider.balances;
        final hasBalance = balances.values.any((balance) => balance > 0);
        final totalValue = cryptoProvider.totalPortfolioValueInBKN;
        
        if (cryptoProvider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.primaryBlue),
                SizedBox(height: 16),
                Text('Chargement du portefeuille...'),
              ],
            ),
          );
        }
        
        if (!hasBalance) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet, size: 100, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text(
                  'Portefeuille crypto vide',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Achetez vos premières cryptos dans l\'onglet "Trader"',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    _tabController.animateTo(0);
                  },
                  icon: const Icon(Icons.trending_up),
                  label: const Text('Aller trader'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }
        
        return Column(
          children: [
            // Valeur totale du portefeuille
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primaryBlue, AppTheme.accentPurple],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Valeur totale du portefeuille',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${totalValue.toStringAsFixed(2)} BKN',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '≈ ${totalValue.toStringAsFixed(2)} €',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            
            // Liste des cryptos possédées
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: CryptoCurrency.supportedCryptos.length,
                itemBuilder: (context, index) {
                  final crypto = CryptoCurrency.supportedCryptos[index];
                  final balance = cryptoProvider.getBalance(crypto.id);
                  
                  if (balance <= 0.00000001) return const SizedBox.shrink();
                  
                  final valueInBKN = cryptoProvider.estimateBKN(crypto.id, balance);
                  final currentPrice = cryptoProvider.prices[crypto.id] ?? crypto.price;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Logo/Icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                currentPrice > crypto.price 
                                    ? AppTheme.secondaryGreen 
                                    : AppTheme.errorRed,
                                (currentPrice > crypto.price 
                                    ? AppTheme.secondaryGreen 
                                    : AppTheme.errorRed).withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              crypto.symbol[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Infos crypto
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                crypto.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${balance.toStringAsFixed(8)} ${crypto.symbol}',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Valeur
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${valueInBKN.toStringAsFixed(2)} BKN',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  currentPrice > crypto.price 
                                      ? Icons.arrow_upward 
                                      : Icons.arrow_downward,
                                  color: currentPrice > crypto.price 
                                      ? AppTheme.secondaryGreen 
                                      : AppTheme.errorRed,
                                  size: 12,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '\$${currentPrice.toStringAsFixed(currentPrice < 1 ? 4 : 2)}',
                                  style: TextStyle(
                                    color: currentPrice > crypto.price 
                                        ? AppTheme.secondaryGreen 
                                        : AppTheme.errorRed,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryView() {
    return Consumer<CryptoProvider>(
      builder: (context, cryptoProvider, child) {
        if (cryptoProvider.isLoading && cryptoProvider.transactions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.primaryBlue),
                SizedBox(height: 16),
                Text('Chargement de l\'historique...'),
              ],
            ),
          );
        }
        
        if (cryptoProvider.transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 100, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text(
                  'Aucune transaction crypto',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Vos achats et ventes de cryptos apparaîtront ici',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cryptoProvider.transactions.length,
          itemBuilder: (context, index) {
            final t = cryptoProvider.transactions[index];
            final isBuy = t.type == 'buy';
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isBuy ? AppTheme.secondaryGreen : AppTheme.errorRed).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isBuy ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isBuy ? AppTheme.secondaryGreen : AppTheme.errorRed,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              isBuy ? 'Achat' : 'Vente',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                t.crypto.toUpperCase(),
                                style: const TextStyle(
                                  color: AppTheme.primaryBlue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${t.amountCrypto.toStringAsFixed(8)} @ \$${t.priceAtTransaction.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${t.amountBKN.toStringAsFixed(0)} BKN',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(t.createdAt),
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return "Aujourd'hui ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } else if (difference.inDays == 1) {
      return "Hier ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } else if (difference.inDays < 7) {
      return "Il y a ${difference.inDays} jours";
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}