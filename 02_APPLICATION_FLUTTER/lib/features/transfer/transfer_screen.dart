import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/glass_container.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({Key? key}) : super(key: key);

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final recipientController = TextEditingController();
  final amountController = TextEditingController();
  String _qrData = 'NEGs-Banking-${DateTime.now().millisecondsSinceEpoch}';
  bool _isQRGenerated = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    recipientController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _generateQR() {
    setState(() {
      _qrData =
          'NEGs|${recipientController.text}|${amountController.text}|${DateTime.now().millisecondsSinceEpoch}';
      _isQRGenerated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: NEGsGradients.bgGradient),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: GradientText('Transfers', style: NEGsStyles.heading2),
            ),
            TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: NEGsGradients.mainGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: NEGsColors.textSecondary,
              tabs: const [
                Tab(text: 'Send Money'),
                Tab(text: 'QR Payment'),
                Tab(text: 'History'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSendMoneyTab(),
                  _buildQRPaymentTab(),
                  _buildHistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendMoneyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Recipient Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: NEGsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: recipientController,
            label: 'Recipient Name',
            icon: Icons.person,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: amountController,
            label: 'Amount (€)',
            icon: Icons.euro,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          const Text(
            'Bank Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: NEGsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: TextEditingController()
              ..text = 'IBAN: FR76 XXXX XXXX XXXX',
            label: 'IBAN',
            icon: Icons.credit_card,
            readOnly: true,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Container(
              decoration: BoxDecoration(
                gradient: NEGsGradients.mainGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transfer Sent Successfully!'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Send Money',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRPaymentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Quick Payment QR Code',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: NEGsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: recipientController,
            label: 'Recipient Name',
            icon: Icons.person,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: amountController,
            label: 'Amount (€)',
            icon: Icons.euro,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          if (_isQRGenerated) ...[
            GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Center(
                      child: Text(
                        _qrData,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '📱 Scan QR Code',
                    style: TextStyle(
                      color: NEGsColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Container(
              decoration: BoxDecoration(
                gradient: NEGsGradients.mainGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ElevatedButton(
                onPressed: _generateQR,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Generate QR Code',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildHistoryItem('John Doe', '€250.00', '2024-04-01', true),
          _buildHistoryItem('Jane Smith', '€500.00', '2024-03-31', true),
          _buildHistoryItem('Mike Johnson', '€100.00', '2024-03-30', false),
          _buildHistoryItem('Sarah Williams', '€75.50', '2024-03-29', true),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: NEGsColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            style: const TextStyle(color: NEGsColors.textPrimary),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: NEGsColors.primaryViolet),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    String name,
    String amount,
    String date,
    bool isOutgoing,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isOutgoing
                    ? Colors.red.withOpacity(0.15)
                    : Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isOutgoing ? Icons.arrow_upward : Icons.arrow_downward,
                color: isOutgoing ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: NEGsColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    date,
                    style: const TextStyle(
                      color: NEGsColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isOutgoing ? '-' : '+'}$amount',
              style: TextStyle(
                color: isOutgoing ? Colors.red : Colors.green,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
