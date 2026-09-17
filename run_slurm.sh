#!/bin/bash
#SBATCH --job-name=wildseq_counts
#SBATCH --account=STURNER-SL3-CPU
#SBATCH --partition=icelake
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --time=04:00:00
#SBATCH --output=slurm_logs/%x_%j.out
#SBATCH --error=slurm_logs/%x_%j.err

# Runs the whole workflow inside one SLURM job.
# For per-rule job submission instead, use: snakemake --profile profiles/slurm
# (requires: pip install snakemake-executor-plugin-slurm)

set -euo pipefail
source "$HOME/miniconda3/etc/profile.d/conda.sh"
conda activate "${SNAKEMAKE_ENV:-base}"

mkdir -p slurm_logs
snakemake --use-conda --cores "${SLURM_CPUS_PER_TASK:-8}" --rerun-incomplete "$@"
