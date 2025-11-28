#!/bin/bash

module use /appl/local/csc/modulefiles
module load julia
module load julia-amdgpu
julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.resolve()'
