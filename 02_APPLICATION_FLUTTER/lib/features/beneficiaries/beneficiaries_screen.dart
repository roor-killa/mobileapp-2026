import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/models/beneficiary.dart';

class BeneficiariesScreen extends StatefulWidget {
  const BeneficiariesScreen({Key? key}) : super(key: key);

  @override
  State<BeneficiariesScreen> createState() => _BeneficiariesScreenState();
}

class _BeneficiariesScreenState extends State<BeneficiariesScreen> {
  List<Beneficiary> _beneficiaries = [
    Beneficiary(
      id: '1',
      name: 'Marie Dupont',
      iban: 'FR1420041010050500013M02606',
      bank: 'Société Générale',
      avatarColor: '#7E57C2',
      isFavorite: true,
    ),
    Beneficiary(
      id: '2',
      name: 'Pierre Bernard',
      iban: 'FR1410097000004340006M47261',
      bank: 'BNP Paribas',
      avatarColor: '#00BCD4',
    ),
    Beneficiary(
      id: '3',
      name: 'Sophie Martin',
      iban: 'FR1608007000015018223346301',
      bank: 'Crédit Agricole',
      avatarColor: '#26A69A',
      isFavorite: true,
    ),
  ];

  late List<Beneficiary> _filteredBeneficiaries;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredBeneficiaries = _beneficiaries;
  }

  void _filterBeneficiaries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBeneficiaries = _beneficiaries;
      } else {
        _filteredBeneficiaries = _beneficiaries
            .where(
              (b) =>
                  b.name.toLowerCase().contains(query.toLowerCase()) ||
                  b.iban.contains(query) ||
                  b.bank.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _toggleFavorite(int index) {
    final beneficiary = _beneficiaries.firstWhere(
      (b) => b.id == _filteredBeneficiaries[index].id,
    );
    setState(() => beneficiary.isFavorite = !beneficiary.isFavorite);
  }

  void _deleteBeneficiary(int index) {
    final beneficiary = _filteredBeneficiaries[index];
    setState(() => _beneficiaries.removeWhere((b) => b.id == beneficiary.id));
    _filterBeneficiaries(_searchController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${beneficiary.name} supprimé'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showBeneficiaryForm({Beneficiary? beneficiary}) {
    final isEditing = beneficiary != null;
    final nameController = TextEditingController(text: beneficiary?.name ?? '');
    final ibanController = TextEditingController(text: beneficiary?.iban ?? '');
    String selectedBank = beneficiary?.bank ?? 'Société Générale';

    showModalBottomSheet(
      context: context,
      backgroundColor: NEGsColors.bgWhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Modifier bénéficiaire' : 'Ajouter bénéficiaire',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: NEGsColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Nom complet',
                  filled: true,
                  fillColor: NEGsColors.bgSecondaryLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: NEGsColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: NEGsColors.borderLight),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ibanController,
                decoration: InputDecoration(
                  hintText: 'IBAN (ex: FR14...)',
                  filled: true,
                  fillColor: NEGsColors.bgSecondaryLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: NEGsColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: NEGsColors.borderLight),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedBank,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: NEGsColors.bgSecondaryLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: NEGsColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: NEGsColors.borderLight),
                  ),
                ),
                items:
                    [
                      'Société Générale',
                      'BNP Paribas',
                      'Crédit Agricole',
                      'Banque de France',
                      'Caisse d\'Épargne',
                      'La Banque Postale',
                    ].map((bank) {
                      return DropdownMenuItem(value: bank, child: Text(bank));
                    }).toList(),
                onChanged: (value) => setState(() => selectedBank = value!),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: NEGsGradients.mainGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isEmpty ||
                          ibanController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Remplissez tous les champs'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (isEditing) {
                        final index = _beneficiaries.indexWhere(
                          (b) => b.id == beneficiary.id,
                        );
                        _beneficiaries[index] = Beneficiary(
                          id: beneficiary.id,
                          name: nameController.text,
                          iban: ibanController.text,
                          bank: selectedBank,
                          isFavorite: beneficiary.isFavorite,
                        );
                      } else {
                        _beneficiaries.add(
                          Beneficiary(
                            id: DateTime.now().toString(),
                            name: nameController.text,
                            iban: ibanController.text,
                            bank: selectedBank,
                          ),
                        );
                      }

                      _filterBeneficiaries(_searchController.text);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      isEditing ? 'Modifier' : 'Ajouter',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: NEGsGradients.bgGradient),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bénéficiaires',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: NEGsColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: _filterBeneficiaries,
                    decoration: InputDecoration(
                      hintText: 'Chercher...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: NEGsColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: NEGsColors.bgWhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: NEGsColors.borderLight,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: NEGsColors.borderLight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _filteredBeneficiaries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 48,
                            color: NEGsColors.textTertiary,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Aucun bénéficiaire',
                            style: TextStyle(
                              fontSize: 16,
                              color: NEGsColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _filteredBeneficiaries.length,
                      itemBuilder: (context, index) {
                        final beneficiary = _filteredBeneficiaries[index];
                        return Dismissible(
                          key: Key(beneficiary.id),
                          onDismissed: (_) => _deleteBeneficiary(index),
                          background: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: GestureDetector(
                            onLongPress: () =>
                                _showBeneficiaryForm(beneficiary: beneficiary),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: NEGsColors.bgWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: NEGsColors.borderLight,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(
                                            int.parse(
                                                  '0xFF${beneficiary.avatarColor?.substring(1) ?? '7E57C2'}',
                                                ) ??
                                                0xFF7E57C2,
                                          ),
                                          Color(
                                            int.parse(
                                                  '0xFF${beneficiary.avatarColor?.substring(1) ?? '7E57C2'}',
                                                ) ??
                                                0xFF7E57C2,
                                          ),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        beneficiary.initials,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          beneficiary.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: NEGsColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${beneficiary.displayIban} • ${beneficiary.bank}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: NEGsColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      beneficiary.isFavorite
                                          ? Icons.star
                                          : Icons.star_outline,
                                      color: beneficiary.isFavorite
                                          ? NEGsColors.accentGreen
                                          : NEGsColors.textTertiary,
                                      size: 24,
                                    ),
                                    onPressed: () => _toggleFavorite(index),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: NEGsGradients.mainGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: () => _showBeneficiaryForm(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Ajouter un bénéficiaire',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
