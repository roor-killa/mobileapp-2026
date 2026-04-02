'use client';

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900 to-slate-900">
      {/* Navigation */}
      <header className="bg-slate-900/80 backdrop-blur-md border-b border-slate-700">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-purple-600 rounded-lg flex items-center justify-center text-white font-bold">N</div>
              <h1 className="text-2xl font-bold text-white">NEG's</h1>
            </div>
            <div className="flex gap-4">
              <a
                href="/login"
                className="px-4 py-2 text-gray-300 hover:text-white transition font-semibold"
              >
                Connexion
              </a>
              <a
                href="/register"
                className="px-6 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-semibold transition"
              >
                S'inscrire
              </a>
            </div>
          </div>
        </div>
      </header>

      {/* Hero */}
      <main>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24">
          <div className="text-center mb-20">
            <h2 className="text-5xl md:text-6xl font-bold text-white mb-6 leading-tight">
              La Banque Moderne <span className="bg-gradient-to-r from-blue-400 to-purple-500 bg-clip-text text-transparent">pour la Vie</span>
            </h2>
            <p className="text-xl text-gray-300 mb-10 max-w-2xl mx-auto">
              L'argent fait le bonheur dit-on. Laissez-nous donc ôter le manque de bonheur financière de votre vie.
            </p>
            <div className="flex gap-4 justify-center">
              <a
                href="/register"
                className="px-8 py-4 bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white rounded-lg font-bold text-lg transition transform hover:scale-105"
              >
                Commencer Maintenant
              </a>
              <a
                href="/login"
                className="px-8 py-4 bg-slate-800 hover:bg-slate-700 text-white rounded-lg font-bold text-lg transition border border-slate-600"
              >
                Se Connecter
              </a>
            </div>
          </div>

          {/* Features Grid */}
          <div className="grid md:grid-cols-3 gap-8 mt-20">
            {[
              {
                icon: '⚡',
                title: 'Virements Instantanés',
                description: 'Envoyez et recevez de l\'argent en secondes',
              },
              {
                icon: '🛡️',
                title: 'Sécurité Bancaire',
                description: 'Votre argent protégé par le chiffrement',
              },
              {
                icon: '💳',
                title: 'Cartes Virtuelles',
                description: 'Créez des cartes jetables pour vos achats en ligne',
              },
              {
                icon: '🌍',
                title: 'Multi-Devises',
                description: 'Échangez et conservez l\'argent en plusieurs devises',
              },
              {
                icon: '📊',
                title: 'Analyse Intelligente',
                description: 'Suivez et analysez vos dépenses',
              },
              {
                icon: '📱',
                title: 'Mobile First',
                description: 'Gérez tout depuis votre téléphone',
              },
            ].map((feature, i) => (
              <div
                key={i}
                className="bg-slate-800/50 border border-slate-700 rounded-xl p-8 hover:bg-slate-800 transition hover:scale-105"
              >
                <div className="text-4xl mb-4">{feature.icon}</div>
                <h3 className="text-xl font-bold text-white mb-2">{feature.title}</h3>
                <p className="text-gray-400">{feature.description}</p>
              </div>
            ))}
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-slate-900 border-t border-slate-700 mt-32">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <div className="text-center text-gray-400">
            <p>&copy; 2026 NEG's. Tous droits réservés.</p>
          </div>
        </div>
      </footer>
    </div>
  );
}
