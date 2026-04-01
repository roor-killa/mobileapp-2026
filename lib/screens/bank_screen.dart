import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/api.dart';

class BankScreen extends StatefulWidget {
  const BankScreen({super.key});

  @override
  State<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends State<BankScreen> with TickerProviderStateMixin {
  bool _loading = true;
  bool _sending = false;

  double _balance = 0.0;
  DateTime? _updatedAt;
  List<dynamic> _txs = const [];

  // ✅ beneficiaries cache
  List<Map<String, dynamic>> _beneficiaries = const [];

  // ✅ suggestions state
  Timer? _debounce;
  bool _searchingUsers = false;
  List<Map<String, dynamic>> _suggestions = const [];

  final _toCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _refresh();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _pulseCtrl.dispose();
    _toCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      final bal = await api.bankBalance();
      final txs = await api.bankTransactions(limit: 30);

      // ✅ load beneficiaries too
      final bens = await api.bankBeneficiaries();

      final b = (bal["balance_usd"] as num?)?.toDouble() ?? 0.0;
      final up = bal["updated_at"]?.toString();

      setState(() {
        _balance = b;
        _updatedAt = up != null ? DateTime.tryParse(up) : null;
        _txs = txs;
        _beneficiaries = bens;
      });
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onToChanged(String v) {
    final q = v.trim().toLowerCase();

    // suggestions from beneficiaries (instant)
    final fromBen = q.isEmpty
        ? <Map<String, dynamic>>[]
        : _beneficiaries.where((b) {
            final email = (b["email"] ?? "").toString().toLowerCase();
            final alias = (b["alias"] ?? "").toString().toLowerCase();
            final fn = (b["first_name"] ?? "").toString().toLowerCase();
            final ln = (b["last_name"] ?? "").toString().toLowerCase();
            return email.contains(q) || alias.contains(q) || fn.contains(q) || ln.contains(q);
          }).take(6).toList();

    setState(() {
      _suggestions = fromBen;
    });

    // remote search users (debounce)
    _debounce?.cancel();
    if (q.length < 2) return;

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      setState(() => _searchingUsers = true);

      try {
        final users = await api.searchUsers(q, limit: 8);

        // filter out emails already in beneficiaries to avoid duplicates
        final existingEmails = _beneficiaries
            .map((b) => (b["email"] ?? "").toString().toLowerCase())
            .toSet();

        final extra = users.where((u) {
          final email = (u["email"] ?? "").toString().toLowerCase();
          return email.isNotEmpty && !existingEmails.contains(email);
        }).toList();

        // merge: beneficiaries first, then extra users
        final merged = <Map<String, dynamic>>[
          ...fromBen.map((b) => {"_type": "beneficiary", ...b}),
          ...extra.map((u) => {"_type": "user", ...u}),
        ];

        if (!mounted) return;
        setState(() => _suggestions = merged);
      } catch (_) {
        // silent fail (ne bloque pas)
      } finally {
        if (!mounted) return;
        setState(() => _searchingUsers = false);
      }
    });
  }

  void _pickSuggestion(Map<String, dynamic> s) {
    final email = (s["email"] ?? "").toString();
    if (email.isEmpty) return;

    _toCtrl.text = email;
    setState(() => _suggestions = []);
  }

  Future<void> _sendTransfer() async {
    final to = _toCtrl.text.trim();
    final amt = double.tryParse(_amountCtrl.text.replaceAll(",", ".")) ?? 0.0;
    final note = _noteCtrl.text.trim();

    if (to.isEmpty || !to.contains("@")) {
      _showError("Email destinataire invalide.");
      return;
    }
    if (amt <= 0) {
      _showError("Montant invalide.");
      return;
    }

    setState(() => _sending = true);
    try {
      final res = await api.bankTransfer(toEmail: to, usdAmount: amt, note: note);
      final msg = res["message"]?.toString() ?? "Virement envoyé.";

      _toCtrl.clear();
      _amountCtrl.clear();
      _noteCtrl.clear();
      setState(() => _suggestions = []);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
        );
      }

      await _refresh();
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  String _money(double v) => "\$${v.toStringAsFixed(2)}";

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final bg = cs.surfaceContainerLowest;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
            children: [
              _Header(cs: cs),
              const SizedBox(height: 14),

              _GlassCard(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Compte courant",
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(0.75),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _loading
                            ? _BalanceSkeleton(cs: cs, pulse: _pulseCtrl)
                            : TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: _balance),
                                duration: const Duration(milliseconds: 650),
                                curve: Curves.easeOutCubic,
                                builder: (context, val, _) {
                                  return Text(
                                    _money(val),
                                    style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                      color: cs.onSurface,
                                      letterSpacing: -0.6,
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _updatedAt == null
                            ? "Synchronisation…"
                            : "Mis à jour : ${_updatedAt!.toLocal().toString().split('.').first}",
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(0.55),
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              _GlassCard(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Virement",
                        style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _NeoField(
                        controller: _toCtrl,
                        label: "Email du bénéficiaire",
                        hint: "ex: b@test.com",
                        icon: Icons.alternate_email_rounded,
                        onChanged: _onToChanged,
                        suffix: _searchingUsers
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                              )
                            : null,
                      ),

                      // ✅ Suggestions box
                      if (_suggestions.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 220),
                          decoration: BoxDecoration(
                            color: surface.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: cs.onSurface.withOpacity(0.08)),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _suggestions.length,
                            separatorBuilder: (_, __) => Divider(height: 1, color: cs.onSurface.withOpacity(0.08)),
                            itemBuilder: (_, i) {
                              final s = _suggestions[i];
                              final email = (s["email"] ?? "").toString();
                              final alias = (s["alias"] ?? "").toString();
                              final fn = (s["first_name"] ?? "").toString();
                              final ln = (s["last_name"] ?? "").toString();
                              final name = ("$fn $ln").trim();
                              final label = alias.isNotEmpty ? alias : (name.isNotEmpty ? name : "Compte");

                              return ListTile(
                                dense: true,
                                title: Text("$label • $email", style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w800)),
                                onTap: () => _pickSuggestion(s),
                              );
                            },
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _NeoField(
                              controller: _amountCtrl,
                              label: "Montant (USD)",
                              hint: "ex: 50",
                              keyboardType: TextInputType.number,
                              icon: Icons.payments_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _NeoField(
                              controller: _noteCtrl,
                              label: "Note",
                              hint: "optionnel",
                              icon: Icons.notes_rounded,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _sending ? null : _sendTransfer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: _sending
                                ? const SizedBox(
                                    key: ValueKey("loading"),
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2.4),
                                  )
                                : const Text(
                                    key: ValueKey("txt"),
                                    "Envoyer",
                                    style: TextStyle(fontWeight: FontWeight.w900),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      Text(
                        "Démo : ce virement bouge ton solde USD entre utilisateurs.",
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(0.55),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Historique",
                      style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ),
                  IconButton(
                    onPressed: _refresh,
                    icon: Icon(Icons.refresh_rounded, color: cs.onSurface.withOpacity(0.8)),
                  )
                ],
              ),
              const SizedBox(height: 6),

              _GlassCard(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: _loading
                      ? _TxSkeleton(cs: cs, pulse: _pulseCtrl)
                      : (_txs.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(14),
                              child: Text(
                                "Aucune transaction pour le moment.",
                                style: TextStyle(
                                  color: cs.onSurface.withOpacity(0.65),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : Column(
                              children: _txs.take(12).map((t) {
                                final kind = (t["kind"] ?? "").toString();
                                final note = (t["note"] ?? "").toString();
                                final amount = (t["amount_usd"] as num?)?.toDouble() ?? 0.0;
                                final created = (t["created_at"] ?? "").toString();
                                final ref = (t["ref"] ?? "").toString();

                                final isOut = amount < 0;
                                final chipColor = isOut ? cs.errorContainer : cs.primaryContainer;
                                final chipText = isOut ? cs.onErrorContainer : cs.onPrimaryContainer;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                                  decoration: BoxDecoration(
                                    color: surface.withOpacity(0.55),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: cs.onSurface.withOpacity(0.08)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(14),
                                          color: chipColor,
                                        ),
                                        child: Icon(
                                          isOut ? Icons.call_made_rounded : Icons.call_received_rounded,
                                          color: chipText,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(kind, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w900)),
                                            const SizedBox(height: 2),
                                            Text(
                                              note.isEmpty ? (ref.isEmpty ? "—" : ref) : note,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: cs.onSurface.withOpacity(0.65),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12.5,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              created.replaceFirst("T", " ").split(".").first,
                                              style: TextStyle(
                                                color: cs.onSurface.withOpacity(0.5),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        (isOut ? "-" : "+") + _money(amount.abs()),
                                        style: TextStyle(
                                          color: isOut ? cs.error : cs.primary,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ColorScheme cs;
  const _Header({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NeonDot(cs: cs),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Banque",
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                "Solde • virements • historique",
                style: TextStyle(
                  color: cs.onSurface.withOpacity(0.65),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NeonDot extends StatelessWidget {
  final ColorScheme cs;
  const _NeonDot({required this.cs});

  @override
  Widget build(BuildContext context) {
    final neon = cs.primary;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            neon.withOpacity(0.95),
            cs.secondary.withOpacity(0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: neon.withOpacity(0.35),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(Icons.account_balance_rounded, color: cs.onPrimary),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surface.withOpacity(0.62),
            cs.surface.withOpacity(0.35),
          ],
        ),
        border: Border.all(color: cs.onSurface.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _NeoField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;

  const _NeoField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.onChanged,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(
        color: cs.onSurface,
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        filled: true,
        fillColor: cs.surface.withOpacity(0.55),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.onSurface.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.onSurface.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.primary.withOpacity(0.75), width: 1.6),
        ),
      ),
    );
  }
}

class _BalanceSkeleton extends StatelessWidget {
  final ColorScheme cs;
  final AnimationController pulse;
  const _BalanceSkeleton({required this.cs, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 0.9).animate(
        CurvedAnimation(parent: pulse, curve: Curves.easeInOut),
      ),
      child: Container(
        height: 38,
        width: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: cs.onSurface.withOpacity(0.12),
        ),
      ),
    );
  }
}

class _TxSkeleton extends StatelessWidget {
  final ColorScheme cs;
  final AnimationController pulse;
  const _TxSkeleton({required this.cs, required this.pulse});

  @override
  Widget build(BuildContext context) {
    Widget line(double w) => Container(
          height: 12,
          width: w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: cs.onSurface.withOpacity(0.12),
          ),
        );

    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 0.9).animate(
        CurvedAnimation(parent: pulse, curve: Curves.easeInOut),
      ),
      child: Column(
        children: List.generate(6, (i) {
          final w1 = 170 + Random(i).nextInt(80);
          final w2 = 90 + Random(i + 7).nextInt(80);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: cs.onSurface.withOpacity(0.12),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      line(w1.toDouble()),
                      const SizedBox(height: 8),
                      line(w2.toDouble()),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}