import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/supabase_service.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  final _themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  @override
  void dispose() {
    _themeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeNotifier,
      builder: (context, themeMode, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: themeMode,
        theme: ThemeData(brightness: Brightness.light, primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white),
        darkTheme: ThemeData(brightness: Brightness.dark, primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.grey[900]),
        home: HomePage(themeNotifier: _themeNotifier),
      ),
    );
  }
}

// Fonction pour convertir le code pays en nom complet
String getCountryName(String countryCode) {
  const Map<String, String> countries = {
    "AF": "Afghanistan",
    "ZA": "Afrique du Sud",
    "AL": "Albanie",
    "DZ": "Algérie",
    "DE": "Allemagne",
    "AD": "Andorre",
    "AO": "Angola",
    "AI": "Anguilla",
    "AQ": "Antarctique",
    "AG": "Antigua-et-Barbuda",
    "SA": "Arabie saoudite",
    "AR": "Argentine",
    "AM": "Arménie",
    "AW": "Aruba",
    "AU": "Australie",
    "AT": "Autriche",
    "AZ": "Azerbaïdjan",
    "BS": "Bahamas",
    "BH": "Bahreïn",
    "BD": "Bangladesh",
    "BB": "Barbade",
    "BY": "Biélorussie",
    "BE": "Belgique",
    "BZ": "Belize",
    "BJ": "Bénin",
    "BM": "Bermudes",
    "BT": "Bhoutan",
    "BO": "Bolivie",
    "BA": "Bosnie-Herzégovine",
    "BW": "Botswana",
    "BR": "Brésil",
    "BN": "Brunei",
    "BG": "Bulgarie",
    "BF": "Burkina Faso",
    "BI": "Burundi",
    "KH": "Cambodge",
    "CM": "Cameroun",
    "CA": "Canada",
    "CV": "Cap-Vert",
    "CL": "Chili",
    "CN": "Chine",
    "CY": "Chypre",
    "CO": "Colombie",
    "KM": "Comores",
    "KP": "Corée du Nord",
    "KR": "Corée du Sud",
    "CR": "Costa Rica",
    "CI": "Côte d'Ivoire",
    "HR": "Croatie",
    "CU": "Cuba",
    "CW": "Curaçao",
    "DK": "Danemark",
    "DJ": "Djibouti",
    "DM": "Dominique",
    "EG": "Égypte",
    "AE": "Émirats arabes unis",
    "EC": "Équateur",
    "ER": "Érythrée",
    "FM": "États fédérés de Micronésie",
    "ES": "Espagne",
    "EE": "Estonie",
    "US": "États-Unis",
    "ET": "Éthiopie",
    "FJ": "Fidji",
    "FI": "Finlande",
    "FR": "France",
    "GA": "Gabon",
    "GM": "Gambie",
    "GE": "Géorgie",
    "GS": "Géorgie du Sud-et-les Îles Sandwich du Sud",
    "GH": "Ghana",
    "GI": "Gibraltar",
    "GR": "Grèce",
    "GD": "Grenade",
    "GL": "Groenland",
    "GP": "Guadeloupe",
    "GU": "Guam",
    "GT": "Guatemala",
    "GG": "Guernesey",
    "GN": "Guinée",
    "GQ": "Guinée équatoriale",
    "GW": "Guinée-Bissau",
    "GY": "Guyana",
    "GF": "Guyane",
    "HT": "Haïti",
    "HN": "Honduras",
    "HK": "Hong Kong",
    "HU": "Hongrie",
    "CX": "Île Christmas",
    "BV": "Île Bouvet",
    "NF": "Île Norfolk",
    "AX": "Îles Åland",
    "KY": "Îles Caïmans",
    "CC": "Îles Cocos",
    "CK": "Îles Cook",
    "FO": "Îles Féroé",
    "HM": "Îles Heard-et-MacDonald",
    "FK": "Îles Malouines",
    "MP": "Îles Mariannes du Nord",
    "MH": "Îles Marshall",
    "UM": "Îles mineures éloignées des États-Unis",
    "TC": "Îles Turques-et-Caïques",
    "VG": "Îles Vierges britanniques",
    "VI": "Îles Vierges des États-Unis",
    "IN": "Inde",
    "ID": "Indonésie",
    "IQ": "Irak",
    "IR": "Iran",
    "IE": "Irlande",
    "IS": "Islande",
    "IL": "Israël",
    "IT": "Italie",
    "JM": "Jamaïque",
    "JP": "Japon",
    "JE": "Jersey",
    "JO": "Jordanie",
    "KZ": "Kazakhstan",
    "KE": "Kenya",
    "KG": "Kirghizistan",
    "KI": "Kiribati",
    "KW": "Koweït",
    "LA": "Laos",
    "LS": "Lesotho",
    "LV": "Lettonie",
    "LB": "Liban",
    "LR": "Liberia",
    "LY": "Libye",
    "LI": "Liechtenstein",
    "LT": "Lituanie",
    "LU": "Luxembourg",
    "MO": "Macao",
    "MK": "Macédoine du Nord",
    "MG": "Madagascar",
    "MY": "Malaisie",
    "MW": "Malawi",
    "MV": "Maldives",
    "ML": "Mali",
    "MT": "Malte",
    "MA": "Maroc",
    "MQ": "Martinique",
    "MU": "Maurice",
    "MR": "Mauritanie",
    "YT": "Mayotte",
    "MX": "Mexique",
    "MD": "Moldavie",
    "MC": "Monaco",
    "MN": "Mongolie",
    "ME": "Monténégro",
    "MS": "Montserrat",
    "MZ": "Mozambique",
    "NA": "Namibie",
    "NR": "Nauru",
    "NP": "Népal",
    "NI": "Nicaragua",
    "NE": "Niger",
    "NG": "Nigeria",
    "NU": "Niue",
    "NO": "Norvège",
    "NC": "Nouvelle-Calédonie",
    "NZ": "Nouvelle-Zélande",
    "OM": "Oman",
    "UG": "Ouganda",
    "UZ": "Ouzbékistan",
    "PK": "Pakistan",
    "PW": "Palaos",
    "PS": "Palestine",
    "PA": "Panama",
    "PG": "Papouasie-Nouvelle-Guinée",
    "PY": "Paraguay",
    "PE": "Pérou",
    "PH": "Philippines",
    "PL": "Pologne",
    "PF": "Polynésie française",
    "PT": "Portugal",
    "QA": "Qatar",
    "RE": "La Réunion",
    "EH": "République arabe sahraouie démocratique",
    "CF": "République centrafricaine",
    "CD": "République démocratique du Congo",
    "DO": "République dominicaine",
    "CG": "République du Congo",
    "RO": "Roumanie",
    "GB": "Royaume-Uni",
    "RU": "Russie",
    "RW": "Rwanda",
    "BL": "Saint-Barthélemy",
    "KN": "Saint-Christophe-et-Niévès",
    "SM": "Saint-Marin",
    "MF": "Saint-Martin (partie française)",
    "SX": "Saint-Martin (partie néerlandaise)",
    "PM": "Saint-Pierre-et-Miquelon",
    "VA": "Saint-Siège",
    "VC": "Saint-Vincent-et-les-Grenadines",
    "SH": "Saint-Hélène",
    "LC": "Sainte-Lucie",
    "SV": "Salvador",
    "AS": "Samoa américaines",
    "WS": "Samoa",
    "ST": "Sao Tomé-et-Principe",
    "SN": "Sénégal",
    "RS": "Serbie",
    "SC": "Seychelles",
    "SL": "Sierra Leone",
    "SG": "Singapour",
    "SK": "Slovaquie",
    "SI": "Slovénie",
    "SO": "Somalie",
    "SD": "Soudan",
    "SS": "Soudan du Sud",
    "LK": "Sri Lanka",
    "SE": "Suède",
    "CH": "Suisse",
    "SR": "Suriname",
    "SJ": "Svalbard et île Jan Mayen",
    "SZ": "Eswatini",
    "SY": "Syrie",
    "TJ": "Tadjikistan",
    "TW": "Taïwan",
    "TZ": "Tanzanie",
    "TD": "Tchad",
    "CZ": "Tchéquie",
    "TF": "Terres australes et antarctiques françaises",
    "IO": "Territoire britannique de l'océan Indien",
    "TH": "Thaïlande",
    "TL": "Timor oriental",
    "TG": "Togo",
    "TK": "Tokelau",
    "TO": "Tonga",
    "TT": "Trinité-et-Tobago",
    "TN": "Tunisie",
    "TM": "Turkménistan",
    "TR": "Turquie",
    "TV": "Tuvalu",
    "UA": "Ukraine",
    "UY": "Uruguay",
    "VU": "Vanuatu",
    "VE": "Venezuela",
    "VN": "Vietnam",
    "WF": "Wallis-et-Futuna",
    "YE": "Yémen",
    "ZM": "Zambie",
    "ZW": "Zimbabwe",
  };

  return countries[countryCode] ?? countryCode;
}

