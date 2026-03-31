<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\EtudiantController;
use App\Http\Controllers\ProfesseurController;
use App\Http\Controllers\MatiereController;
use App\Http\Controllers\NoteController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\ClasseController;

// ==========================================================
// AUTHENTIFICATION PROFESSEUR
// ==========================================================

Route::post('/login', [ProfesseurController::class, 'login']);
Route::post('/register', [ProfesseurController::class, 'register']);
Route::post('/professeur/reset-password', [ProfesseurController::class, 'resetPassword']);

// ==========================================================
// AUTHENTIFICATION ÉTUDIANT
// ==========================================================

Route::post('/etudiant/login', [EtudiantController::class, 'login']);
Route::post('/etudiant/reset-password', [EtudiantController::class, 'resetPassword']);

// ==========================================================
// AUTHENTIFICATION ADMIN
// ==========================================================

Route::post('/admin/login', [AdminController::class, 'login']);
Route::post('/admin/reset-password', [AdminController::class, 'resetPassword']);

// ==========================================================
// GESTION PROFESSEURS (admin seulement)
// ==========================================================

Route::get('/admin/professeurs',                   [AdminController::class, 'listeProfesseurs']);
Route::post('/admin/professeurs',                  [AdminController::class, 'creerProfesseur']);
Route::put('/admin/professeurs/{id}/matieres',     [AdminController::class, 'modifierMatieres']);
Route::delete('/admin/professeurs/{id}',           [AdminController::class, 'supprimerProfesseur']);

// ==========================================================
// ÉTUDIANTS
// ==========================================================

Route::get('/etudiants',         [EtudiantController::class, 'index']);
Route::post('/etudiants',        [EtudiantController::class, 'store']);
Route::put('/etudiants/{id}',    [EtudiantController::class, 'update']);
Route::delete('/etudiants/{id}', [EtudiantController::class, 'destroy']);

// ==========================================================
// CLASSES
// ==========================================================

Route::get('/classes',                    [ClasseController::class, 'index']);
Route::get('/classes/{id}/etudiants',     [ClasseController::class, 'etudiants']);
Route::get('/classes/{id}/moyennes',      [ClasseController::class, 'moyennes']);

// ==========================================================
// MATIÈRES
// ==========================================================

Route::get('/matieres',                   [MatiereController::class, 'index']);
Route::get('/professeurs/{id}/matieres',  [MatiereController::class, 'matieresProf']);
Route::post('/professeurs/{id}/matieres', [MatiereController::class, 'assignerMatieres']);

// ==========================================================
// NOTES
// ==========================================================

Route::get('/etudiants/{id}/notes',  [NoteController::class, 'getNotesEtudiant']);
Route::post('/notes',                [NoteController::class, 'store']);
Route::get('/matieres/{id}/notes',   [NoteController::class, 'getNotesByMatiere']);