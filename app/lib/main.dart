import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherPage(),
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final TextEditingController cityController = TextEditingController();

  static const String apiKey = '937ee9f29655fadcad8c6a7dc5d00a69';

  String city = '';
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
        title: const Text('🌤️ Météo en temps réel'),
        centerTitle: true,
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