<!DOCTYPE html>
<html>
<head>
    <title>Confirmation de virement</title>
</head>
<body style="font-family: Arial, sans-serif; color: #333;">
    <h2 style="color: #28a745;">Virement effectué avec succès !</h2>
    <p>Bonjour,</p>
    <p>Nous vous confirmons que votre virement de <strong>{{ $amount }} €</strong> vers <strong>{{ $receiverName }}</strong> a bien été traité.</p>
    <p>Date de l'opération : {{ date('d/m/Y à H:i') }}</p>
    <hr>
    <p>Merci de votre confiance,<br>L'équipe FirstApp</p>
</body>
</html>