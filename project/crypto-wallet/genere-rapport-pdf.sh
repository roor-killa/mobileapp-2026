#!/usr/bin/env bash
# Régénère RAPPORT_RENDU_NODEX.pdf à partir du Markdown (Pandoc + XeLaTeX).
set -e
cd "$(dirname "$0")"
pandoc RAPPORT_RENDU_NODEX.md -o RAPPORT_RENDU_NODEX.pdf \
  --from=markdown+yaml_metadata_block \
  --pdf-engine=xelatex \
  --resource-path=".:docs" \
  -V lang=fr \
  -V documentclass=article \
  -V papersize=a4
echo "OK : $(pwd)/RAPPORT_RENDU_NODEX.pdf"
