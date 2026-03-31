import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MoyennesClasseScreen extends StatefulWidget {
  const MoyennesClasseScreen({super.key});

  @override
  State<MoyennesClasseScreen> createState() => _MoyennesClasseScreenState();
}

class _MoyennesClasseScreenState extends State<MoyennesClasseScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _classes = [];
  Map<String, dynamic>? _classeSelectionnee;
  List<Map<String, dynamic>> _moyennes = [];
  bool _isLoading = true;
  bool _isLoadingMoyennes = false;

  @override
  void initState() {
    super.initState();
    _chargerClasses();
  }

  Future<void> _chargerClasses() async {
    try {
      final classes = await _apiService.getClasses();
      setState(() {
        _classes = classes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _chargerMoyennes(int classeId) async {
    setState(() => _isLoadingMoyennes = true);
    try {
      final moyennes = await _apiService.getMoyennesClasse(classeId);
      setState(() {
        _moyennes = moyennes;
        _isLoadingMoyennes = false;
      });
    } catch (e) {
      setState(() => _isLoadingMoyennes = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        title: const Text(
          'Moyennes par classe',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sélection de la classe
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<Map<String, dynamic>>(
                      value: _classeSelectionnee,
                      decoration: InputDecoration(
                        labelText: 'Sélectionner une classe',
                        prefixIcon: const Icon(Icons.class_,
                            color: Color(0xFF6C63FF)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: _classes.map((classe) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: classe,
                          child: Text(
                              '${classe['nom']} (${classe['etudiants_count']} étudiants)'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _classeSelectionnee = val);
                        if (val != null) _chargerMoyennes(val['id']);
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (_isLoadingMoyennes)
                    const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF6C63FF)),
                    )
                  else if (_moyennes.isNotEmpty) ...[
                    Text(
                      'Moyennes de ${_classeSelectionnee!['nom']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _moyennes.length,
                        itemBuilder: (context, index) {
                          final m = _moyennes[index];
                          final moyenne = m['moyenne_classe'] as double?;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: moyenne == null
                                          ? Colors.grey.withOpacity(0.1)
                                          : moyenne >= 10
                                              ? const Color(0xFF6C63FF)
                                                  .withOpacity(0.1)
                                              : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.book,
                                      color: moyenne == null
                                          ? Colors.grey
                                          : moyenne >= 10
                                              ? const Color(0xFF6C63FF)
                                              : Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m['matiere'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          '${m['nombre_etudiants']} étudiant(s)',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: moyenne == null
                                            ? [Colors.grey, Colors.grey]
                                            : moyenne >= 10
                                                ? [
                                                    const Color(0xFF6C63FF),
                                                    const Color(0xFF3B82F6)
                                                  ]
                                                : [
                                                    const Color(0xFFFF6B6B),
                                                    const Color(0xFFEE0979)
                                                  ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      moyenne != null
                                          ? '${moyenne.toStringAsFixed(2)}/20'
                                          : '-/20',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}