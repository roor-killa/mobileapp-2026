/**
 * Régénère docs/RAPPORT-UTILISATION-DETAILLE.html puis le PDF (Chrome ou Edge en headless).
 * Variables d’environnement : CHROME_PATH ou EDGE_PATH vers l’exécutable du navigateur.
 */
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, "..");
const htmlPath = path.join(root, "docs", "RAPPORT-UTILISATION-DETAILLE.html");
const pdfPath = path.join(root, "docs", "RAPPORT-UTILISATION-DETAILLE.pdf");

function buildHtml() {
  const r = spawnSync(process.execPath, [path.join(__dirname, "build-report-html.mjs")], {
    cwd: root,
    stdio: "inherit",
    shell: false,
  });
  if (r.status !== 0) process.exit(r.status ?? 1);
}

function resolveBrowser() {
  if (process.env.CHROME_PATH && fs.existsSync(process.env.CHROME_PATH)) {
    return process.env.CHROME_PATH;
  }
  if (process.env.EDGE_PATH && fs.existsSync(process.env.EDGE_PATH)) {
    return process.env.EDGE_PATH;
  }
  const { platform } = process;
  if (platform === "win32") {
    const candidates = [
      path.join(process.env["ProgramFiles"] ?? "", "Google", "Chrome", "Application", "chrome.exe"),
      path.join(process.env["ProgramFiles(x86)"] ?? "", "Google", "Chrome", "Application", "chrome.exe"),
      path.join(process.env["ProgramFiles"] ?? "", "Microsoft", "Edge", "Application", "msedge.exe"),
      path.join(process.env["ProgramFiles(x86)"] ?? "", "Microsoft", "Edge", "Application", "msedge.exe"),
    ];
    for (const p of candidates) {
      if (p && fs.existsSync(p)) return p;
    }
  }
  if (platform === "darwin") {
    const candidates = [
      "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
      "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge",
    ];
    for (const p of candidates) {
      if (fs.existsSync(p)) return p;
    }
  }
  for (const name of ["google-chrome", "chromium", "chromium-browser", "microsoft-edge"]) {
    const r = spawnSync("which", [name], { encoding: "utf8" });
    if (r.status === 0 && r.stdout?.trim()) return r.stdout.trim();
  }
  return null;
}

buildHtml();

if (!fs.existsSync(htmlPath)) {
  console.error("Fichier HTML introuvable :", htmlPath);
  process.exit(1);
}

const browser = resolveBrowser();
if (!browser) {
  console.error(
    "Aucun navigateur headless trouvé. Définis CHROME_PATH ou EDGE_PATH, ou installe Chrome / Edge.",
  );
  process.exit(1);
}

const fileUrl = pathToFileURL(htmlPath).href;
const args = [
  "--headless=new",
  "--disable-gpu",
  "--no-pdf-header-footer",
  `--print-to-pdf=${pdfPath}`,
  fileUrl,
];

const print = spawnSync(browser, args, { cwd: root, stdio: "inherit" });
if (print.status !== 0) {
  console.error("Échec de l’impression PDF (code", print.status, ").");
  process.exit(print.status ?? 1);
}

if (!fs.existsSync(pdfPath)) {
  console.error("Le PDF n’a pas été créé :", pdfPath);
  process.exit(1);
}

const { size } = fs.statSync(pdfPath);
console.log("Écrit :", pdfPath, `(${size} octets)`);