// ── HomePage ──────────────────────────────────────────────────────────────────
class HomePage extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier;
  final VoidCallback? onBack;

  const HomePage({super.key, required this.themeNotifier, this.onBack});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) => Scaffold(
        appBar: AppBar(
          title: const Text('🌤️ Interface Météo'),
          centerTitle: true,
          leading: (onBack != null || Navigator.canPop(context))
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack ?? () => Navigator.pop(context),
                )
              : null,
          actions: [
            IconButton(
              icon: Icon(themeMode == ThemeMode.light
                  ? Icons.dark_mode : Icons.light_mode),
              onPressed: () {
                themeNotifier.value = themeNotifier.value == ThemeMode.light
                    ? ThemeMode.dark : ThemeMode.light;
              },
              tooltip: 'Changer le thème',
            ),
          ],
        ),
        // ── Body restauré ─────────────────────────────────────────────
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wb_sunny, size: 100,
                    color: themeMode == ThemeMode.light
                        ? Colors.orange : Colors.amber),
                const SizedBox(height: 30),
                const Text('Bienvenue !',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('Que souhaitez-vous faire ?',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                const SizedBox(height: 50),
                SizedBox(
                  width: double.infinity, height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => WeatherPage(themeNotifier: themeNotifier))),
                    icon: const Icon(Icons.cloud, size: 30),
                    label: const Text('Consulter la météo',
                        style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => ChatbotPage(
                          city: '', country: '', temperature: null, description: '',
                          themeNotifier: themeNotifier,
                        ))),
                    icon: const Icon(Icons.chat_bubble, size: 30),
                    label: const Text('Parler à l\'expert météo',
                        style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
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

// ── WeatherPage ───────────────────────────────────────────────────────────────
class WeatherPage extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const WeatherPage({super.key, required this.themeNotifier});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final TextEditingController cityController = TextEditingController();
  static const String apiKey = '937ee9f29655fadcad8c6a7dc5d00a69';
  String city = '', country = '', description = '', icon = '';
  double? temperature;
  bool loading = false;
  String error = '';

  Future<void> fetchWeather() async {
    final cityName = cityController.text.trim();
    if (cityName.isEmpty) return;
    setState(() { loading = true; error = ''; });
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather'
      '?q=$cityName&appid=$apiKey&units=metric&lang=fr',
    );
    try {
      final response = await http.get(url);
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          city = data['name'];
          country = getCountryName(data['sys']['country']);
          temperature = data['main']['temp'].toDouble();
          description = data['weather'][0]['description'];
          icon = data['weather'][0]['icon'];
        });
      } else {
        setState(() { error = 'Ville introuvable'; temperature = null; });
      }
    } catch (e) {
      setState(() { error = 'Erreur réseau'; temperature = null; });
    }
    setState(() { loading = false; });
  }

  @override
  void dispose() { cityController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: widget.themeNotifier,
      builder: (context, themeMode, _) => Scaffold(
        appBar: AppBar(
          title: const Text('🌤️ Météo actuelle'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(themeMode == ThemeMode.light
                  ? Icons.dark_mode : Icons.light_mode),
              onPressed: () {
                widget.themeNotifier.value =
                    widget.themeNotifier.value == ThemeMode.light
                        ? ThemeMode.dark : ThemeMode.light;
              },
              tooltip: 'Changer le thème',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: cityController,
                decoration: InputDecoration(
                  labelText: 'Entrer une ville',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                      icon: const Icon(Icons.search), onPressed: fetchWeather),
                ),
                onSubmitted: (_) => fetchWeather(),
              ),
              const SizedBox(height: 30),
              if (loading) const CircularProgressIndicator(),
              if (error.isNotEmpty)
                Text(error, style: const TextStyle(color: Colors.red, fontSize: 18)),
              if (temperature != null && !loading)
                Column(children: [
                  Text(city, style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text('($country)', style: TextStyle(
                      fontSize: 18, color: Colors.grey[600])),
                  const SizedBox(height: 10),
                  Image.network('https://openweathermap.org/img/wn/$icon@2x.png'),
                  Text('${temperature!.round()} °C',
                      style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 5),
                  Text(description, style: const TextStyle(fontSize: 22)),
                ]),
            ],
          ),
        ),
      ),
    );
  }
}

