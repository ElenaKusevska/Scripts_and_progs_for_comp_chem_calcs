#!/bin/bash

# General2 has 40 processors and 120 GB per node
# There are 27 different energies being deposited

#SBATCH --job-name=frame_1000
#SBATCH --partition=general2
#SBATCH --ntasks=27
#SBATCH --nodes=7
#SBATCH --tasks-per-node=4
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=3000
#SBATCH --time=72:00:00
f=1000

export LD_LIBRARY_PATH=/home/moldynamics/public/programs/openmpi/lib:$LD_LIBRARY_PATH

# Execute jobs in parallel
for i in 0 25 35 40 50 60 75 85 90 100 110 125 135 150 160 175 185 200 225 250 275 300 325 350 375 400 800
do
    cd 'frame_'$f'_Edep_'$i
    srun -N 1 -n 1 -c 10 --exclusive /home/moldynamics/public/programs/mbnexplorer64_3.0.2900_2020-03-20_Linux 'frame_'$f'_Edep_'$i'.task' &
    cd ..
done
wait
