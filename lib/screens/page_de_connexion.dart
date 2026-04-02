import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PageDeConnexionWidget extends StatefulWidget {
  const PageDeConnexionWidget({super.key});

  static String routeName = 'Page_de_connexion';
  static String routePath = '/pageDeConnexion';

  @override
  State<PageDeConnexionWidget> createState() => _PageDeConnexionWidgetState();
}

class _PageDeConnexionWidgetState extends State<PageDeConnexionWidget>
    with TickerProviderStateMixin {

  late TabController _tabController;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  final TextEditingController _emailCreateController = TextEditingController();
  final TextEditingController _passwordCreateController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();
  bool _passwordCreateVisible = false;
  bool _passwordConfirmVisible = false;
  bool _isLoading = false;

  late AnimationController _anim1Controller;
  late AnimationController _anim2Controller;
  late Animation<double> _fade1;
  late Animation<Offset> _slide1;
  late Animation<double> _fade2;
  late Animation<Offset> _slide2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _anim1Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fade1 = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim1Controller, curve: Curves.easeInOut));
    _slide1 = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(CurvedAnimation(parent: _anim1Controller, curve: Curves.easeInOut));

    _anim2Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fade2 = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim2Controller, curve: Curves.easeInOut));
    _slide2 = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(CurvedAnimation(parent: _anim2Controller, curve: Curves.easeInOut));

    SchedulerBinding.instance.addPostFrameCallback((_) => _anim1Controller.forward());
    _tabController.addListener(() {
      if (_tabController.index == 1) _anim2Controller.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailCreateController.dispose();
    _passwordCreateController.dispose();
    _passwordConfirmController.dispose();
    _anim1Controller.dispose();
    _anim2Controller.dispose();
    super.dispose();
  }

  Future<void> _seConnecter() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Veuillez remplir tous les champs.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      Navigator.pushNamed(context, '/mot-de-passe');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showSnackBar('Aucun compte trouvé avec cet email.');
      } else if (e.code == 'wrong-password') {
        _showSnackBar('Mot de passe incorrect.');
      } else {
        _showSnackBar('Erreur : ${e.message}');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _creerCompte() async {
    if (_emailCreateController.text.isEmpty || _passwordCreateController.text.isEmpty || _passwordConfirmController.text.isEmpty) {
      _showSnackBar('Veuillez remplir tous les champs.');
      return;
    }
    if (_passwordCreateController.text != _passwordConfirmController.text) {
      _showSnackBar('Les mots de passe ne correspondent pas.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCreateController.text.trim(),
        password: _passwordCreateController.text,
      );
      Navigator.pushNamed(context, '/mot-de-passe');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showSnackBar('Cet email est déjà utilisé.');
      } else if (e.code == 'weak-password') {
        _showSnackBar('Le mot de passe doit contenir au moins 6 caractères.');
      } else {
        _showSnackBar('Erreur : ${e.message}');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _inputDecoration(String label, {Widget? suffixIcon}) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: cs.onSurface.withOpacity(0.6)),
      filled: true,
      fillColor: cs.surface,
      contentPadding: const EdgeInsets.all(24),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: cs.outline, width: 2), borderRadius: BorderRadius.circular(40)),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: cs.primary, width: 2), borderRadius: BorderRadius.circular(40)),
      errorBorder: OutlineInputBorder(borderSide: BorderSide(color: cs.error, width: 2), borderRadius: BorderRadius.circular(40)),
      focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: cs.error, width: 2), borderRadius: BorderRadius.circular(40)),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 230,
      height: 52,
      child: OutlinedButton(
        onPressed: _isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          backgroundColor: cs.surface,
          side: BorderSide(color: cs.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        ),
        child: _isLoading
            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary))
            : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildConnexionTab() {
    final cs = Theme.of(context).colorScheme;
    return FadeTransition(
      opacity: _fade1,
      child: SlideTransition(
        position: _slide1,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 12, bottom: 24),
                child: Text('Commençons par remplir le formulaire ci-dessous.', style: TextStyle(fontSize: 14, color: Colors.grey)),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: _inputDecoration('Email')),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  decoration: _inputDecoration('Mot de passe',
                    suffixIcon: IconButton(
                      icon: Icon(_passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                    ),
                  ),
                ),
              ),
              Center(child: Padding(padding: const EdgeInsets.only(bottom: 16), child: _buildButton('Connexion', _seConnecter))),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/mot-de-passe-oublie'),
                  child: Text('Mot de passe Oublié ?', style: TextStyle(color: cs.error, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInscriptionTab() {
    return FadeTransition(
      opacity: _fade2,
      child: SlideTransition(
        position: _slide2,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 12, bottom: 24),
                child: Text('Commençons par remplir le formulaire ci-dessous.', style: TextStyle(fontSize: 14, color: Colors.grey)),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(controller: _emailCreateController, keyboardType: TextInputType.emailAddress, decoration: _inputDecoration('Email')),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: _passwordCreateController,
                  obscureText: !_passwordCreateVisible,
                  decoration: _inputDecoration('Mot de passe',
                    suffixIcon: IconButton(
                      icon: Icon(_passwordCreateVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _passwordCreateVisible = !_passwordCreateVisible),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: _passwordConfirmController,
                  obscureText: !_passwordConfirmVisible,
                  decoration: _inputDecoration('Confirmer le mot de passe',
                    suffixIcon: IconButton(
                      icon: Icon(_passwordConfirmVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _passwordConfirmVisible = !_passwordConfirmVisible),
                    ),
                  ),
                ),
              ),
              Center(child: Padding(padding: const EdgeInsets.only(top: 8, bottom: 16), child: _buildButton('Créer un Compte', _creerCompte))),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () { FocusScope.of(context).unfocus(); FocusManager.instance.primaryFocus?.unfocus(); },
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 44),
                  child: Icon(Icons.lock_rounded, size: 100, color: cs.primary),
                ),
                Container(
                  width: double.infinity,
                  height: 680,
                  constraints: const BoxConstraints(maxWidth: 602),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            labelColor: cs.primary,
                            unselectedLabelColor: cs.onSurface.withOpacity(0.5),
                            labelStyle: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                            unselectedLabelStyle: const TextStyle(fontSize: 25, fontWeight: FontWeight.normal),
                            indicatorColor: cs.error,
                            indicatorWeight: 4,
                            labelPadding: const EdgeInsets.all(16),
                            padding: const EdgeInsets.fromLTRB(0, 12, 16, 12),
                            tabs: const [Tab(text: 'Connexion'), Tab(text: 'Inscription')],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [_buildConnexionTab(), _buildInscriptionTab()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