// ── ChatbotPage ───────────────────────────────────────────────────────────────
class ChatbotPage extends StatefulWidget {
  final String city, country, description;
  final double? temperature;
  final ValueNotifier<ThemeMode> themeNotifier;

  const ChatbotPage({
    super.key,
    required this.city, required this.country,
    required this.temperature, required this.description,
    required this.themeNotifier,
  });

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');

  final TextEditingController messageController = TextEditingController();
  final List<ChatMessage> messages = [];
  final ScrollController scrollController = ScrollController();
  bool isLoading = false, isLoadingHistory = true;

  // Historique pour le contexte
  final List<Map<String, String>> _conversationHistory = [];

  @override
  void initState() { super.initState(); _loadHistory(); }

  Future<void> _loadHistory() async {
    try {
      final rows = await SupabaseService.getChatMessages(widget.city);
      setState(() {
        for (final r in rows as List) {
          final content = r['content'] as String;
          final isUser = r['is_user'] as bool;
          messages.add(ChatMessage(text: content, isUser: isUser));
          // ✅ N'ajoute à l'historique Groq QUE les messages user/assistant
          // en ignorant le message de bienvenue (isUser: false en premier)
          if (_conversationHistory.isNotEmpty || isUser) {
            _conversationHistory.add({
              'role': isUser ? 'user' : 'assistant',
              'content': content,
            });
          }
        }
        if (messages.isEmpty) _addWelcome();
      });
    } catch (_) { _addWelcome(); }
    finally { setState(() => isLoadingHistory = false); scrollToBottom(); }
  }

