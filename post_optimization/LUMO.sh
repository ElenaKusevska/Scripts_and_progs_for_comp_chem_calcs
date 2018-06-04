#!/bin/bash

np=2 # number of processors
m=8 # memory
i=3

echo $i
mkdir $i'_LUMO'
cp $i.fchk $i'_LUMO'
cd $i'_LUMO'

#-------------------------------------------
# Prepare the slurm script:
#-------------------------------------------

echo '#!/usr/bin/env bash' | cat >> $i.slurm
echo '#SBATCH --time=1:00:00' | cat >> $i.slurm
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
echo ' ' | cat >> $i.slurm
echo ulimit -s unlimited | cat >> $i.slurm
echo export LC_COLLATE=C | cat >> $i.slurm
echo ' ' | cat >> $i.slurm
echo cubegen $np MO=LUMO $i.fchk $i.cube 100 h | cat >> $i.slurm

cd ..
mv $i'_LUMO' ../
