#! /bin/bash



## Submit jobs for all lambdas, omegas, and betas via SLURM
# In practice, I had to run each lambda separately because the number of jobs was above the maximum for our SLURM cluster. 
# So I ran this script 13 times, each time changing the range of lambdas to be a single value.
#
# 2_slurm.sh is the script to run the job
for LAMBDA in {1..13}
do
    for OMEGA in {4..4}
    do
        for BETA in {1..16}
        do
        
            echo  ${LAMBDA} ${BETA} ${OMEGA}
            sbatch -J "l${LAMBDA}-o${OMEGA}-b${BETA}" 2_slurm.sh ${LAMBDA} ${BETA} ${OMEGA}
        done
    done
done