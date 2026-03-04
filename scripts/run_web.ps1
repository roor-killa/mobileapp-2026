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
$app = Join-Path $repo "project\firstapp"

RequireCommand "php"
RequireCommand "flutter"

WriteStep "1) Démarrage backend Laravel (serveur API)"
if (-not (Test-Path (Join-Path $backend "vendor\autoload.php"))) {
  Write-Host "vendor/ absent -> lance d'abord: composer install (dans $backend)" -ForegroundColor Yellow
} else {
  $backendCmd = "cd `"$backend`"; php artisan serve --host=127.0.0.1 --port=8000"
  Start-Process powershell -ArgumentList "-NoProfile","-ExecutionPolicy","Bypass","-Command",$backendCmd | Out-Null
  Write-Host "Backend lancé sur http://127.0.0.1:8000 (API: /api)" -ForegroundColor Green
}

WriteStep "2) Lancer l'app Flutter dans Chrome"
$runCmd = "cd `"$app`"; flutter pub get; flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api"
Start-Process powershell -ArgumentList "-NoProfile","-ExecutionPolicy","Bypass","-Command",$runCmd | Out-Null

Write-Host ""
Write-Host "Terminé. L'app va s'ouvrir dans Chrome, connectée à http://127.0.0.1:8000/api." -ForegroundColor Green

