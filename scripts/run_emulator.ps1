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

# Trouver le SDK Android (emulator.exe)
$sdkCandidates = @(
  $env:ANDROID_SDK_ROOT,
  $env:ANDROID_HOME,
  "$env:LOCALAPPDATA\Android\sdk",
  "C:\Users\Fayzel\AppData\Local\Android\sdk"
)
$sdkRoot = $sdkCandidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
$emuExe = $null
if ($sdkRoot) {
  $emuExe = Join-Path $sdkRoot "emulator\emulator.exe"
  if (-not (Test-Path $emuExe)) { $emuExe = $null }
}

$avdToLaunch = $null

# Méthode 1 : emulator -list-avds puis lancer avec le nom exact (le plus fiable sur Windows)
if ($emuExe) {
  try {
    $avdList = & $emuExe -list-avds 2>$null
    if ($avdList -and ($avdList | Where-Object { $_.Trim() })) {
      $avdToLaunch = ($avdList | Where-Object { $_.Trim() } | Select-Object -First 1).Trim()
      Write-Host "AVD trouvé: $avdToLaunch" -ForegroundColor Green
    }
  } catch {
    Write-Host "emulator -list-avds a échoué: $_" -ForegroundColor Yellow
  }
}

# Méthode 2 : parser flutter emulators si pas d'AVD trouvé
if (-not $avdToLaunch) {
  $emulators = (flutter emulators) 2>$null
  if (-not $emulators) {
    throw "Aucun émulateur trouvé. Ouvre Android Studio > Device Manager > Create Device pour créer un AVD, puis réessaie."
  }
  $emuLine = $emulators | Where-Object { $_ -and ($_ -notmatch '^\s*Id\s') -and ($_ -notmatch '^\s*Name\s') -and ($_ -notmatch '^\s*Manufacturer\s') -and ($_ -notmatch '^\s*Platform\s') -and ($_ -notmatch '^To run') -and ($_ -notmatch '^To create') } | Select-Object -First 1
  if ($emuLine) {
    # Premier mot ou premier token avant " • " (format Flutter: "Medium_Phone_API_36.1 • Medium Phone...")
    $avdToLaunch = ($emuLine -split '•')[0].Trim()
    if ($avdToLaunch) { Write-Host "Émulateur (flutter): $avdToLaunch" -ForegroundColor Green }
  }
}

if (-not $avdToLaunch) {
  throw "Aucun AVD détecté. Crée un appareil virtuel dans Android Studio (Device Manager) puis relance ce script."
}

# Lancer l'émulateur : priorité à emulator.exe -avd (nom exact)
$emulatorLaunched = $false
if ($emuExe -and $avdToLaunch) {
  Write-Host "Lancement: emulator.exe -avd `"$avdToLaunch`"" -ForegroundColor Cyan
  Start-Process -FilePath $emuExe -ArgumentList "-avd", $avdToLaunch -WindowStyle Normal
  $emulatorLaunched = $true
}

if (-not $emulatorLaunched) {
  Write-Host "Tentative: flutter emulators --launch $avdToLaunch" -ForegroundColor Cyan
  Start-Process -FilePath "flutter" -ArgumentList "emulators", "--launch", $avdToLaunch -WindowStyle Normal -ErrorAction SilentlyContinue
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

Write-Host ""
Write-Host "Terminé. L'app va s'installer et apparaître sur l'émulateur." -ForegroundColor Green
Write-Host "Astuce: sur la Home de l'émulateur, ouvre le tiroir d'apps, maintiens 'MyBank' et glisse l'icône sur l'écran d'accueil." -ForegroundColor Gray

