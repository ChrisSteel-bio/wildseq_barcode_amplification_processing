# WILDseq barcode abundance pipeline

Counts lineage barcode abundance from RT WILDseq amplicon sequencing.

```
raw fastq  ->  extract insert between adapters  ->  map to Twist library  ->  per-barcode counts
```

Output: `final_counts/{sample}_Twist_BC_count.txt` — two columns, count and barcode ID.

## Setup

Edit `config/config.yaml` to point at your reads directory and bowtie index, then
list samples in `config/samples.csv`:

```csv
sample_name,path
Rituximab_Baseline1,reads/SLX-26596.i715-i503.fq.gz
```

`path` is relative to `reads_dir`.

## Run

Locally:

```bash
snakemake --use-conda --cores 8
```

On SLURM (Cambridge CSD3):

```bash
snakemake --profile profiles/slurm
```

Adjust `slurm_account` and `slurm_partition` in `profiles/slurm/config.yaml`.

## Notes

`bowtie_extra` in the config is empty by default, which keeps bowtie's permissive
defaults (up to 2 seed mismatches, no multimapper suppression). Set it to
`-v 1 -m 1 --best --strata` for stricter barcode assignment.

Requires snakemake >= 8 and `snakemake-executor-plugin-slurm` for the SLURM profile.
