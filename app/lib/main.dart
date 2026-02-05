import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      home: HomePage(onThemeToggle: _toggleTheme, currentTheme: _themeMode),
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

// Page d'accueil avec 2 boutons
class HomePage extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final ThemeMode currentTheme;

  const HomePage({
    super.key,
    required this.onThemeToggle,
    required this.currentTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌤️ Application Météo'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              currentTheme == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
            ),
            onPressed: onThemeToggle,
            tooltip: 'Changer le thème',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wb_sunny,
                size: 100,
                color: currentTheme == ThemeMode.light ? Colors.orange : Colors.amber,
              ),
              const SizedBox(height: 30),
              const Text(
                'Bienvenue !',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Que souhaitez-vous faire ?',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 50),
              
              // Bouton 1 : Météo
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WeatherPage(
                          onThemeToggle: onThemeToggle,
                          currentTheme: currentTheme,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.cloud, size: 30),
                  label: const Text(
                    'Consulter la météo',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Bouton 2 : Chatbot
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatbotPage(
                          city: '',
                          country: '',
                          temperature: null,
                          description: '',
                          onThemeToggle: onThemeToggle,
                          currentTheme: currentTheme,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble, size: 30),
                  label: const Text(
                    'Parler à l\'expert météo',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
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
}

class WeatherPage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final ThemeMode currentTheme;

  const WeatherPage({
    super.key,
    required this.onThemeToggle,
    required this.currentTheme,
  });

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final TextEditingController cityController = TextEditingController();

  static const String apiKey = '937ee9f29655fadcad8c6a7dc5d00a69';

  String city = '';
  String country = '';
  String description = '';
  String icon = '';
  double? temperature;
  bool loading = false;
  String error = '';

  Future<void> fetchWeather() async {
    final cityName = cityController.text.trim();
    if (cityName.isEmpty) return;

    setState(() {
      loading = true;
      error = '';
    });

    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather'
      '?q=$cityName'
      '&appid=$apiKey'
      '&units=metric'
      '&lang=fr',
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
        setState(() {
          error = 'Ville introuvable';
          temperature = null;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Erreur réseau';
        temperature = null;
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌤️ Météo actuelle'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              widget.currentTheme == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
            ),
            onPressed: widget.onThemeToggle,
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
                  icon: const Icon(Icons.search),
                  onPressed: fetchWeather,
                ),
              ),
              onSubmitted: (_) => fetchWeather(),
            ),

            const SizedBox(height: 30),

            if (loading)
              const CircularProgressIndicator(),

            if (error.isNotEmpty)
              Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 18),
              ),

            if (temperature != null && !loading)
              Column(
                children: [
                  Text(
                    city,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '($country)',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Image.network(
                    'https://openweathermap.org/img/wn/$icon@2x.png',
                  ),
                  Text(
                    '${temperature!.round()} °C',
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 22),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class ChatbotPage extends StatefulWidget {
  final String city;
  final String country;
  final double? temperature;
  final String description;
  final VoidCallback onThemeToggle;
  final ThemeMode currentTheme;

  const ChatbotPage({
    super.key,
    required this.city,
    required this.country,
    required this.temperature,
    required this.description,
    required this.onThemeToggle,
    required this.currentTheme,
  });

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController messageController = TextEditingController();
  final List<ChatMessage> messages = [];
  final ScrollController scrollController = ScrollController();
  bool isLoading = false;

  static const String groqApiKey = 'CLE_API_GROK';

  @override
  void initState() {
    super.initState();
    
    String welcomeMessage = 'Bonjour👋. Je suis votre expert météo. '
        'Posez-moi toutes vos questions sur la météorologie !';
    
    messages.add(ChatMessage(
      text: welcomeMessage,
      isUser: false,
    ));
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    setState(() {
      messages.add(ChatMessage(text: userMessage, isUser: true));
      isLoading = true;
    });

    messageController.clear();
    scrollToBottom();

    try {
      String contextMeteo = '';
      if (widget.city.isNotEmpty && widget.temperature != null) {
        contextMeteo = '''
Contexte météorologique actuel :
- Ville : ${widget.city}, ${widget.country}
- Température : ${widget.temperature?.round()}°C
- Conditions : ${widget.description}

''';
      }

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $groqApiKey',
        },
        body: json.encode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'system',
              'content': 'Tu es un expert en météorologie. Réponds de manière TRÈS COURTE et CONCISE (maximum 3-4 phrases). Utilise des emojis météo. Sois direct et va à l\'essentiel.'
            },
            {
              'role': 'user',
              'content': '$contextMeteo Question : $userMessage'
            }
          ],
          'temperature': 0.7,
          'max_tokens': 300,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final assistantMessage = data['choices'][0]['message']['content'];

        setState(() {
          messages.add(ChatMessage(text: assistantMessage, isUser: false));
        });
        scrollToBottom();
      } else {
        final errorData = json.decode(response.body);
        setState(() {
          messages.add(ChatMessage(
            text: 'Erreur ${response.statusCode}: ${errorData['error']?['message'] ?? 'Veuillez réessayer'}',
            isUser: false,
          ));
        });
      }
    } catch (e) {
      setState(() {
        messages.add(ChatMessage(
          text: 'Erreur de connexion: $e',
          isUser: false,
        ));
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.currentTheme == ThemeMode.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 Expert Météo'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              widget.currentTheme == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
            ),
            onPressed: widget.onThemeToggle,
            tooltip: 'Changer le thème',
          ),
        ],
      ),
      body: Column(
        children: [
          if (widget.city.isNotEmpty && widget.temperature != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: isDark ? Colors.grey[800] : Colors.blue.shade50,
              child: Text(
                '📍 ${widget.city}, ${widget.country} - ${widget.temperature?.round()}°C - ${widget.description}',
                style: const TextStyle(fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),

          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ChatBubble(message: message, isDark: isDark);
              },
            ),
          ),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text('L\'expert réfléchit...'),
                ],
              ),
            ),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black38 : Colors.grey.shade300,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Posez votre question...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
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
                  color: Colors.blue,
                  iconSize: 28,
                ),
              ],
            ),
          ),
        ],
      ),
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

  const ChatBubble({
    super.key,
    required this.message,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser 
              ? Colors.blue 
              : (isDark ? Colors.grey[800] : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser 
                ? Colors.white 
                : (isDark ? Colors.white : Colors.black87),
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}