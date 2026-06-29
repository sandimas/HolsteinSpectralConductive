
# done/submitted lambdas
# 1, 2, 3
LAMBDA=4

for OMEGA in {1..4}
do
    for BETA in {1..16}
    do
    
        echo  ${LAMBDA} ${BETA} ${OMEGA}
        sbatch -J "l${LAMBDA}-o${OMEGA}-b${BETA}" slurm_spectral.sh ${LAMBDA} ${BETA} ${OMEGA}
    done
done
    