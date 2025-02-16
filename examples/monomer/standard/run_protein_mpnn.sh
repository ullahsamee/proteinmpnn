#!/bin/bash

#SBATCH -p volta-gpu
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=16g
#SBATCH -t 00-00:30:00
#SBATCH --qos gpu_access
#SBATCH --gres=gpu:1
#SBATCH --constraint=rhel8
#SBATCH --mail-type=END
#SBATCH --mail-user=user@email.com

source ~/.bashrc
conda activate mpnn

# Set GPUs
export CUDA_VISIBLE_DEVICES=0,1

#module load cuda
#module load gcc

python ../../../run/generate_json.py @json.flags

python ../../../run/run_protein_mpnn.py @proteinmpnn.flags
