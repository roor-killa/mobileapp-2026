import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api.dart';

class BankScreen extends StatefulWidget {
  const BankScreen({super.key});

  @override
  State<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends State<BankScreen> {
  bool _loading = true;

  double _balance = 0;
  List<dynamic> _txs = const [];
  List<dynamic> _bens = const [];

  // Filtres historique
  String _direction = "all"; // all | in | out
  String? _counterparty;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      final bal = await api.bankBalance();
      final txs = await api.bankTransactions(
        limit: 30,
        direction: _direction,
        fromDate: _fromDate,
        toDate: _toDate,
        counterparty: _counterparty,
      );
      final bens = await api.bankBeneficiaries();

      setState(() {
        _balance = (bal["balance_usd"] as num).toDouble();
        _txs = txs;
        _bens = bens;
      });
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addBeneficiary() async {
    final aliasCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    Timer? debounce;
    bool searching = false;
    List<Map<String, dynamic>> suggestions = [];

    void clearSuggestions(StateSetter setStateDialog) {
      setStateDialog(() => suggestions = []);
    }

    Future<void> runSearch(StateSetter setStateDialog, String q) async {
      final query = q.trim();
      if (query.length < 2) {
        clearSuggestions(setStateDialog);
        return;
      }

      debounce?.cancel();
      debounce = Timer(const Duration(milliseconds: 300), () async {
        setStateDialog(() => searching = true);
        try {
          final users = await api.searchUsers(query, limit: 8);

          // evite d'afficher les emails déjà en bénéficiaires
          final existing = _bens
              .map((b) => (b["email"] ?? "").toString().toLowerCase())
              .where((e) => e.isNotEmpty)
              .toSet();

          final filtered = users.where((u) {
            final email = (u["email"] ?? "").toString().toLowerCase();
            return email.isNotEmpty && !existing.contains(email);
          }).toList();

          setStateDialog(() => suggestions = filtered);
        } catch (_) {
          // silencieux : on ne casse pas le dialog si l'endpoint n'est pas dispo
          setStateDialog(() => suggestions = []);
        } finally {
          setStateDialog(() => searching = false);
        }
      });
    }

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Ajouter un bénéficiaire"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: aliasCtrl,
                    decoration: const InputDecoration(labelText: "Alias"),
                  ),
                  TextField(
                    controller: emailCtrl,
                    decoration: InputDecoration(
                      labelText: "Email (recherche intelligente)",
                      suffixIcon: searching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                          : (emailCtrl.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    emailCtrl.clear();
                                    clearSuggestions(setStateDialog);
                                  },
                                )),
                    ),
                    onChanged: (v) => runSearch(setStateDialog, v),
                  ),

                  if (suggestions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 220),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12)),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: suggestions.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final u = suggestions[i];
                          final email = (u["email"] ?? "").toString();
                          final fn = (u["first_name"] ?? "").toString();
                          final ln = (u["last_name"] ?? "").toString();
                          final name = ("$fn $ln").trim();

                          return ListTile(
                            dense: true,
                            title: Text(name.isEmpty ? email : "$name • $email"),
                            onTap: () {
                              emailCtrl.text = email;
                              // auto-alias si vide
                              if (aliasCtrl.text.trim().isEmpty) {
                                aliasCtrl.text = name.isNotEmpty ? name : email.split("@").first;
                              }
                              clearSuggestions(setStateDialog);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    debounce?.cancel();
                    Navigator.pop(context);
                  },
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final email = emailCtrl.text.trim().toLowerCase();
                      final alias = aliasCtrl.text.trim();

                      if (email.isEmpty || !email.contains("@")) {
                        _snack("Email invalide.");
                        return;
                      }

                      await api.bankAddBeneficiary(alias: alias, email: email);

                      if (context.mounted) Navigator.pop(context);
                      await _refresh();
                    } catch (e) {
                      _snack(e.toString());
                    }
                  },
                  child: const Text("Ajouter"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteBeneficiary(int id) async {
    try {
      await api.bankDeleteBeneficiary(id);
      await _refresh();
    } catch (e) {
      _snack(e.toString());
    }
  }

  Future<void> _transferTo(String email) async {
    final amountCtrl = TextEditingController(text: "50");
    final noteCtrl = TextEditingController(text: "Virement");

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Virement à $email"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: "Montant USD")),
              TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: "Note")),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
            ElevatedButton(
              onPressed: () async {
                try {
                  final amt = double.parse(amountCtrl.text.replaceAll(",", "."));
                  await api.bankTransfer(toEmail: email, usdAmount: amt, note: noteCtrl.text.trim());
                  if (context.mounted) Navigator.pop(context);
                  await _refresh();
                } catch (e) {
                  _snack(e.toString());
                }
              },
              child: const Text("Envoyer"),
            )
          ],
        );
      },
    );
  }

  
  
  Widget _dirChip(BuildContext context, {required String label, required String value}) {
    final selected = _direction == value;
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) {
        setState(() => _direction = value);
        _refresh();
      },
    );
  }

