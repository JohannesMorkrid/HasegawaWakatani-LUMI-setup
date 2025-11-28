# HasegawaWakatani-LUMI-setup
Structure for running HasegawaWakatani.jl simulations on LUMI

## Setup
Run instantiate.sh on a ***login node*** to ensure all packages are installed and pre-compiled:
```bash
  chmod +x instantiate.sh
  ./instantiate.sh
```

## Run simulations
Modify the script.jl and run.sh to your liking and then submit it to slurm using:

```bash 
  sbatch run.sh
```

Currently the normal terminal log is logged to the error-* file.
