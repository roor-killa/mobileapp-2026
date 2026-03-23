<!DOCTYPE html>
<html>
<head>
    <title>Alerte de sécurité</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
    <h2 style="color: #d9534f;">Nouvelle connexion détectée</h2>
    <p>Bonjour <strong>{{ $userName }}</strong>,</p>
    <p>Nous avons détecté une nouvelle connexion à votre compte bancaire le {{ date('d/m/Y à H:i') }}.</p>
    <p>Si c'était vous, vous pouvez ignorer cet e-mail. Si vous n'êtes pas à l'origine de cette connexion, nous vous conseillons de changer votre mot de passe immédiatement.</p>
    <br>
    <p>L'équipe de sécurité FirstApp</p>
</body>
</html>