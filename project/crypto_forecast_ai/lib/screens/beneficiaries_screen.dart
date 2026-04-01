import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api.dart';

class BeneficiariesScreen extends StatefulWidget {
  final bool selectMode; // true => "utiliser" renvoie l'email au BankScreen
  const BeneficiariesScreen({super.key, required this.selectMode});

  @override
  State<BeneficiariesScreen> createState() => _BeneficiariesScreenState();
}

class _BeneficiariesScreenState extends State<BeneficiariesScreen> {
  final _q = TextEditingController();
  Timer? _debounce;

  bool _loading = true;
  List<dynamic> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _q.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  void _onQueryChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _load);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final rows = await api.bankBeneficiaries(q: _q.text.trim().isEmpty ? null : _q.text.trim());
      if (!mounted) return;
      setState(() => _items = rows);
    } catch (e) {
      _snack("Erreur: $e");
      if (!mounted) return;
      setState(() => _items = const []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(int id) async {
    try {
      await api.bankDeleteBeneficiary(id);
      await _load();
      _snack("Supprimé.");
    } catch (e) {
      _snack("Suppression impossible: $e");
    }
  }

  Future<void> _openAdd() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _AddBeneficiarySheet(),
    );
    if (added == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectMode ? "Choisir un bénéficiaire" : "Bénéficiaires"),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
          IconButton(onPressed: _openAdd, icon: const Icon(Icons.person_add_alt_1_rounded)),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              TextField(
                controller: _q,
                onChanged: _onQueryChanged,
                decoration: InputDecoration(
                  hintText: "Recherche alias / email / nom",
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    onPressed: () {
                      _q.clear();
                      _load();
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : (_items.isEmpty
                        ? Center(
                            child: Text(
                              "Aucun bénéficiaire.\nAppuie sur + pour ajouter.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: cs.onSurface.withOpacity(0.7), fontWeight: FontWeight.w700),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, i) {
                              final b = _items[i] as Map<String, dynamic>;
                              final id = (b["id"] as num).toInt();
                              final alias = (b["alias"] ?? "").toString();
                              final email = (b["email"] ?? "").toString();
                              final name = (b["name"] ?? "").toString();

                              return Material(
                                color: cs.surface.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(16),
                                child: ListTile(
                                  title: Text(alias.isEmpty ? (name.isEmpty ? email : name) : alias,
                                      style: const TextStyle(fontWeight: FontWeight.w900)),
                                  subtitle: Text(email),
                                  onTap: widget.selectMode ? () => Navigator.of(context).pop(email) : null,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (widget.selectMode)
                                        IconButton(
                                          tooltip: "Utiliser",
                                          onPressed: () => Navigator.of(context).pop(email),
                                          icon: const Icon(Icons.check_circle_rounded),
                                        ),
                                      IconButton(
                                        tooltip: "Supprimer",
                                        onPressed: () => _delete(id),
                                        icon: Icon(Icons.delete_rounded, color: cs.error),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddBeneficiarySheet extends StatefulWidget {
  const _AddBeneficiarySheet();

  @override
  State<_AddBeneficiarySheet> createState() => _AddBeneficiarySheetState();
}

class _AddBeneficiarySheetState extends State<_AddBeneficiarySheet> {
  final _alias = TextEditingController();
  final _email = TextEditingController();
  final _search = TextEditingController();

  bool _saving = false;
  bool _loadingUsers = false;
  List<dynamic> _users = const [];
  Timer? _debounce;

  @override
  void dispose() {
    _alias.dispose();
    _email.dispose();
    _search.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  void _searchUsers(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () => _doSearch(v));
  }

  Future<void> _doSearch(String v) async {
    final q = v.trim();
    if (q.length < 2) {
      setState(() => _users = const []);
      return;
    }

    setState(() => _loadingUsers = true);
    try {
      final rows = await api.searchUsers(q);
      if (!mounted) return;
      setState(() => _users = rows.take(20).toList());
    } catch (_) {
      if (!mounted) return;
      setState(() => _users = const []);
    } finally {
      if (mounted) setState(() => _loadingUsers = false);
    }
  }

  Future<void> _save() async {
    final alias = _alias.text.trim();
    final email = _email.text.trim();

    if (email.isEmpty || !email.contains("@")) return _snack("Email invalide.");
    if (alias.isEmpty) return _snack("Alias requis.");

    setState(() => _saving = true);
    try {
      await api.bankAddBeneficiary(alias: alias, email: email);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      _snack("Ajout impossible: $e");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Ajouter un bénéficiaire", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 10),

          TextField(
            controller: _search,
            onChanged: _searchUsers,
            decoration: InputDecoration(
              labelText: "Recherche utilisateur (saisie intelligente)",
              hintText: "nom / email",
              prefixIcon: const Icon(Icons.manage_search_rounded),
              suffixIcon: _loadingUsers ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              ) : null,
            ),
          ),

          if (_users.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              constraints: const BoxConstraints(maxHeight: 170),
              decoration: BoxDecoration(
                color: cs.surface.withOpacity(0.55),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.onSurface.withOpacity(0.08)),
              ),
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, i) {
                  final u = _users[i] as Map<String, dynamic>;
                  final email = (u["email"] ?? "").toString();
                  final name = "${u["first_name"] ?? ""} ${u["last_name"] ?? ""}".trim();
                  return ListTile(
                    dense: true,
                    title: Text(name.isEmpty ? email : name, style: const TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: Text(email),
                    onTap: () {
                      _email.text = email;
                      if (_alias.text.trim().isEmpty) _alias.text = name.isEmpty ? email : name;
                      setState(() => _users = const []);
                    },
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 10),
          TextField(
            controller: _alias,
            decoration: const InputDecoration(labelText: "Alias", prefixIcon: Icon(Icons.badge_rounded)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _email,
            decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.alternate_email_rounded)),
          ),
          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text("Ajouter", style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}