  void _addWelcome() => messages.add(ChatMessage(
      text: 'Bonjour👋. Je suis votre expert météo. '
          'Posez-moi toutes vos questions sur la météorologie !',
      isUser: false));

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  // ── Récupère la météo d'une ville mentionnée dans le message ─────────────
static const String _weatherApiKey = '937ee9f29655fadcad8c6a7dc5d00a69';

Future<String> _fetchWeatherForCity(String cityName) async {
  try {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather'
      '?q=$cityName&appid=$_weatherApiKey&units=metric&lang=fr',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final name = data['name'];
      final country = getCountryName(data['sys']['country']);
      final temp = (data['main']['temp'] as num).round();
      final desc = data['weather'][0]['description'];
      final humidity = data['main']['humidity'];
      final windSpeed = (data['wind']['speed'] as num).toStringAsFixed(1);
      final feelsLike = (data['main']['feels_like'] as num).round();
      return 'Météo à $name ($country) : $temp°C (ressenti $feelsLike°C), '
          '$desc, humidité $humidity%, vent $windSpeed m/s.';
    }
  } catch (_) {}
  return '';
}

// ── Extrait une ville du message utilisateur ─────────────────────────────
Future<String> _extractCityWeather(String userMessage) async {
  // Patterns courants pour détecter une ville dans le message
  final patterns = [
    RegExp(r'(?:météo|temps|température|climat|pluie|soleil|vent|chaud|froid)\s+(?:à|a|au|en|de|sur)\s+([A-ZÀ-Ÿa-zà-ÿ\s\-]+?)(?:\s*[?!.,]|$)', caseSensitive: false),
    RegExp(r'(?:à|a|au|en)\s+([A-ZÀ-Ÿa-zà-ÿ\s\-]+?)(?:\s+(?:il fait|il y a|météo|temps|aujourd|demain)|[?!.,]|$)', caseSensitive: false),
    RegExp(r'^([A-ZÀ-Ÿa-zà-ÿ\s\-]+?)(?:\s*[?!.,]|$)', caseSensitive: false),
  ];

  for (final pattern in patterns) {
    final match = pattern.firstMatch(userMessage);
    if (match != null) {
      final city = match.group(1)?.trim() ?? '';
      if (city.length > 2) {
        final weather = await _fetchWeatherForCity(city);
        if (weather.isNotEmpty) return weather;
      }
    }
  }
  return '';
}

