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

WriteStep "2) Lancement de l'émulateur Android"
$emulators = (flutter emulators) 2>$null
if (-not $emulators) {
  throw "Aucun émulateur trouvé. Crée un AVD dans Android Studio (Device Manager) puis réessaie."
}

# Choix par défaut: le premier ID listé par flutter emulators (sans dépendre des caractères spéciaux)
$emuLine = $emulators | Where-Object { $_ -and ($_ -notmatch '^\s*Id\s') -and ($_ -notmatch '^\s*Name\s') -and ($_ -notmatch '^\s*Manufacturer\s') -and ($_ -notmatch '^\s*Platform\s') } | Select-Object -First 1
if (-not $emuLine) { throw "Impossible de détecter une ligne d'émulateur dans 'flutter emulators'." }
$emuId = ($emuLine -split '\s+')[0]
if (-not $emuId) { throw "Impossible d'extraire l'ID émulateur depuis: $emuLine" }

Write-Host "Émulateur détecté: $emuId" -ForegroundColor Green

try {
  flutter emulators --launch $emuId | Out-Null
} catch {
  Write-Host "Échec de 'flutter emulators --launch $emuId' ($_). Tentative via emulator.exe directe..." -ForegroundColor Yellow
}

# Fallback: lancer directement l'émulateur Android si possible
$sdkRoot = @($env:ANDROID_SDK_ROOT, $env:ANDROID_HOME, "C:\Users\Fayzel\AppData\Local\Android\sdk") | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if ($sdkRoot) {
  $emuExe = Join-Path $sdkRoot "emulator\emulator.exe"
  if (Test-Path $emuExe) {
    $avdName = ($emuId -replace '_', ' ')
    Write-Host "Tentative de lancement direct: $emuExe -avd '$avdName'" -ForegroundColor DarkCyan
    Start-Process $emuExe -ArgumentList @("-avd", $avdName) | Out-Null
  }
}

WriteStep "3) Attente que l'émulateur soit prêt"
$deadline = (Get-Date).AddMinutes(3)
$deviceId = $null
while ((Get-Date) -lt $deadline) {
  $devices = flutter devices
  $line = $devices | Select-String -Pattern "emulator-\d+" | Select-Object -First 1
  if ($line) {
    $match = [regex]::Match($line.ToString(), "emulator-\d+")
    if ($match.Success) {
      $deviceId = $match.Value
    }
    break
  }
  Start-Sleep -Seconds 3
}
if (-not $deviceId) { throw "L'émulateur n'apparaît pas dans 'flutter devices' (timeout)." }
Write-Host "Device OK: $deviceId" -ForegroundColor Green

WriteStep "4) Lancer l'app Flutter sur l'émulateur"
$runCmd = "cd `"$app`"; flutter pub get; flutter run -d $deviceId --dart-define=API_BASE_URL=http://10.0.2.2:8000/api"
Start-Process powershell -ArgumentList "-NoProfile","-ExecutionPolicy","Bypass","-Command",$runCmd | Out-Null

WriteHost ""
Write-Host "Terminé. L'app va s'installer et apparaître sur l'émulateur." -ForegroundColor Green
Write-Host "Astuce: sur la Home de l'émulateur, ouvre le tiroir d'apps, maintiens 'MyBank' et glisse l'icône sur l'écran d'accueil." -ForegroundColor Gray

