#!/bin/bash
# Rebuild the theoretical Twist barcode library and its bowtie index.
#
# The library is every pairwise combination of the 2900 WILDseq barcodes in
# resources/barcodes.txt, joined by a constant linker:
#
#     barcode_i + TGCATCGGTTAACCGATGCA + barcode_j
#
# giving 2900^2 = 8,410,000 sequences of 44 bp. Records are numbered serially
# in row-major order (i outer, j inner) and named ">N_N".
#
# Usage: ./build_index.sh [output_dir]     (default: Twist_barcode_library)

set -euo pipefail

BARCODES="$(dirname "$0")/resources/barcodes.txt"
OUTDIR="${1:-Twist_barcode_library}"
LINKER="TGCATCGGTTAACCGATGCA"

mkdir -p "$OUTDIR"

echo "Generating $OUTDIR/oligo_combinations.fasta ..."
awk -v linker="$LINKER" '
    { bc[NR-1] = $1 }
    END {
        n = NR
        rec = 0
        for (i = 0; i < n; i++)
            for (j = 0; j < n; j++) {
                print ">" rec "_" rec
                print bc[i] linker bc[j]
                rec++
            }
    }
' "$BARCODES" > "$OUTDIR/oligo_combinations.fasta"

echo "Building bowtie index ..."
bowtie-build --threads "${THREADS:-8}" \
    "$OUTDIR/oligo_combinations.fasta" \
    "$OUTDIR/theoretical_barcodes"

echo "Done. Set barcode_index in config/config.yaml to:"
echo "  $(cd "$OUTDIR" && pwd)/theoretical_barcodes"
