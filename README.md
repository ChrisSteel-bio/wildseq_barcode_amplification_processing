# WILDseq barcode counts

Snakemake pipeline for quantifying lineage barcode abundance from
[WILDseq](https://elifesciences.org/articles/80981) RT amplicon sequencing.

```
fastq ──▶ extract insert between adapters ──▶ map to Twist library ──▶ per-barcode counts
            (seqkit + grep)                      (bowtie)              (sort | uniq -c)
```

**Output:** `final_counts/{sample}_Twist_BC_count.txt` — two columns, read count and barcode ID.

## Configure

`config/samples.csv`:

```csv
sample_name,path
Rituximab_Baseline1,ritux_pressure_2/SLX-26596.i715-i503.fq.gz
```

`config/config.yaml` sets `reads_dir` (what `path` is relative to), `barcode_index`
(bowtie index prefix for the theoretical barcode library), the flanking adapters,
and `bowtie_extra`.

## Run

```bash
snakemake --use-conda --cores 8            # local
sbatch run_slurm.sh                        # SLURM, whole workflow in one job
snakemake --profile profiles/slurm         # SLURM, one job per rule
```

The profile needs `pip install snakemake-executor-plugin-slurm`, and its
`slurm_account` / `slurm_partition` are set for Cambridge CSD3 — change them for
your cluster.

## Barcode assignment stringency

`bowtie_extra` is empty by default, which keeps bowtie's permissive defaults: up to
two seed mismatches and no multimapper suppression, so a read matching several
theoretical barcodes is assigned to an arbitrary one. For stricter assignment:

```yaml
bowtie_extra: "-v 1 -m 1 --best --strata"
```

This changes results, so it is off by default.

## Requirements

Snakemake ≥ 8 and conda. Tool environments (seqkit, bowtie) are created
automatically by `--use-conda`.
