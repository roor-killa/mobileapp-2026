<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\WeatherData;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class WeatherController extends Controller
{
    private const API_KEY = '937ee9f29655fadcad8c6a7dc5d00a69';
    private const API_URL = 'https://api.openweathermap.org/data/2.5/weather';

    public function fetchAndStore(Request $request)
    {
        $request->validate([
            'city' => 'required|string',
        ]);

        $cityName = $request->city;

        try {
            $response = Http::get(self::API_URL, [
                'q' => $cityName,
                'appid' => self::API_KEY,
                'units' => 'metric',
                'lang' => 'fr',
            ]);

            if ($response->successful()) {
                $data = $response->json();

                $weatherData = WeatherData::updateOrCreate(
                    ['city' => $data['name']],
                    [
                        'country' => $this->getCountryName($data['sys']['country']),
                        'temperature' => $data['main']['temp'],
                        'description' => $data['weather'][0]['description'],
                        'icon' => $data['weather'][0]['icon'],
                        'humidity' => $data['main']['humidity'],
                        'wind_speed' => $data['wind']['speed'],
                        'pressure' => $data['main']['pressure'],
                        'feels_like' => $data['main']['feels_like'],
                    ]
                );

                return response()->json([
                    'success' => true,
                    'data' => $weatherData,
                ]);
            }

            return response()->json([
                'success' => false,
                'message' => 'Ville introuvable',
            ], 404);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération des données',
            ], 500);
        }
    }

    public function getWeather(Request $request)
    {
        $request->validate([
            'city' => 'required|string',
        ]);

        $weather = WeatherData::where('city', 'LIKE', '%' . $request->city . '%')
            ->first();

        if ($weather) {
            // Vérifier si les données ont plus de 30 minutes
            if ($weather->updated_at->diffInMinutes(now()) > 30) {
                // Rafraîchir les données
                $this->refreshWeatherData($weather->city);
                $weather->refresh();
            }

            return response()->json([
                'success' => true,
                'data' => $weather,
            ]);
        }

        // Si pas en base, récupérer depuis l'API
        return $this->fetchAndStore($request);
    }

    private function refreshWeatherData($city)
    {
        try {
            $response = Http::get(self::API_URL, [
                'q' => $city,
                'appid' => self::API_KEY,
                'units' => 'metric',
                'lang' => 'fr',
            ]);

            if ($response->successful()) {
                $data = $response->json();

                WeatherData::where('city', $city)->update([
                    'temperature' => $data['main']['temp'],
                    'description' => $data['weather'][0]['description'],
                    'icon' => $data['weather'][0]['icon'],
                    'humidity' => $data['main']['humidity'],
                    'wind_speed' => $data['wind']['speed'],
                    'pressure' => $data['main']['pressure'],
                    'feels_like' => $data['main']['feels_like'],
                ]);
            }
        } catch (\Exception $e) {
            // Ignorer les erreurs de rafraîchissement
        }
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