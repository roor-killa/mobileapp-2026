<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Réinitialisation du mot de passe</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 520px;
            margin: 40px auto;
            background: #ffffff;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
        }
        .header {
            background: linear-gradient(135deg, #6C63FF 0%, #8B5CF6 100%);
            padding: 40px 32px;
            text-align: center;
        }
        .header h1 {
            color: #ffffff;
            margin: 0;
            font-size: 24px;
            font-weight: 700;
        }
        .header p {
            color: rgba(255,255,255,0.8);
            margin: 8px 0 0;
            font-size: 14px;
        }
        .body {
            padding: 36px 32px;
        }
        .greeting {
            font-size: 16px;
            color: #1a1a2e;
            margin-bottom: 16px;
        }
        .text {
            font-size: 14px;
            color: #555;
            line-height: 1.6;
            margin-bottom: 16px;
        }
        .token-box {
            background: #f0eeff;
            border: 2px dashed #6C63FF;
            border-radius: 12px;
            padding: 20px;
            text-align: center;
            margin: 24px 0;
        }
        .token-label {
            font-size: 12px;
            color: #888;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 8px;
        }
        .token-value {
            font-size: 28px;
            font-weight: 700;
            color: #6C63FF;
            letter-spacing: 6px;
            font-family: 'Courier New', monospace;
        }
        .warning {
            background: #fff8e1;
            border-left: 4px solid #ffc107;
            padding: 12px 16px;
            border-radius: 0 8px 8px 0;
            font-size: 13px;
            color: #7a5c00;
            margin: 16px 0;
        }
        .footer {
            background: #fafafa;
            padding: 20px 32px;
            text-align: center;
            font-size: 12px;
            color: #aaa;
            border-top: 1px solid #eee;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>💳 MoneyTransfer</h1>
            <p>Réinitialisation du mot de passe</p>
        </div>

        <div class="body">
            <p class="greeting">Bonjour {{ $firstName }},</p>

            <p class="text">
                Vous avez demandé à réinitialiser votre mot de passe.
                Utilisez le code ci-dessous dans l'application :
            </p>

            <div class="token-box">
                <div class="token-label">Votre code de réinitialisation</div>
                <div class="token-value">{{ $token }}</div>
            </div>

            <div class="warning">
                ⏱ Ce code expire dans <strong>15 minutes</strong> et ne peut être utilisé qu'une seule fois.
            </div>

            <p class="text">
                Si vous n'avez pas demandé cette réinitialisation, ignorez cet email.
                Votre mot de passe restera inchangé.
            </p>
        </div>

        <div class="footer">
            © {{ date('Y') }} MoneyTransferApp — Cet email a été envoyé automatiquement.
        </div>
    </div>
</body>
</html>
