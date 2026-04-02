/**
 * Génère docs/RAPPORT-COMPLET-PROJET.html à partir du Markdown complet du projet.
 * Couvre les deux applications : MyBank (Flutter + Laravel) et SECONDAPP (React + Vite).
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { marked } from "marked";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, "..");
const mdPath = path.join(root, "docs", "RAPPORT-COMPLET-PROJET.md");
const outPath = path.join(root, "docs", "RAPPORT-COMPLET-PROJET.html");

const md = fs.readFileSync(mdPath, "utf8");
const body = await marked.parse(md);

const html = `<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Rapport technique — mobileapp-2026</title>
  <style>
    :root { color-scheme: light; }

    * { box-sizing: border-box; }

    body {
      font-family: "Segoe UI", system-ui, -apple-system, sans-serif;
      line-height: 1.65;
      max-width: 900px;
      margin: 0 auto;
      padding: 2.5rem 2rem 5rem;
      color: #1a1a2e;
      font-size: 10.5pt;
      background: #fff;
    }

    /* ── Page de couverture ── */
    h1:first-of-type {
      font-size: 2rem;
      font-weight: 800;
      color: #0f172a;
      border-bottom: 3px solid #3b82f6;
      padding-bottom: 0.5rem;
      margin-top: 0;
      margin-bottom: 0.25rem;
    }

    /* ── Titres ── */
    h1 { font-size: 1.8rem; font-weight: 700; color: #0f172a; margin-top: 2.5rem; }
    h2 {
      font-size: 1.3rem;
      font-weight: 700;
      color: #1e40af;
      margin-top: 2.2rem;
      border-bottom: 2px solid #bfdbfe;
      padding-bottom: 0.3rem;
    }
    h3 {
      font-size: 1.05rem;
      font-weight: 600;
      color: #1d4ed8;
      margin-top: 1.6rem;
    }
    h4 {
      font-size: 0.95rem;
      font-weight: 600;
      color: #374151;
      margin-top: 1.2rem;
    }

    /* ── Paragraphes & texte ── */
    p { margin: 0.5rem 0 0.75rem; }
    strong { color: #111827; }

    /* ── Tableaux ── */
    table {
      border-collapse: collapse;
      width: 100%;
      margin: 1rem 0 1.4rem;
      font-size: 0.92rem;
    }
    th {
      background: #1e40af;
      color: #fff;
      font-weight: 600;
      padding: 0.5rem 0.75rem;
      text-align: left;
      vertical-align: top;
    }
    td {
      border: 1px solid #dbeafe;
      padding: 0.45rem 0.75rem;
      vertical-align: top;
    }
    tr:nth-child(even) td { background: #f0f7ff; }
    tr:hover td { background: #dbeafe; }

    /* ── Code inline ── */
    code {
      font-family: "Cascadia Code", "Fira Code", ui-monospace, Consolas, monospace;
      font-size: 0.85em;
      background: #f1f5f9;
      color: #0f172a;
      padding: 0.12em 0.4em;
      border-radius: 4px;
      border: 1px solid #e2e8f0;
    }

    /* ── Blocs de code ── */
    pre {
      background: #0f172a;
      color: #e2e8f0;
      padding: 1rem 1.25rem;
      overflow-x: auto;
      border-radius: 8px;
      margin: 1rem 0 1.5rem;
      font-size: 0.82em;
      line-height: 1.55;
    }
    pre code {
      background: none;
      color: inherit;
      padding: 0;
      border: none;
      font-size: inherit;
    }

    /* ── Listes ── */
    ul, ol { padding-left: 1.5rem; margin: 0.4rem 0 0.8rem; }
    li { margin: 0.2rem 0; }

    /* ── Séparateurs ── */
    hr {
      border: none;
      border-top: 2px solid #e2e8f0;
      margin: 2.5rem 0;
    }

    /* ── Blockquote ── */
    blockquote {
      border-left: 4px solid #3b82f6;
      background: #eff6ff;
      margin: 1rem 0;
      padding: 0.6rem 1rem;
      border-radius: 0 6px 6px 0;
      color: #1e3a8a;
    }

    /* ── Badges d'état (simulation) ── */
    .badge-draft  { background:#fef9c3; color:#854d0e; padding:2px 8px; border-radius:9999px; font-size:0.8em; }
    .badge-posted { background:#dbeafe; color:#1e40af; padding:2px 8px; border-radius:9999px; font-size:0.8em; }
    .badge-paid   { background:#dcfce7; color:#166534; padding:2px 8px; border-radius:9999px; font-size:0.8em; }

    /* ── Métadonnées du rapport (après le h1) ── */
    h1 + p strong { color: #374151; }

    /* ── Table des matières ── */
    h2:first-of-type + ul a,
    p + ul a {
      color: #2563eb;
      text-decoration: none;
    }

    /* ── Liens ── */
    a { color: #2563eb; text-decoration: underline; }

    /* ── Impression PDF ── */
    @media print {
      body {
        max-width: none;
        padding: 0.8cm 1.2cm 1cm;
        font-size: 9.5pt;
        color: #000;
      }

      h1 { font-size: 20pt; page-break-after: avoid; }
      h2 { font-size: 13pt; page-break-after: avoid; color: #1e40af; }
      h3 { font-size: 11pt; page-break-after: avoid; }

      pre {
        background: #f8fafc;
        color: #0f172a;
        border: 1px solid #cbd5e1;
        page-break-inside: avoid;
        font-size: 7.5pt;
      }

      table { page-break-inside: avoid; font-size: 8.5pt; }
      tr    { page-break-inside: avoid; }

      th { background: #1e40af !important; color: #fff !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
      tr:nth-child(even) td { background: #f0f7ff !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }

      hr { border-top: 1px solid #94a3b8; }

      a { color: #1d4ed8; text-decoration: none; }

      /* Saut de page avant chaque grande section numérotée */
      h2 { page-break-before: auto; }
    }
  </style>
</head>
<body>
${body}
<hr/>
<p style="margin-top:2.5rem;font-size:0.82rem;color:#64748b;text-align:center;">
  <em>Document généré automatiquement · mobileapp-2026 · CLAPIER Titouan · Avril 2026</em>
</p>
</body>
</html>`;

fs.writeFileSync(outPath, html, "utf8");
console.log("✓ HTML généré :", outPath);
console.log("  → Ouvrir dans le navigateur, puis Ctrl+P → Enregistrer au format PDF");
console.log("  → Ou lancer : npm run report:full:pdf");
