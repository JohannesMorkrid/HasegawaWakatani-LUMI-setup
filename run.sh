#!/bin/bash
#SBATCH --account=project_465002229  # project account to bill 
#SBATCH --partition=standard-g          # other options are small-g and standard-g
#SBATCH --gpus-per-node=1            # Number of GPUs per node (max of 8)
#SBATCH --ntasks-per-node=1          # Use one task for one GPU
#SBATCH --cpus-per-task=7            # Use 1/8 of all available 56 CPUs on LUMI-G nodes
#SBATCH --output=output-%j
#SBATCH --error=error-%j
#SBATCH --time=24:00:00               # time limit

module use  /appl/local/csc/modulefiles
module load julia
module load julia-amdgpu
 
julia --project=. script.jl
