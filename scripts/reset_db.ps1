$ErrorActionPreference = "Stop"

function WriteStep($msg) {
  Write-Host ""
  Write-Host "==> $msg" -ForegroundColor Cyan
}

function RequireCommand($name) {
  if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
    throw "Commande introuvable: $name. Vérifie que c'est installé et dans le PATH."
  }
}

$repo = Split-Path -Parent $PSScriptRoot
$backend = Join-Path $repo "infrastructure\back-laravel"

RequireCommand "php"

WriteStep "1) Préparer .env et base SQLite"
Set-Location $backend
if (-not (Test-Path ".env") -and (Test-Path ".env.example")) {
  Copy-Item ".env.example" ".env"
}
if (-not (Test-Path "database\database.sqlite")) {
  New-Item -ItemType File -Path "database\database.sqlite" | Out-Null
}

WriteStep "2) Regénérer la base (migrate:fresh --seed)"
php artisan migrate:fresh --seed

Write-Host ""
Write-Host "Base de données recréée et remplie avec les données de test." -ForegroundColor Green