Future<String> _askGroq(String userMessage) async {
  // Contexte météo de base (ville consultée dans WeatherPage)
  String meteoContext = widget.city.isNotEmpty && widget.temperature != null
      ? 'Météo actuelle consultée : ${widget.city}, ${widget.country} — '
        '${widget.temperature?.round()}°C, ${widget.description}. '
      : '';

  // Tente de récupérer la météo d'une ville mentionnée dans le message
  final cityWeather = await _extractCityWeather(userMessage);
  if (cityWeather.isNotEmpty) {
    meteoContext += 'Données météo en temps réel pour la demande : $cityWeather';
  }

  final cleanHistory = <Map<String, String>>[];
  for (final msg in _conversationHistory) {
    if (cleanHistory.isEmpty && msg['role'] != 'user') continue;
    if (cleanHistory.isNotEmpty && cleanHistory.last['role'] == msg['role']) continue;
    cleanHistory.add(msg);
  }

  final response = await http.post(
    Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    },
    body: json.encode({
      'model': 'llama-3.1-8b-instant',
      'max_tokens': 512,
      'messages': [
        {
          'role': 'system',
          'content':
              'Tu es un expert météorologue friendly et concis. '
              'Tu réponds uniquement en français. '
              'Tu as accès aux données météo en temps réel via OpenWeatherMap. '
              'Tu donnes des conseils pratiques liés à la météo '
              '(vêtements, activités, précautions). '
              '$meteoContext',
        },
        ...cleanHistory,
        {'role': 'user', 'content': userMessage},
      ],
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['choices'][0]['message']['content'] as String;
  } else {
    throw Exception('Erreur API: ${response.statusCode}');
  }
}

  Future<void> sendMessage(String userMessage) async {
  if (userMessage.trim().isEmpty) return;

  setState(() {
    messages.add(ChatMessage(text: userMessage, isUser: true));
    isLoading = true;
  });
  messageController.clear();
  scrollToBottom();

  // Sauvegarde non-bloquante
  try {
    await SupabaseService.saveChatMessage(
        content: userMessage, isUser: true, city: widget.city);
  } catch (_) {}

  _conversationHistory.add({'role': 'user', 'content': userMessage});

  try {
    final botResponse = await _askGroq(userMessage);

    // Sauvegarde non-bloquante
    try {
      await SupabaseService.saveChatMessage(
          content: botResponse, isUser: false, city: widget.city);
    } catch (_) {}

    _conversationHistory.add({'role': 'assistant', 'content': botResponse});

    setState(() {
      messages.add(ChatMessage(text: botResponse, isUser: false));
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      messages.add(ChatMessage(
          text: '❌ Erreur : vérifiez votre connexion ou votre clé API.',
          isUser: false));
      isLoading = false;
    });
  }
  scrollToBottom();
}

  @override
  void dispose() { messageController.dispose(); scrollController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: widget.themeNotifier,
      builder: (context, themeMode, _) {
        final isDark = themeMode == ThemeMode.dark;
        return Scaffold(
          appBar: AppBar(
            title: const Text('🤖 Expert Météo'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(themeMode == ThemeMode.light
                    ? Icons.dark_mode : Icons.light_mode),
                onPressed: () {
                  widget.themeNotifier.value =
                      widget.themeNotifier.value == ThemeMode.light
                          ? ThemeMode.dark : ThemeMode.light;
                },
                tooltip: 'Changer le thème',
              ),
            ],
          ),
          body: isLoadingHistory
              ? const Center(child: CircularProgressIndicator())
              : Column(children: [
                  if (widget.city.isNotEmpty && widget.temperature != null)
                    Container(
                      width: double.infinity, padding: const EdgeInsets.all(12),
                      color: isDark ? Colors.grey[800] : Colors.blue.shade50,
                      child: Text(
                        '📍 ${widget.city}, ${widget.country} — ${widget.temperature?.round()}°C — ${widget.description}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (ctx, i) =>
                          ChatBubble(message: messages[i], isDark: isDark),
                    ),
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 10),
                        Text('L\'expert réfléchit...'),
                      ]),
                    ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[850] : Colors.white,
                      boxShadow: [BoxShadow(
                          color: isDark ? Colors.black38 : Colors.grey.shade300,
                          blurRadius: 5, offset: const Offset(0, -2))],
                    ),
                    child: Row(children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'Posez votre question météo...',
                            hintStyle: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600]),
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          onSubmitted: sendMessage,
                          enabled: !isLoading,
                          maxLines: null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: isLoading
                            ? null
                            : () => sendMessage(messageController.text),
                        icon: const Icon(Icons.send),
                        color: Colors.blue, iconSize: 28,
                      ),
                    ]),
                  ),
                ]),
        );
      },
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDark;
  const ChatBubble({super.key, required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser
              ? Colors.blue
              : (isDark ? Colors.grey[800] : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(message.text,
            style: TextStyle(
              color: message.isUser
                  ? Colors.white
                  : (isDark ? Colors.white : Colors.black87),
              fontSize: 15,
            )),
      ),
    );
  }
}

