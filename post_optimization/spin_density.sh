#!/bin/bash

np=2 # number of processors
m=8 # memory
i=2

echo $i
mkdir spin_density
cp $i.fchk spin_density
cd spin_density

#-------------------------------------------
# Prepare the slurm script:
#-------------------------------------------

echo '#!/usr/bin/env bash' | cat >> $i.slurm
echo '#SBATCH --time=96:00:00' | cat >> $i.slurm
echo '#SBATCH --nodes=1' | cat >> $i.slurm
echo '#SBATCH --ntasks=1' | cat >> $i.slurm
echo '#SBATCH --cpus-per-task='$np | cat >> $i.slurm
echo '#SBATCH --mem='$m'gb' | cat >> $i.slurm
echo '#SBATCH --job-name='$i | cat >> $i.slurm
echo '#SBATCH --output='$i.out | cat >> $i.slurm
echo '#SBATCH --partition=smp' | cat >> $i.slurm
echo ' ' | cat >> $i.slurm
echo module purge | cat >> $i.slurm
echo module load gaussian/D.01 | cat >> $i.slurm
echo ' '
echo ulimit -s unlimited | cat >> $i.slurm
echo export LC_COLLATE=C | cat >> $i.slurm
echo ' '
echo cubegen $np Spin=SCF $i.fchk $i.cube 100 h

cd ..

