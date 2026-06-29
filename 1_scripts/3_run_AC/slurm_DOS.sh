#!/bin/bash
#SBATCH -J DOS			       #The name of the job
#SBATCH -A ACF-UTK0014              # The project account to be charged
#SBATCH --nodes=1                     # Number of nodes
#SBATCH --ntasks=1          # cpus per node 
##SBATCH --cpus-per-task=47
#SBATCH --partition=short            # If not specified then default is "campus"
#SBATCH --time=3:00:00             # Wall time (days-hh:mm:ss)
#SBATCH --error=error/DOS.err	       # The file where run time errors will be dumped
#SBATCH --output=error/DOS.out	       # The file where the output of the terminal will be dumped
#SBATCH --qos=short

if [ ! -f "deac_finished_dos" ] ; then
    sbatch --dependency=afterany:$SLURM_JOBID slurm_DOS.sh
else
    exit 0
fi


julia --threads=auto run_DOS.jl >> error/DOS_out.txt

#

touch deac_finished_dos
