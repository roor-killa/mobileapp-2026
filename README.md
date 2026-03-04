
# 🏦 Yann's BANK - Application de Gestion Bancaire

Projet réalisé dans le cadre de la **Licence 3 Informatique** à l'Université des Antilles.  
**Développeuse :** Yannelle Negui (Mariloud)

## 📋 Présentation du projet
Yann's BANK est une application mobile et web moderne permettant de consulter son solde bancaire en temps réel. Le projet met en œuvre une communication sécurisée entre une interface **Flutter** et une API **Laravel**.

## 🏗️ Architecture Technique
L'application repose sur une architecture découplée :
- **Frontend :** Flutter (Multiplateforme : Web & Android)
- **Backend :** API REST avec Laravel 11
- **Base de données :** MySQL / SQLite via XAMPP
- **Serveur local :** PHP Artisan

## 🔐 Aspects Cybersécurité (L3 Info)
Dans le cadre de mon cursus en systèmes et réseaux, ce projet intègre des notions clés :
- **Consommation d'API REST :** Gestion des flux de données JSON.
- **Sécurisation des accès :** Isolation du backend et du frontend.
- **Gestion des erreurs :** Traitement des codes HTTP (200, 404, etc.).

## 🚀 Installation et Lancement

### 1. Backend (Laravel)
```powershell
cd infrastructure/back-laravel
php artisan serve