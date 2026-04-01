/**
 * Génère docs/RAPPORT-UTILISATION-DETAILLE.html à partir du Markdown.
 * Ouvrir le HTML dans un navigateur → Fichier / Imprimer → Enregistrer au format PDF.
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { marked } from "marked";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, "..");
const mdPath = path.join(root, "docs", "RAPPORT-UTILISATION-DETAILLE.md");
const outPath = path.join(root, "docs", "RAPPORT-UTILISATION-DETAILLE.html");

const md = fs.readFileSync(mdPath, "utf8");
const body = await marked.parse(md);

const html = `<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Rapport d'utilisation — SECONDAPP</title>
  <style>
    :root { color-scheme: light; }
    body {
      font-family: "Segoe UI", system-ui, sans-serif;
      line-height: 1.55;
      max-width: 820px;
      margin: 0 auto;
      padding: 2rem 1.5rem 4rem;
      color: #1a1a1a;
      font-size: 11pt;
    }
    h1 { font-size: 1.75rem; margin-top: 0; }
    h2 { font-size: 1.35rem; margin-top: 2rem; border-bottom: 1px solid #ccc; padding-bottom: 0.25rem; }
    h3 { font-size: 1.1rem; margin-top: 1.25rem; }
    table { border-collapse: collapse; width: 100%; margin: 1rem 0; font-size: 0.95rem; }
    th, td { border: 1px solid #bbb; padding: 0.45rem 0.6rem; text-align: left; vertical-align: top; }
    th { background: #f0f0f0; }
    code, pre { font-family: ui-monospace, Consolas, monospace; font-size: 0.88em; }
    code { background: #f4f4f4; padding: 0.1em 0.35em; border-radius: 3px; }
    pre { background: #f8f8f8; padding: 1rem; overflow-x: auto; border: 1px solid #ddd; border-radius: 6px; }
    pre code { background: none; padding: 0; }
    hr { border: none; border-top: 1px solid #ddd; margin: 2rem 0; }
    ul, ol { padding-left: 1.4rem; }
    @media print {
      body { max-width: none; padding: 0.5cm 1cm; font-size: 10pt; }
      h2 { page-break-after: avoid; }
      tr { page-break-inside: avoid; }
    }
  </style>
</head>
<body>
${body}
<p style="margin-top:3rem;font-size:0.85rem;color:#666;"><em>Document généré pour impression PDF — SECONDAPP</em></p>
</body>
</html>`;

fs.writeFileSync(outPath, html, "utf8");
console.log("Écrit :", outPath);
console.log("Ouvrez ce fichier dans le navigateur, puis Ctrl+P → Enregistrer au format PDF.");
