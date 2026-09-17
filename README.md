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
(bowtie index prefix for the theoretical barcode library) and
the flanking adapters.

## Run

```bash
snakemake --use-conda --cores 8            # local
sbatch run_slurm.sh                        # SLURM, whole workflow in one job
snakemake --profile profiles/slurm         # SLURM, one job per rule
```

The profile needs `pip install snakemake-executor-plugin-slurm`, and its
`slurm_account` / `slurm_partition` are set for Cambridge CSD3 — change them for
your cluster.

## Requirements

Snakemake ≥ 8 and conda. Tool environments (seqkit, bowtie) are created
automatically by `--use-conda`.
