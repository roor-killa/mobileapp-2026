<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\EtudiantController;
use App\Http\Controllers\ProfesseurController;
use App\Http\Controllers\MatiereController;
use App\Http\Controllers\NoteController;

/*
|--------------------------------------------------------------------------
| Routes API
|--------------------------------------------------------------------------
*/

// ─── AUTHENTIFICATION ───────────────────────────────────────────────────────
// POST /api/login    → connexion professeur
Route::post('/login', [ProfesseurController::class, 'login']);
// POST /api/register → inscription professeur
Route::post('/register', [ProfesseurController::class, 'register']);

// ─── ÉTUDIANTS ──────────────────────────────────────────────────────────────
// GET    /api/etudiants       → liste tous les étudiants
Route::get('/etudiants',         [EtudiantController::class, 'index']);
// POST   /api/etudiants       → ajoute un étudiant
Route::post('/etudiants',        [EtudiantController::class, 'store']);
// PUT    /api/etudiants/{id}  → modifie un étudiant
Route::put('/etudiants/{id}',    [EtudiantController::class, 'update']);
// DELETE /api/etudiants/{id}  → supprime un étudiant
Route::delete('/etudiants/{id}', [EtudiantController::class, 'destroy']);

// ─── MATIÈRES ───────────────────────────────────────────────────────────────
// GET  /api/matieres                        → liste toutes les matières
Route::get('/matieres',                      [MatiereController::class, 'index']);
// GET  /api/professeurs/{id}/matieres       → matières d'un professeur
Route::get('/professeurs/{id}/matieres',     [MatiereController::class, 'matieresProf']);
// POST /api/professeurs/{id}/matieres       → assigner des matières à un professeur
Route::post('/professeurs/{id}/matieres',    [MatiereController::class, 'assignerMatieres']);

// ─── NOTES ──────────────────────────────────────────────────────────────────
// GET  /api/etudiants/{id}/notes  → notes d'un étudiant
Route::get('/etudiants/{id}/notes',          [NoteController::class, 'getNotesEtudiant']);
// POST /api/notes                 → ajouter/modifier des notes
Route::post('/notes',                        [NoteController::class, 'store']);
// GET  /api/matieres/{id}/notes   → notes de tous les étudiants pour une matière
Route::get('/matieres/{id}/notes',           [NoteController::class, 'getNotesByMatiere']);