<?php
use App\Http\Controllers\EtudiantController;
use Illuminate\Support\Facades\Route;

// Route pour récupérer tous les étudiants
Route::get('/etudiants', [EtudiantController::class, 'index']);

// Route pour ajouter un étudiant
Route::post('/etudiants', [EtudiantController::class, 'store']);

// Route pour modifier un étudiant (par son id)
Route::put('/etudiants/{id}', [EtudiantController::class, 'update']);

// Route pour supprimer un étudiant (par son id)
Route::delete('/etudiants/{id}', [EtudiantController::class, 'destroy']);

Route::post('/etudiants/{id}', [EtudiantController::class, 'update']);