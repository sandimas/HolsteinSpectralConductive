#!/bin/bash
#SBATCH -J spec			       #The name of the job
#SBATCH -A ACF-UTK0014              # The project account to be charged
#SBATCH --nodes=1                     # Number of nodes
#SBATCH --ntasks=1          # cpus per node 
#SBATCH --cpus-per-task=48
#SBATCH --partition=campus            # If not specified then default is "campus"
#SBATCH --time=24:00:00             # Wall time (days-hh:mm:ss)
#SBATCH --error=error/%j.err	       # The file where run time errors will be dumped
#SBATCH --output=error/%j.out	       # The file where the output of the terminal will be dumped
#SBATCH --qos=campus




julia --threads=auto run_spectral.jl $*


