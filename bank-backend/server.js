const express = require('express');
const bodyParser = require('body-parser');
const bcrypt = require('bcrypt');
const app = express();
const PORT = 3000;
const SALT_ROUNDS = 10;

app.use(bodyParser.json());

function generateIBAN(userId) {
    const bankCode = "30006";
    const branchCode = "00001";
    const accountNumber = String(userId).padStart(11, '0');
    const key = "76";
    return `FR${key} ${bankCode} ${branchCode} ${accountNumber} 00`;
}

let users = [];

// Compte test créé au démarrage avec mot de passe hashé
(async () => {
    const hashedPassword = await bcrypt.hash("loic123", SALT_ROUNDS);
    users.push({
        id: 1,
        name: "Loïc",
        email: "loic@gmail.com",
        password: hashedPassword,
        balance: 2350,
        history: [{ type: "Crédit", amount: 500,  date: "30/03/2025", label: "Virement reçu" },
            { type: "Débit",  amount: -150, date: "28/03/2025", label: "Vers test@gmail.com" },
            { type: "Crédit", amount: 2000, date: "01/03/2025", label: "Dépôt initial" }],
        iban: generateIBAN(users.length + 1)
    });
    console.log("✅ Compte test créé : loic@gmail.com / loic123");
})();

// 1. INSCRIPTION — hash du mot de passe
app.post('/api/register', async (req, res) => {
    const { name, email, password } = req.body;
    if (users.find(u => u.email === email))
        return res.status(400).json({ message: "Email utilisé" });

    const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);
    const newUser = {
        id: users.length > 0 ? Math.max(...users.map(u => u.id)) + 1 : 1,
        name, email,
        password: hashedPassword,
        balance: 1000,
        history: [],
        iban: generateIBAN(users.length + 1)
    };
    users.push(newUser);
    console.log(`✅ Nouveau compte : ${name} (ID: ${newUser.id})`);
    console.log(`🔒 Mot de passe hashé stocké : ${newUser.password}`); // PREUVE
    res.status(201).json(newUser);
});

app.post('/api/login', async (req, res) => {
    const { email, password } = req.body;
    const user = users.find(u => u.email === email);
    if (!user) return res.status(401).json({ message: "Erreur" });

    const match = await bcrypt.compare(password, user.password);
    if (match) {
        console.log(`🔑 Connexion : ${user.name} (ID: ${user.id})`);
        res.json(user);
    } else {
        res.status(401).json({ message: "Erreur" });
    }
});

// 3. RÉCUPÉRER COMPTE
app.get('/api/account/:id', (req, res) => {
    const user = users.find(u => u.id == req.params.id);
    user ? res.json(user) : res.status(404).json({ message: "Non trouvé" });
});

// 4. VIREMENT
app.post('/api/account/transfer', async (req, res) => {
    const { fromId, toEmail, amount } = req.body;
    const sender = users.find(u => u.id == fromId);
    const val = parseFloat(amount);

    if (!sender || sender.balance < val)
        return res.status(400).json({ message: "Solde insuffisant" });

    let receiver = users.find(u => u.email.toLowerCase() === toEmail.toLowerCase().trim());
    if (!receiver) {
        const hashedDefault = await bcrypt.hash("1234", SALT_ROUNDS); // HASH DU MDP PAR DÉFAUT
        receiver = {
            id: users.length > 0 ? Math.max(...users.map(u => u.id)) + 1 : 1,
            name: toEmail.split("@")[0], // Nom = partie avant le @
            email: toEmail,
            password: hashedDefault,
            balance: 0,
            history: [],
            iban: generateIBAN(users.length + 1)
        };
        users.push(receiver);
        console.log(`👤 Nouveau compte créé : ${receiver.email} / mot de passe par défaut : 1234`);
    }

    sender.balance -= val;
    receiver.balance += val;
    sender.history.unshift({ type: "Débit", amount: -val, date: new Date().toLocaleDateString(), label: `Vers ${toEmail}` });
    receiver.history.unshift({ type: "Crédit", amount: val, date: new Date().toLocaleDateString(), label: `De ${sender.name}` });

    res.status(200).json(sender);
});

// 5. MISE À JOUR PROFIL
app.put('/api/account/update', async (req, res) => {
    const { id, name, email, password } = req.body;
    const user = users.find(u => u.id == id);
    if (!user) return res.status(404).json({ message: "Utilisateur non trouvé" });

    if (name) user.name = name;
    if (email) user.email = email;
    if (password) user.password = await bcrypt.hash(password, SALT_ROUNDS);

    console.log(`✏️ Profil mis à jour : ${user.name}`);
    res.json(user);
});

// 6. RESET MOT DE PASSE
app.post('/api/reset-password', async (req, res) => {
    const { email } = req.body;
    const user = users.find(u => u.email.toLowerCase() === email.toLowerCase());
    if (!user) return res.status(404).json({ message: "Email introuvable" });

    user.password = await bcrypt.hash("1234", SALT_ROUNDS);
    console.log(`🔑 Reset mot de passe : ${user.name}`);
    res.json(user);
});

app.listen(PORT, () => console.log(`🚀 Serveur lancé sur le port ${PORT}`));