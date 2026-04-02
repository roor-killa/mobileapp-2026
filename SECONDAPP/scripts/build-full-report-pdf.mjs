/**
 * Génère docs/RAPPORT-COMPLET-PROJET.pdf (MyBank + SECONDAPP).
 * Étapes :
 *  1. Régénère le HTML depuis le Markdown
 *  2. Imprime en PDF via Chrome ou Edge en mode headless
 *
 * Variables d'environnement :
 *   CHROME_PATH → chemin vers chrome.exe
 *   EDGE_PATH   → chemin vers msedge.exe
 */
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root      = path.join(__dirname, "..");
const htmlPath  = path.join(root, "docs", "RAPPORT-COMPLET-PROJET.html");
const pdfPath   = path.join(root, "docs", "RAPPORT-COMPLET-PROJET.pdf");

/* ── 1. Génération HTML ───────────────────────────────────────────── */
function buildHtml() {
  console.log("→ Génération du HTML…");
  const r = spawnSync(
    process.execPath,
    [path.join(__dirname, "build-full-report-html.mjs")],
    { cwd: root, stdio: "inherit", shell: false }
  );
  if (r.status !== 0) process.exit(r.status ?? 1);
}

/* ── 2. Résolution du navigateur headless ─────────────────────────── */
function resolveBrowser() {
  if (process.env.CHROME_PATH && fs.existsSync(process.env.CHROME_PATH))
    return process.env.CHROME_PATH;
  if (process.env.EDGE_PATH && fs.existsSync(process.env.EDGE_PATH))
    return process.env.EDGE_PATH;

  const { platform } = process;

  if (platform === "win32") {
    const candidates = [
      path.join(process.env["ProgramFiles"]      ?? "", "Google",    "Chrome",         "Application", "chrome.exe"),
      path.join(process.env["ProgramFiles(x86)"] ?? "", "Google",    "Chrome",         "Application", "chrome.exe"),
      path.join(process.env["LocalAppData"]      ?? "", "Google",    "Chrome",         "Application", "chrome.exe"),
      path.join(process.env["ProgramFiles"]      ?? "", "Microsoft", "Edge",           "Application", "msedge.exe"),
      path.join(process.env["ProgramFiles(x86)"] ?? "", "Microsoft", "Edge",           "Application", "msedge.exe"),
    ];
    for (const p of candidates) {
      if (p && fs.existsSync(p)) return p;
    }
  }

  if (platform === "darwin") {
    const candidates = [
      "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
      "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge",
      "/Applications/Chromium.app/Contents/MacOS/Chromium",
    ];
    for (const p of candidates) {
      if (fs.existsSync(p)) return p;
    }
  }

  // Linux — recherche dans PATH
  for (const name of ["google-chrome", "chromium", "chromium-browser", "microsoft-edge"]) {
    const r = spawnSync("which", [name], { encoding: "utf8" });
    if (r.status === 0 && r.stdout?.trim()) return r.stdout.trim();
  }

  return null;
}

/* ── 3. Impression PDF ────────────────────────────────────────────── */
buildHtml();

if (!fs.existsSync(htmlPath)) {
  console.error("✗ Fichier HTML introuvable :", htmlPath);
  process.exit(1);
}

const browser = resolveBrowser();
if (!browser) {
  console.error([
    "✗ Aucun navigateur headless détecté.",
    "  Définir CHROME_PATH ou EDGE_PATH, ou installer Google Chrome / Microsoft Edge.",
    "",
    "  Exemple PowerShell :",
    '  $env:CHROME_PATH = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe"',
    "  npm run report:full:pdf",
    "",
    "  Alternative manuelle :",
    "  npm run report:full:html",
    "  → Ouvrir docs/RAPPORT-COMPLET-PROJET.html → Ctrl+P → Enregistrer au format PDF",
  ].join("\n"));
  process.exit(1);
}

console.log("→ Navigateur détecté :", browser);
console.log("→ Impression PDF en cours…");

const fileUrl = pathToFileURL(htmlPath).href;
const args = [
  "--headless=new",
  "--disable-gpu",
  "--no-sandbox",
  "--no-pdf-header-footer",
  "--print-to-pdf-no-header",
  `--print-to-pdf=${pdfPath}`,
  fileUrl,
];

const result = spawnSync(browser, args, { cwd: root, stdio: "inherit" });

if (result.status !== 0) {
  console.error("✗ Échec de l'impression PDF (code", result.status, ").");
  process.exit(result.status ?? 1);
}

if (!fs.existsSync(pdfPath)) {
  console.error("✗ Le PDF n'a pas été créé :", pdfPath);
  process.exit(1);
}

const { size } = fs.statSync(pdfPath);
const sizeKb = (size / 1024).toFixed(1);
console.log(`✓ PDF généré : ${pdfPath}  (${sizeKb} Ko)`);
