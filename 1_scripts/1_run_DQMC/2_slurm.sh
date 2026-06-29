#!/bin/bash
#SBATCH -A ACF-UTK0014              # The project account to be charged
#SBATCH --nodes=2                   # Number of nodes
#SBATCH --ntasks-per-node=40        # cpus per node 
#SBATCH --partition=campus          # If not specified then default is "campus"
#SBATCH --time=24:00:00             # Wall time (days-hh:mm:ss)
#SBATCH --error=error/%x-%j.err	    # The file where run time errors will be dumped
#SBATCH --output=error/%x-%j.out	# The file where the output of the terminal will be dumped
#SBATCH --qos=campus                # QOS for the job

# Here we run 80 cores. 
# 4 walkers per simulation over 20 fillings 
# AMBDA, BETA and OMEGA are passed in as arguments to this script.
# Note, even for beta=20 on 2017 Skylake Xeon Gold 6148 processors we can run these in under 24 hours.

module load openmpi

~/.julia/bin/mpiexecjl --project=. -n 80 julia 3_holstein_2D.jl $*