Future<void> _openFilters() async {
    String direction = _direction;
    String? counterparty = _counterparty;
    DateTime? fromD = _fromDate;
    DateTime? toD = _toDate;

    final cs = Theme.of(context).colorScheme;

    await showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            Future<void> pickFrom() async {
              final d = await showDatePicker(
                context: ctx,
                initialDate: fromD ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 3650)),
              );
              if (d != null) setLocal(() => fromD = DateTime(d.year, d.month, d.day));
            }

            Future<void> pickTo() async {
              final d = await showDatePicker(
                context: ctx,
                initialDate: toD ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 3650)),
              );
              if (d != null) setLocal(() => toD = DateTime(d.year, d.month, d.day));
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 14,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 14,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Filtres", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: direction,
                    items: const [
                      DropdownMenuItem(value: "all", child: Text("Tout")),
                      DropdownMenuItem(value: "in", child: Text("Entrants")),
                      DropdownMenuItem(value: "out", child: Text("Sortants")),
                    ],
                    onChanged: (v) => setLocal(() => direction = v ?? "all"),
                    decoration: const InputDecoration(labelText: "Direction", border: OutlineInputBorder()),
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: counterparty,
                    items: [
                      const DropdownMenuItem(value: null, child: Text("— Aucun")),
                      ..._bens.map((b) {
                        final email = (b["email"] ?? "").toString();
                        final alias = (b["alias"] ?? "").toString();
                        return DropdownMenuItem(
                          value: email,
                          child: Text(alias.isEmpty ? email : "$alias • $email"),
                        );
                      }).toList(),
                    ],
                    onChanged: (v) => setLocal(() => counterparty = v),
                    decoration: const InputDecoration(labelText: "Bénéficiaire", border: OutlineInputBorder()),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: pickFrom,
                          icon: const Icon(Icons.date_range_rounded),
                          label: Text(fromD == null
                              ? "Date début"
                              : "${fromD!.year}-${fromD!.month.toString().padLeft(2, '0')}-${fromD!.day.toString().padLeft(2, '0')}"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: pickTo,
                          icon: const Icon(Icons.date_range_rounded),
                          label: Text(toD == null
                              ? "Date fin"
                              : "${toD!.year}-${toD!.month.toString().padLeft(2, '0')}-${toD!.day.toString().padLeft(2, '0')}"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _direction = direction;
                          _counterparty = counterparty;
                          _fromDate = fromD;
                          _toDate = toD;
                        });
                        Navigator.pop(ctx);
                        _refresh();
                      },
                      child: const Text("Appliquer", style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        _direction = "all";
                        _counterparty = null;
                        _fromDate = null;
                        _toDate = null;
                      });
                      Navigator.pop(ctx);
                      _refresh();
                    },
                    child: const Text("Réinitialiser"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

@override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Banque"),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _VirtualCard(balance: _balance),
            const SizedBox(height: 14),

            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 10),

            Row(
              children: [
                const Expanded(child: Text("Bénéficiaires", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
                IconButton(onPressed: _addBeneficiary, icon: const Icon(Icons.person_add_alt_1_rounded)),
              ],
            ),

            if (_bens.isEmpty)
              Text("Aucun bénéficiaire.", style: TextStyle(color: cs.onSurface.withOpacity(0.65)))
            else
              ..._bens.map((b) {
                final id = (b["id"] as num).toInt();
                final alias = (b["alias"] ?? "").toString();
                final email = (b["email"] ?? "").toString();

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surface.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.onSurface.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: cs.primary.withOpacity(0.25),
                        child: Text(alias.isNotEmpty ? alias[0].toUpperCase() : "?"),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(alias, style: const TextStyle(fontWeight: FontWeight.w900)),
                            Text(email, style: TextStyle(color: cs.onSurface.withOpacity(0.65))),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: "Virement",
                        onPressed: () => _transferTo(email),
                        icon: const Icon(Icons.send_rounded),
                      ),
                      IconButton(
                        tooltip: "Supprimer",
                        onPressed: () => _deleteBeneficiary(id),
                        icon: Icon(Icons.delete_rounded, color: cs.error),
                      ),
                    ],
                  ),
                );
              }).toList(),

            const SizedBox(height: 12),
            const Text("Historique", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 10),

            if (_txs.isEmpty)
              Text("Aucune transaction.", style: TextStyle(color: cs.onSurface.withOpacity(0.65)))
            else
              ..._txs.take(12).map((t) {
                final kind = (t["kind"] ?? "").toString();
                final note = (t["note"] ?? "").toString();
                final cp = (t["counterparty_email"] ?? "").toString();
                final amt = (t["amount_usd"] as num).toDouble();
                final isOut = amt < 0;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: isOut ? cs.errorContainer : cs.primaryContainer,
                    child: Icon(isOut ? Icons.call_made_rounded : Icons.call_received_rounded),
                  ),
                  title: Text(kind, style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text([
                    if (cp.isNotEmpty) cp,
                    if (note.isNotEmpty) note else "—",
                  ].join(" • ")),
                  trailing: Text(
                    (isOut ? "-" : "+") + "\$${amt.abs().toStringAsFixed(2)}",
                    style: TextStyle(fontWeight: FontWeight.w900, color: isOut ? cs.error : cs.primary),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}

class _VirtualCard extends StatelessWidget {
  final double balance;
  const _VirtualCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary.withOpacity(0.26), cs.secondary.withOpacity(0.14), const Color(0xFF070B10)],
        ),
        border: Border.all(color: cs.primary.withOpacity(0.25)),
        boxShadow: [BoxShadow(color: cs.primary.withOpacity(0.18), blurRadius: 28, spreadRadius: 1)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Carte virtuelle", style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Text("\$${balance.toStringAsFixed(2)}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text("**** **** **** 4821", style: TextStyle(letterSpacing: 2, color: cs.onSurface.withOpacity(0.7))),
          const SizedBox(height: 6),
          Text("EXP 08/29  •  CVV ***", style: TextStyle(color: cs.onSurface.withOpacity(0.65))),
        ],
      ),
    );
  }
}