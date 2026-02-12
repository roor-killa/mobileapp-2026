<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\WeatherData;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class ChatbotController extends Controller
{
    private const API_KEY = '937ee9f29655fadcad8c6a7dc5d00a69';
    private const API_URL = 'https://api.openweathermap.org/data/2.5/weather';

    /**
     * Normalise une chaîne : enlève accents, convertit en minuscules, enlève 's' final
     */
    private function normalizeText($text)
    {
        // Enlever les accents
        $unwanted_array = [
            'á'=>'a', 'à'=>'a', 'â'=>'a', 'ä'=>'a', 'ã'=>'a', 'å'=>'a',
            'é'=>'e', 'è'=>'e', 'ê'=>'e', 'ë'=>'e',
            'í'=>'i', 'ì'=>'i', 'î'=>'i', 'ï'=>'i',
            'ó'=>'o', 'ò'=>'o', 'ô'=>'o', 'ö'=>'o', 'õ'=>'o',
            'ú'=>'u', 'ù'=>'u', 'û'=>'u', 'ü'=>'u',
            'ý'=>'y', 'ÿ'=>'y',
            'ñ'=>'n', 'ç'=>'c', 'œ'=>'oe', 'æ'=>'ae'
        ];
        
        $text = mb_strtolower($text, 'UTF-8');
        $text = strtr($text, $unwanted_array);
        
        // Enlever les 's' en fin de mots pour gérer singulier/pluriel
        $text = preg_replace('/\bs\b/i', '', $text); // enlever "s" isolé
        $text = preg_replace('/([a-z])s(\s|$)/i', '$1$2', $text); // enlever 's' final des mots
        
        return $text;
    }

    /**
     * Vérifie si le pattern matche le sujet (flexible)
     */
    private function matchesFlexible($pattern, $subject)
    {
        // Test direct d'abord
        if (preg_match($pattern, $subject)) {
            return true;
        }
        
        // Normaliser et tester
        $normalizedSubject = $this->normalizeText($subject);
        $normalizedPattern = $this->normalizeText($pattern);
        
        return preg_match($normalizedPattern, $normalizedSubject);
    }

    /**
     * Extrait une correspondance flexible
     */
    private function matchFlexible($pattern, $subject, &$matches)
    {
        // Test direct d'abord
        if (preg_match($pattern, $subject, $matches)) {
            return true;
        }
        
        // Normaliser et tester
        $normalizedSubject = $this->normalizeText($subject);
        $normalizedPattern = $this->normalizeText($pattern);
        
        return preg_match($normalizedPattern, $normalizedSubject, $matches);
    }

    public function chat(Request $request)
    {
        $request->validate([
            'message' => 'required|string',
            'city' => 'nullable|string',
            'temperature' => 'nullable|numeric',
            'description' => 'nullable|string',
        ]);

        $userMessage = strtolower($request->message);
        
        try {
            $response = $this->generateResponse($userMessage, $request->all());
        } catch (\Exception $e) {
            // Log l'erreur pour debug
            \Log::error('Chatbot error: ' . $e->getMessage());
            $response = "❌ Désolé, une erreur s'est produite. Veuillez réessayer.";
        }

        return response()->json([
            'response' => $response,
            'timestamp' => now()->toISOString(),
        ]);
    }

    private function generateResponse(string $message, array $context)
    {
        // ============ REQUÊTE MÉTÉO D'UNE VILLE ============
        if ($this->matchFlexible('/(temperature|meteo|temps|il fait|climat).*(a|à)\s+([a-z\s\-]+)/i', $message, $matches)) {
            $cityName = trim($matches[3] ?? '');
            if ($cityName) {
                return $this->getWeatherForCity($cityName);
            }
        }

        if ($this->matchFlexible('/(temperature|meteo|temps|il fait|climat)\s+(de|d)\s+([a-z\s\-]+)/i', $message, $matches)) {
            $cityName = trim($matches[3] ?? '');
            if ($cityName) {
                return $this->getWeatherForCity($cityName);
            }
        }

        if ($this->matchFlexible('/^([a-z\s\-]+)\s+(temperature|meteo|temps)/i', $message, $matches)) {
            $cityName = trim($matches[1] ?? '');
            if ($cityName) {
                return $this->getWeatherForCity($cityName);
            }
        }

        // Détecter "combien" + ville
        if ($this->matchFlexible('/(combien|quel|quelle).*(a|à)\s+([a-z\s\-]+)/i', $message, $matches)) {
            $cityName = trim($matches[3] ?? '');
            if ($cityName) {
                return $this->getWeatherForCity($cityName);
            }
        }

        // ============ CONTEXTE MÉTÉO ACTUEL ============
        if (isset($context['city']) && isset($context['temperature'])) {
            $city = $context['city'];
            $temp = $context['temperature'];
            $desc = $context['description'] ?? '';

            if ($this->matchesFlexible('/meteo|temps|il fait|climat actuel/i', $message)) {
                $conseil = $this->getAdviceByTemp($temp);
                return "🌍 À $city, il fait actuellement {$temp}°C avec $desc. $conseil";
            }
        }

        // ============ TEMPÉRATURE ============
        if ($this->matchesFlexible('/temperature|degre|chaud|froid|canicule|gel/i', $message)) {
            if (isset($context['temperature'])) {
                return $this->analyzeTemperature($context['temperature'], $context['city'] ?? '');
            }
            return "🌡️ La température se mesure en degrés Celsius (°C) ou Fahrenheit (°F). Elle varie selon la saison, l'altitude et la latitude. Record mondial : 56.7°C en Californie (1913) et -89.2°C en Antarctique (1983) !";
        }

        // ============ PLUIE ============
        if ($this->matchesFlexible('/pluie|pleuvoir|pleut|averse|precipitation|parapluie|mouille/i', $message)) {
            if (isset($context['description']) && preg_match('/pluie|rain|drizzle/i', $context['description'])) {
                return "🌧️ Oui, il pleut à {$context['city']} ! Prenez un parapluie ☔. La pluie apporte de l'eau essentielle pour la nature. Saviez-vous qu'une goutte de pluie tombe à environ 30 km/h ?";
            }
            return "☔ La pluie se forme quand les gouttelettes d'eau dans les nuages deviennent trop lourdes et tombent. Types de pluie : bruine (fine), averse (intense et courte), pluie verglaçante (gèle au contact). Record : 1,825 mètres de pluie en un an à Mawsynram, Inde !";
        }

        // ============ NUAGES ============
        if ($this->matchesFlexible('/nuage|couvert|ciel|brumeux/i', $message)) {
            return "☁️ Les nuages sont formés de milliards de gouttelettes d'eau ou de cristaux de glace. Types principaux :
            
- Cumulus ☁️ : blancs et cotonneux, beau temps
- Stratus 🌫️ : gris, couvrent tout le ciel
- Cirrus 🌀 : fins et élevés, en forme de filaments
- Cumulonimbus ⛈️ : énormes nuages d'orage

Un nuage peut peser plusieurs tonnes !";
        }

        // ============ VENT ============
        if ($this->matchesFlexible('/vent|venteux|brise|ouragan|tornade|cyclone|tempete/i', $message)) {
            if ($this->matchesFlexible('/ouragan|cyclone|typhon/i', $message)) {
                return "🌪️ Les ouragans (Atlantique), cyclones (Indien) et typhons (Pacifique) sont le même phénomène : des tempêtes tropicales avec des vents >119 km/h. Ils tournent dans le sens inverse des aiguilles d'une montre dans l'hémisphère Nord. L'œil du cyclone est une zone calme au centre !";
            }
            if ($this->matchesFlexible('/tornade/i', $message)) {
                return "🌪️ Les tornades sont des colonnes d'air en rotation violente. Elles peuvent atteindre 500 km/h ! Échelle de Fujita : F0 (faible) à F5 (catastrophique). Les USA comptent environ 1000 tornades par an, surtout dans la 'Tornado Alley'.";
            }
            return "💨 Le vent est causé par les différences de pression atmosphérique. L'air se déplace toujours du haute pression vers la basse pression. Échelle de Beaufort : 0 (calme) à 12 (ouragan). Record : 408 km/h sur l'île de Barrow, Australie (1996) !";
        }

        // ============ SOLEIL ============
        if ($this->matchesFlexible('/soleil|ensoleille|UV|bronzer|creme solaire/i', $message)) {
            return "☀️ Le soleil émet de la lumière et de la chaleur essentielles à la vie. Les rayons UV peuvent être dangereux : 
            
- UVA : vieillissement de la peau
- UVB : coups de soleil
- UVC : bloqués par l'atmosphère

Protégez-vous avec de la crème solaire SPF 30+ ! Le soleil met 8 minutes pour nous atteindre à la vitesse de la lumière (300 000 km/s).";
        }

        // ============ NEIGE ============
        if ($this->matchesFlexible('/neige|neiger|flocon|avalanche|blizzard/i', $message)) {
            if ($this->matchesFlexible('/avalanche/i', $message)) {
                return "❄️ Une avalanche est une masse de neige qui dévale une pente. Vitesse : jusqu'à 130 km/h ! Causes : accumulation de neige, pente raide, vibrations. En montagne, respectez les consignes de sécurité et les panneaux d'avertissement.";
            }
            return "❄️ La neige se forme quand il fait <0°C et que la vapeur d'eau gèle directement en cristaux. Chaque flocon a une structure hexagonale unique ! Record de neige en 24h : 1,93 mètres au Colorado (1921). La neige fraîche contient 90% d'air, c'est pourquoi elle isole bien.";
        }

        // ============ ORAGE ============
        if ($this->matchesFlexible('/orage|eclair|foudre|tonnerre|electrique/i', $message)) {
            if ($this->matchesFlexible('/eclair|foudre/i', $message)) {
                return "⚡ La foudre est une décharge électrique de plusieurs millions de volts ! Elle peut atteindre 30 000°C (5 fois plus chaud que le soleil). Vitesse : 100 000 km/s. Si vous voyez un éclair, comptez les secondes jusqu'au tonnerre, divisez par 3 = distance en km. Abritez-vous toujours pendant un orage !";
            }
            if ($this->matchesFlexible('/tonnerre/i', $message)) {
                return "🔊 Le tonnerre est le bruit de l'éclair ! L'éclair chauffe l'air si vite qu'il crée une onde de choc sonore. Le son voyage à 340 m/s (beaucoup plus lent que la lumière), c'est pourquoi on voit l'éclair avant d'entendre le tonnerre.";
            }
            return "⛈️ Les orages se forment quand l'air chaud et humide monte rapidement et rencontre l'air froid. Ils produisent éclairs, tonnerre, pluie intense et parfois grêle. Un orage peut générer 15 millions de volts et des vents >100 km/h. Ne vous abritez jamais sous un arbre !";
        }

        // ============ GRÊLE ============
        if ($this->matchesFlexible('/grele|grelon/i', $message)) {
            return "🧊 La grêle se forme dans les cumulonimbus quand des gouttes d'eau sont projetées dans l'air froid en altitude et gèlent. Elles peuvent faire plusieurs allers-retours et grossir ! Record : grêlon de 20 cm de diamètre (1 kg) au Dakota du Sud, USA. La grêle peut détruire cultures et voitures.";
        }

        // ============ HUMIDITÉ ============
        if ($this->matchesFlexible('/humidite|humide|sec|moiteur/i', $message)) {
            return "💧 L'humidité mesure la quantité de vapeur d'eau dans l'air (0-100%). 
            
- <30% : air sec, irritation
- 40-60% : idéal pour la santé
- >70% : air lourd, transpiration difficile

L'humidité relative dépend de la température : l'air chaud peut contenir plus d'eau. C'est pourquoi les tropiques sont humides et les déserts secs.";
        }

        // ============ BROUILLARD ============
        if ($this->matchesFlexible('/brouillard|brume|visibilite/i', $message)) {
            return "🌫️ Le brouillard est un nuage au sol ! Il se forme quand l'air humide se refroidit et la vapeur d'eau se condense en gouttelettes. Visibilité <1 km = brouillard, >1 km = brume. Types : brouillard de rayonnement (nuit), d'advection (air chaud sur sol froid), de vallée. Conduite : phares antibrouillard + réduire vitesse.";
        }

        // ============ ARC-EN-CIEL ============
        if ($this->matchesFlexible('/arc-en-ciel|arc en ciel|couleur|spectre/i', $message)) {
            return "🌈 Un arc-en-ciel apparaît quand la lumière du soleil traverse des gouttes d'eau et se décompose en 7 couleurs : Rouge, Orange, Jaune, Vert, Bleu, Indigo, Violet (ROYJBIV). Le soleil doit être derrière vous ! Double arc-en-ciel = réflexion double avec couleurs inversées.";
        }

        // ============ SAISONS ============
        if ($this->matchesFlexible('/saison|printemps|ete|automne|hiver|equinoxe|solstice/i', $message)) {
            return "🍂 Les saisons sont causées par l'inclinaison de la Terre (23.5°) :
            
- Printemps 🌸 : mars-juin, renaissance
- Été ☀️ : juin-septembre, chaleur max
- Automne 🍁 : septembre-décembre, feuilles tombent
- Hiver ❄️ : décembre-mars, froid

Équinoxes (jour = nuit) : 20 mars et 22 septembre. Solstices (jour max/min) : 21 juin et 21 décembre.";
        }

        // ============ CLIMAT ============
        if ($this->matchesFlexible('/climat|rechauffement|changement climatique|effet de serre|CO2/i', $message)) {
            return "🌍 Le climat est le temps moyen sur plusieurs années. Le réchauffement climatique est causé par les gaz à effet de serre (CO₂, méthane) qui piègent la chaleur. Conséquences : fonte des glaces, montée des océans, événements extrêmes plus fréquents. Agissez : réduire CO₂, économiser énergie, planter des arbres !";
        }

        // ============ PRESSION ATMOSPHÉRIQUE ============
        if ($this->matchesFlexible('/pression|anticyclone|depression|barometre|hPa/i', $message)) {
            return "📊 La pression atmosphérique est le poids de l'air (mesurée en hectopascals - hPa). 
            
- Haute pression (>1013 hPa) : anticyclone = beau temps ☀️
- Basse pression (<1013 hPa) : dépression = mauvais temps 🌧️

Le baromètre mesure la pression. Au sommet de l'Everest, la pression n'est que 1/3 de celle au niveau de la mer !";
        }

        // ============ MÉTÉOROLOGIE ============
        if ($this->matchesFlexible('/meteorologie|prevoir|prevision|satellite|radar/i', $message)) {
            return "🛰️ La météorologie étudie l'atmosphère pour prévoir le temps. Outils : satellites (images nuages), radars (pluie), stations météo (température, vent), ballons-sondes (altitude). Les supercalculateurs analysent des millions de données ! Fiabilité : 90% à 24h, 70% à 7 jours.";
        }

        // ============ CONSEILS PRATIQUES ============
        if ($this->matchesFlexible('/vetement|habiller|porter|quoi mettre/i', $message)) {
            if (isset($context['temperature'])) {
                return $this->getClothingAdvice($context['temperature'], $context['description'] ?? '');
            }
            return "👕 Habillez-vous selon la météo : <10°C manteau chaud, 10-20°C veste légère, >20°C t-shirt. Pluie = imperméable. Vent = coupe-vent. Multicouche = meilleure isolation !";
        }

        if ($this->matchesFlexible('/sport|jogging|course|velo|randonnee/i', $message)) {
            return "🏃 Météo idéale pour le sport : 10-20°C, peu de vent, pas de pluie. Évitez : <0°C ou >30°C (risque hypothermie/hyperthermie), orage (foudre), pollution élevée. Hydratez-vous bien et adaptez votre effort !";
        }

        if ($this->matchesFlexible('/jardinage|plante|arroser|jardin/i', $message)) {
            return "🌱 Jardinage et météo : arrosez tôt le matin ou tard le soir pour éviter l'évaporation. Pluie prévue ? Économisez l'eau ! Gel annoncé ? Protégez vos plantes fragiles. Vent fort ? Tuteurez les jeunes arbres.";
        }

        // ============ SALUTATIONS ============
        if ($this->matchesFlexible('/^(bonjour|salut|hello|coucou|hey)/i', $message)) {
            return "👋 Bonjour ! Je suis votre expert météo 🌤️. Je peux vous donner la météo de n'importe quelle ville ! Demandez-moi par exemple 'Quelle est la température à Paris ?' ou 'Météo à New York'. Je peux aussi répondre à vos questions sur la météorologie !";
        }

        if ($this->matchesFlexible('/merci|thanks/i', $message)) {
            return "😊 Avec plaisir ! N'hésitez pas si vous avez d'autres questions météo. Bonne journée ! ☀️";
        }

        if ($this->matchesFlexible('/au revoir|bye|a plus|a bientot/i', $message)) {
            return "👋 Au revoir ! Restez au sec et profitez du beau temps ! 🌈";
        }

        // ============ AIDE ============
        if ($this->matchesFlexible('/aide|help|quoi|que (peux|sais)/i', $message)) {
            return "🤖 Je suis un expert météo ! Je peux :

🌍 Donner la météo d'une ville :
- 'Quelle est la température à Paris ?'
- 'Météo à New York'
- 'Il fait combien à Tokyo ?'

📚 Répondre à vos questions :
☀️ Soleil, température, UV
🌧️ Pluie, orages, éclairs
❄️ Neige, grêle, gel
💨 Vent, tornades, ouragans
☁️ Nuages, brouillard
🌈 Arc-en-ciel, saisons
🌍 Climat, réchauffement
📊 Pression, humidité

Essayez-moi ! 😊";
        }

        // ============ RÉPONSE PAR DÉFAUT ============
        return "🤔 Je peux vous donner la météo de n'importe quelle ville ! Demandez-moi par exemple :

- 'Quelle est la température à Paris ?'
- 'Météo à Londres'
- 'Il fait combien à Tokyo ?'

Ou posez-moi des questions météo comme :
- 'Pourquoi il pleut ?'
- 'C'est quoi un arc-en-ciel ?'

Tapez 'aide' pour voir toutes mes capacités ! 😊";
    }

    private function getWeatherForCity($cityName)
    {
        // Nettoyer le nom de la ville
        $cityName = ucfirst(strtolower(trim($cityName)));
        
        // Chercher dans la base de données
        $weather = WeatherData::where('city', 'LIKE', $cityName)
            ->orWhere('city', 'LIKE', '%' . $cityName . '%')
            ->first();

        // Si trouvé et récent (moins de 30 min), utiliser les données en cache
        if ($weather && $weather->updated_at->diffInMinutes(now()) < 30) {
            return $this->formatWeatherResponse($weather);
        }

        // Sinon, récupérer depuis l'API
        try {
            $response = Http::get(self::API_URL, [
                'q' => $cityName,
                'appid' => self::API_KEY,
                'units' => 'metric',
                'lang' => 'fr',
            ]);

            if ($response->successful()) {
                $data = $response->json();

                // Sauvegarder en base de données
                $weather = WeatherData::updateOrCreate(
                    ['city' => $data['name']],
                    [
                        'country' => $this->getCountryName($data['sys']['country']),
                        'temperature' => $data['main']['temp'],
                        'description' => $data['weather'][0]['description'],
                        'icon' => $data['weather'][0]['icon'],
                        'humidity' => $data['main']['humidity'] ?? null,
                        'wind_speed' => $data['wind']['speed'] ?? null,
                        'pressure' => $data['main']['pressure'] ?? null,
                        'feels_like' => $data['main']['feels_like'] ?? null,
                    ]
                );

                return $this->formatWeatherResponse($weather);
            }

            return "❌ Désolé, je n'ai pas trouvé la ville '$cityName'. Vérifiez l'orthographe ou essayez une grande ville proche.";

        } catch (\Exception $e) {
            return "❌ Erreur lors de la récupération des données météo. Veuillez réessayer.";
        }
    }

    private function formatWeatherResponse($weather)
    {
        $temp = round($weather->temperature);
        $feelsLike = $weather->feels_like ? round($weather->feels_like) : null;
        
        $response = "🌍 {$weather->city}, {$weather->country}\n\n";
        $response .= "🌡️ Température : {$temp}°C";
        
        if ($feelsLike && abs($temp - $feelsLike) > 2) {
            $response .= " (ressenti : {$feelsLike}°C)";
        }
        
        $response .= "\n☁️ Conditions : {$weather->description}";
        
        if ($weather->humidity) {
            $response .= "\n💧 Humidité : {$weather->humidity}%";
        }
        
        if ($weather->wind_speed) {
            $windKmh = round($weather->wind_speed * 3.6);
            $response .= "\n💨 Vent : {$windKmh} km/h";
        }
        
        if ($weather->pressure) {
            $response .= "\n📊 Pression : {$weather->pressure} hPa";
        }
        
        $response .= "\n\n" . $this->getAdviceByTemp($temp);
        
        return $response;
    }

    private function analyzeTemperature($temp, $city)
    {
        $emoji = $temp > 30 ? '🔥' : ($temp > 20 ? '🌞' : ($temp > 10 ? '🌤️' : ($temp > 0 ? '🧥' : '❄️')));
        
        $cityText = $city ? " à $city" : "";
        
        if ($temp > 35) {
            return "$emoji Canicule{$cityText} avec {$temp}°C ! Restez hydraté, évitez le soleil 12h-16h, portez des vêtements légers et clairs. Les personnes âgées et enfants sont vulnérables. Cherchez la fraîcheur !";
        } elseif ($temp > 25) {
            return "$emoji Il fait chaud{$cityText} avec {$temp}°C ! Parfait pour la plage 🏖️ mais pensez à la crème solaire SPF 30+, buvez beaucoup d'eau et portez un chapeau.";
        } elseif ($temp > 15) {
            return "$emoji Température agréable{$cityText} : {$temp}°C. Idéal pour les activités extérieures ! Une veste légère peut être utile en soirée.";
        } elseif ($temp > 5) {
            return "$emoji Il fait frais{$cityText} avec {$temp}°C. Portez un pull ou une veste. Bon moment pour une promenade dynamique !";
        } elseif ($temp > -5) {
            return "$emoji Il fait froid{$cityText} : {$temp}°C ! Habillez-vous chaudement : manteau, écharpe, gants. Attention au verglas sur les routes.";
        } else {
            return "$emoji Températures glaciales{$cityText} : {$temp}°C ! Risque de gelures. Superposez les vêtements, protégez extrémités (mains, oreilles, nez). Limitez le temps dehors.";
        }
    }

    private function getAdviceByTemp($temp)
    {
        if ($temp > 30) return "🔥 Restez hydraté et évitez le soleil aux heures chaudes !";
        if ($temp > 20) return "☀️ Temps parfait pour sortir !";
        if ($temp > 10) return "🧥 Une veste légère sera utile.";
        if ($temp > 0) return "🧤 Habillez-vous chaudement !";
        return "❄️ Attention au gel, couvrez-vous bien !";
    }

    private function getClothingAdvice($temp, $description)
    {
        $advice = "👕 Conseils vestimentaires pour {$temp}°C : ";
        
        if ($temp > 25) {
            $advice .= "T-shirt, short, sandales. Chapeau et lunettes de soleil recommandés ! ☀️";
        } elseif ($temp > 15) {
            $advice .= "T-shirt + veste légère ou pull fin. Pantalon confortable.";
        } elseif ($temp > 5) {
            $advice .= "Pull chaud, pantalon, veste. Éventuellement écharpe.";
        } else {
            $advice .= "Manteau épais, écharpe, gants, bonnet. Multicouches recommandé ! ❄️";
        }
        
        if (str_contains($description, 'pluie') || str_contains($description, 'rain')) {
            $advice .= " ☔ N'oubliez pas un parapluie ou un imperméable !";
        }
        
        return $advice;
    }

    private function getCountryName($code)
    {
        $countries = [
            "AF" => "Afghanistan",
            "ZA" => "Afrique du Sud",
            "AL" => "Albanie",
            "DZ" => "Algérie",
            "DE" => "Allemagne",
            "AD" => "Andorre",
            "AO" => "Angola",
            "AI" => "Anguilla",
            "AQ" => "Antarctique",
            "AG" => "Antigua-et-Barbuda",
            "SA" => "Arabie saoudite",
            "AR" => "Argentine",
            "AM" => "Arménie",
            "AW" => "Aruba",
            "AU" => "Australie",
            "AT" => "Autriche",
            "AZ" => "Azerbaïdjan",
            "BS" => "Bahamas",
            "BH" => "Bahreïn",
            "BD" => "Bangladesh",
            "BB" => "Barbade",
            "BY" => "Biélorussie",
            "BE" => "Belgique",
            "BZ" => "Belize",
            "BJ" => "Bénin",
            "BM" => "Bermudes",
            "BT" => "Bhoutan",
            "BO" => "Bolivie",
            "BA" => "Bosnie-Herzégovine",
            "BW" => "Botswana",
            "BR" => "Brésil",
            "BN" => "Brunei",
            "BG" => "Bulgarie",
            "BF" => "Burkina Faso",
            "BI" => "Burundi",
            "KH" => "Cambodge",
            "CM" => "Cameroun",
            "CA" => "Canada",
            "CV" => "Cap-Vert",
            "CL" => "Chili",
            "CN" => "Chine",
            "CY" => "Chypre",
            "CO" => "Colombie",
            "KM" => "Comores",
            "KP" => "Corée du Nord",
            "KR" => "Corée du Sud",
            "CR" => "Costa Rica",
            "CI" => "Côte d'Ivoire",
            "HR" => "Croatie",
            "CU" => "Cuba",
            "CW" => "Curaçao",
            "DK" => "Danemark",
            "DJ" => "Djibouti",
            "DM" => "Dominique",
            "EG" => "Égypte",
            "AE" => "Émirats arabes unis",
            "EC" => "Équateur",
            "ER" => "Érythrée",
            "FM" => "États fédérés de Micronésie",
            "ES" => "Espagne",
            "EE" => "Estonie",
            "US" => "États-Unis",
            "ET" => "Éthiopie",
            "FJ" => "Fidji",
            "FI" => "Finlande",
            "FR" => "France",
            "GA" => "Gabon",
            "GM" => "Gambie",
            "GE" => "Géorgie",
            "GS" => "Géorgie du Sud-et-les Îles Sandwich du Sud",
            "GH" => "Ghana",
            "GI" => "Gibraltar",
            "GR" => "Grèce",
            "GD" => "Grenade",
            "GL" => "Groenland",
            "GP" => "Guadeloupe",
            "GU" => "Guam",
            "GT" => "Guatemala",
            "GG" => "Guernesey",
            "GN" => "Guinée",
            "GQ" => "Guinée équatoriale",
            "GW" => "Guinée-Bissau",
            "GY" => "Guyana",
            "GF" => "Guyane",
            "HT" => "Haïti",
            "HN" => "Honduras",
            "HK" => "Hong Kong",
            "HU" => "Hongrie",
            "CX" => "Île Christmas",
            "BV" => "Île Bouvet",
            "NF" => "Île Norfolk",
            "AX" => "Îles Åland",
            "KY" => "Îles Caïmans",
            "CC" => "Îles Cocos",
            "CK" => "Îles Cook",
            "FO" => "Îles Féroé",
            "HM" => "Îles Heard-et-MacDonald",
            "FK" => "Îles Malouines",
            "MP" => "Îles Mariannes du Nord",
            "MH" => "Îles Marshall",
            "UM" => "Îles mineures éloignées des États-Unis",
            "TC" => "Îles Turques-et-Caïques",
            "VG" => "Îles Vierges britanniques",
            "VI" => "Îles Vierges des États-Unis",
            "IN" => "Inde",
            "ID" => "Indonésie",
            "IQ" => "Irak",
            "IR" => "Iran",
            "IE" => "Irlande",
            "IS" => "Islande",
            "IL" => "Israël",
            "IT" => "Italie",
            "JM" => "Jamaïque",
            "JP" => "Japon",
            "JE" => "Jersey",
            "JO" => "Jordanie",
            "KZ" => "Kazakhstan",
            "KE" => "Kenya",
            "KG" => "Kirghizistan",
            "KI" => "Kiribati",
            "KW" => "Koweït",
            "LA" => "Laos",
            "LS" => "Lesotho",
            "LV" => "Lettonie",
            "LB" => "Liban",
            "LR" => "Liberia",
            "LY" => "Libye",
            "LI" => "Liechtenstein",
            "LT" => "Lituanie",
            "LU" => "Luxembourg",
            "MO" => "Macao",
            "MK" => "Macédoine du Nord",
            "MG" => "Madagascar",
            "MY" => "Malaisie",
            "MW" => "Malawi",
            "MV" => "Maldives",
            "ML" => "Mali",
            "MT" => "Malte",
            "MA" => "Maroc",
            "MQ" => "Martinique",
            "MU" => "Maurice",
            "MR" => "Mauritanie",
            "YT" => "Mayotte",
            "MX" => "Mexique",
            "MD" => "Moldavie",
            "MC" => "Monaco",
            "MN" => "Mongolie",
            "ME" => "Monténégro",
            "MS" => "Montserrat",
            "MZ" => "Mozambique",
            "NA" => "Namibie",
            "NR" => "Nauru",
            "NP" => "Népal",
            "NI" => "Nicaragua",
            "NE" => "Niger",
            "NG" => "Nigeria",
            "NU" => "Niue",
            "NO" => "Norvège",
            "NC" => "Nouvelle-Calédonie",
            "NZ" => "Nouvelle-Zélande",
            "OM" => "Oman",
            "UG" => "Ouganda",
            "UZ" => "Ouzbékistan",
            "PK" => "Pakistan",
            "PW" => "Palaos",
            "PS" => "Palestine",
            "PA" => "Panama",
            "PG" => "Papouasie-Nouvelle-Guinée",
            "PY" => "Paraguay",
            "PE" => "Pérou",
            "PH" => "Philippines",
            "PL" => "Pologne",
            "PF" => "Polynésie française",
            "PT" => "Portugal",
            "QA" => "Qatar",
            "RE" => "La Réunion",
            "EH" => "République arabe sahraouie démocratique",
            "CF" => "République centrafricaine",
            "CD" => "République démocratique du Congo",
            "DO" => "République dominicaine",
            "CG" => "République du Congo",
            "RO" => "Roumanie",
            "GB" => "Royaume-Uni",
            "RU" => "Russie",
            "RW" => "Rwanda",
            "BL" => "Saint-Barthélemy",
            "KN" => "Saint-Christophe-et-Niévès",
            "SM" => "Saint-Marin",
            "MF" => "Saint-Martin (partie française)",
            "SX" => "Saint-Martin (partie néerlandaise)",
            "PM" => "Saint-Pierre-et-Miquelon",
            "VA" => "Saint-Siège",
            "VC" => "Saint-Vincent-et-les-Grenadines",
            "SH" => "Saint-Hélène",
            "LC" => "Sainte-Lucie",
            "SV" => "Salvador",
            "AS" => "Samoa américaines",
            "WS" => "Samoa",
            "ST" => "Sao Tomé-et-Principe",
            "SN" => "Sénégal",
            "RS" => "Serbie",
            "SC" => "Seychelles",
            "SL" => "Sierra Leone",
            "SG" => "Singapour",
            "SK" => "Slovaquie",
            "SI" => "Slovénie",
            "SO" => "Somalie",
            "SD" => "Soudan",
            "SS" => "Soudan du Sud",
            "LK" => "Sri Lanka",
            "SE" => "Suède",
            "CH" => "Suisse",
            "SR" => "Suriname",
            "SJ" => "Svalbard et île Jan Mayen",
            "SZ" => "Eswatini",
            "SY" => "Syrie",
            "TJ" => "Tadjikistan",
            "TW" => "Taïwan",
            "TZ" => "Tanzanie",
            "TD" => "Tchad",
            "CZ" => "Tchéquie",
            "TF" => "Terres australes et antarctiques françaises",
            "IO" => "Territoire britannique de l'océan Indien",
            "TH" => "Thaïlande",
            "TL" => "Timor oriental",
            "TG" => "Togo",
            "TK" => "Tokelau",
            "TO" => "Tonga",
            "TT" => "Trinité-et-Tobago",
            "TN" => "Tunisie",
            "TM" => "Turkménistan",
            "TR" => "Turquie",
            "TV" => "Tuvalu",
            "UA" => "Ukraine",
            "UY" => "Uruguay",
            "VU" => "Vanuatu",
            "VE" => "Venezuela",
            "VN" => "Vietnam",
            "WF" => "Wallis-et-Futuna",
            "YE" => "Yémen",
            "ZM" => "Zambie",
            "ZW" => "Zimbabwe",
        ];

        return $countries[$code] ?? $code;
    }
}