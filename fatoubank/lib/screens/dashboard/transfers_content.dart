import 'package:flutter/material.dart';
import 'package:fatoubank/utils/colors.dart';
import 'package:fatoubank/models/transaction.dart';
import 'package:fatoubank/models/transaction_type.dart';
import 'package:fatoubank/services/api_service.dart';

class TransfersContent extends StatefulWidget {
  final List<String> beneficiaries;
  final Function(Transaction) onTransferMade;

  const TransfersContent({
    Key? key,
    required this.beneficiaries,
    required this.onTransferMade,
  }) : super(key: key);

  @override
  State<TransfersContent> createState() => _TransfersContentState();
}

class _TransfersContentState extends State<TransfersContent> {
  final TextEditingController amountController = TextEditingController();
  String? selectedBeneficiary;
  String _transferType = 'Virement simple';
  final List<String> _transferTypes = ['Virement simple', 'Virement planifié', 'Virement international'];

  Widget _buildField(String label, TextEditingController ctrl, {IconData? icon, bool isNum = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: isNum ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, color: AppColors.primary, size: 20) : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.borderColor)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type de virement
          const Text('Type de virement', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _transferTypes.map((t) {
                final isSelected = t == _transferType;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _transferType = t),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderColor),
                        boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                      ),
                      child: Text(t, style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Bénéficiaire selector
          const Text('Bénéficiaire', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedBeneficiary,
                hint: const Text('Choisir un bénéficiaire', style: TextStyle(color: AppColors.textSecondary)),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                items: widget.beneficiaries.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedBeneficiary = value),
              ),
            ),
          ),

          const SizedBox(height: 20),

          _buildField('Montant (€)', amountController, icon: Icons.euro_outlined, isNum: true),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (selectedBeneficiary == null || amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez remplir tous les champs'), backgroundColor: Colors.orange),
                  );
                  return;
                }

                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                );

                try {
                  // Perform real transfer via API
                  await ApiService.makeTransfer(
                    recipientName: selectedBeneficiary!,
                    amount: amount,
                    description: 'Virement à $selectedBeneficiary',
                  );

                  if (!mounted) return;
                  Navigator.pop(context); // Close loading

                  // Show success dialog
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text('Virement confirmé ✓', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      content: Text('${amount.toStringAsFixed(2)} € envoyés à $selectedBeneficiary'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            
                            // Success local update
                            final newTx = Transaction(
                              name: 'Virement à $selectedBeneficiary',
                              amount: -amount,
                              date: "Aujourd'hui",
                              type: TransactionType.transfer,
                              icon: Icons.swap_horiz,
                            );
                            
                            widget.onTransferMade(newTx);

                            amountController.clear();
                            setState(() => selectedBeneficiary = null);
                          },
                          child: const Text('OK', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  Navigator.pop(context); // Close loading
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur : ${e.toString().replaceAll('Exception: ', '')}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
              ),
              child: const Text('ENVOYER MAINTENANT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
          ),

          const SizedBox(height: 32),

          // Recent beneficiaries
          const Text('Bénéficiaires récents', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          Row(
            children: widget.beneficiaries.map((name) {
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () => setState(() => selectedBeneficiary = name),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: selectedBeneficiary == name
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          name.substring(0, 1),
                          style: TextStyle(
                            color: selectedBeneficiary == name ? Colors.white : AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(name.split(' ')[0], style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }
}
