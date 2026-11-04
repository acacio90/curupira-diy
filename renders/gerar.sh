#!/usr/bin/env bash
# Gera todas as renderizacoes do CURUPIRA nesta pasta (renders/).
# Uso: ./renders/gerar.sh   (de qualquer lugar)
# Requer: kicad-cli (KiCad 10), kicad-packages3d, pdftoppm (poppler-utils), ImageMagick.
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
PROJ="$(dirname "$DIR")"
PCB="$PROJ/curupira-diy.kicad_pcb"
SCH="$PROJ/curupira-diy.kicad_sch"
cd "$DIR"

render() { # nome, args...
  local nome=$1; shift
  kicad-cli pcb render -o "$nome.png" --width 1600 --height 1100 --quality high --background transparent "$@" "$PCB" >/dev/null
  echo "ok $nome"
}

render 3d-frente-topo       --side top
render 3d-verso             --side bottom
render 3d-perspectiva       --side top    --rotate '-40,0,30'
render 3d-verso-perspectiva --side bottom --rotate '40,0,30'
render 3d-lado-frente       --side front
render 3d-lado-direito      --side right

kicad-cli pcb export svg -o 2d-frente.svg --mode-single -l F.Cu,F.Silkscreen,F.Mask,Edge.Cuts \
  --exclude-drawing-sheet --fit-page-to-board "$PCB" >/dev/null
kicad-cli pcb export svg -o 2d-verso.svg --mode-single -l B.Cu,B.Silkscreen,B.Mask,Edge.Cuts \
  --exclude-drawing-sheet --fit-page-to-board --mirror "$PCB" >/dev/null
for f in 2d-frente 2d-verso; do
  magick -density 200 -background none "$f.svg" PNG32:"$f.png"; echo "ok $f"
done

kicad-cli sch export pdf -o esquematico.pdf "$SCH" >/dev/null
pdftoppm -png -r 150 -singlefile esquematico.pdf esquematico
echo "ok esquematico"

magick montage \
  -label 'Frente (3D)'              3d-frente-topo.png \
  -label 'Verso (3D)'               3d-verso.png \
  -label 'Frente - perspectiva'     3d-perspectiva.png \
  -label 'Verso - perspectiva'      3d-verso-perspectiva.png \
  -label 'Perfil - borda inferior'  3d-lado-frente.png \
  -label 'Perfil - borda direita'   3d-lado-direito.png \
  -label 'Frente (2D)'              2d-frente.png \
  -label 'Verso (2D, espelhado)'    2d-verso.png \
  -geometry 800x550+8+8 -tile 2x -pointsize 22 -background none -fill '#888888' \
  -title "CURUPIRA - todas as vistas" PNG32:visao-geral.png
echo "ok visao-geral"