// ── WeatherStandalonePage ─────────────────────────────────────────────────────
class WeatherStandalonePage extends StatefulWidget {
  const WeatherStandalonePage({super.key});

  @override
  State<WeatherStandalonePage> createState() => _WeatherStandalonePageState();
}

// ── WeatherStandalonePage — passe le navigateur parent à HomePage ─────────
class _WeatherStandalonePageState extends State<WeatherStandalonePage> {
  final _themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);
  // Capture le NavigatorState du contexte PARENT (la banque) avant que
  // MaterialApp ne crée son propre Navigator
  NavigatorState? _parentNavigator;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // On récupère le navigator parent ici, avant que MaterialApp enfant existe
    _parentNavigator = Navigator.maybeOf(context);
  }

  @override
  void dispose() { _themeNotifier.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeNotifier,
      builder: (context, themeMode, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: themeMode,
        theme: ThemeData(brightness: Brightness.light, primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white),
        darkTheme: ThemeData(brightness: Brightness.dark, primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.grey[900]),
        home: HomePage(
          themeNotifier: _themeNotifier,
          // ── Utilise le navigator parent pour revenir à la banque ──────
          onBack: _parentNavigator != null
              ? () => _parentNavigator!.pop()
              : null,
        ),
      ),
    );
  }
}
