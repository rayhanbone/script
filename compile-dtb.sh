#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="."
OUT_DIR="build"

# Jika Anda menyimpan DTS di folder tertentu, ubah SRC_DIR mis. "dts/".
mkdir -p "$OUT_DIR"

shopt -s globstar nullglob

found=0
for src in $(find "$SRC_DIR" -type f -name '*.dts'); do
  # Lewati file di direktori .git atau build
  case "$src" in
    ./.git/*|./${OUT_DIR}/*) continue ;;
  esac

  found=1
  # hitung path relatif tanpa leading ./
  rel="${src#./}"
  # ubah ekstensi .dts -> .dtb dan tempatkan di OUT_DIR dengan struktur sama
  out="$OUT_DIR/${rel%.dts}.dtb"
  outdir="$(dirname "$out")"
  mkdir -p "$outdir"

  echo "Compiling: $src -> $out"
  # opsi tambahan:
  # -@ untuk include symbols jika ada __symbols__
  dtc -I dts -O dtb -o "$out" "$src"
done

if [ "$found" -eq 0 ]; then
  echo "No .dts files found."
  exit 0
fi

echo "Compilation finished. Output in $OUT_DIR/"
