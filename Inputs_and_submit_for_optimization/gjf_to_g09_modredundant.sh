#!/bin/bash

np=16 # number of processors
m=24 # memory

for i in 2_7
do

  echo $i
  mkdir $i
  cp $i.gjf $i
  cd $i
  dos2unix $i.gjf

  #-----------------------------------------------
  # Prepare the Gaussian input file:
  #-----------------------------------------------

  echo %NProc=$np | cat >> $i.g09
  echo %Mem=$m'GB' | cat >> $i.g09
  echo %chk=$i.chk | cat >> $i.g09
  echo '#p opt=modredundant freq m062x/6-31+g(d) scrf=(smd,solvent=chloroform) geom=connectivity gfinput' | cat >> $i.g09
  echo ' ' | cat >> $i.g09
  echo $i | cat >> $i.g09
  echo ' ' | cat >> $i.g09

  echo '0 1' | cat >> $i.g09
  sed -n 9,117p $i.gjf >> $i.g09

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
  echo ' ' | cat >> $i.slurm
  echo cp $i.g09 '$SLURM_SCRATCH' | cat >> $i.slurm
  echo cd '$SLURM_SCRATCH' | cat >> $i.slurm
  echo ' ' | cat >> $i.slurm
  echo ulimit -s unlimited | cat >> $i.slurm
  echo export LC_COLLATE=C | cat >> $i.slurm
  echo ' ' | cat >> $i.slurm
  echo 'g09 < $SLURM_JOB_NAME.g09' | cat >> $i.slurm
  echo cp $i.chk '$SLURM_SUBMIT_DIR' | cat >> $i.slurm
  echo ' ' | cat >> $i.slurm  
  echo ' ' | cat >> $i.slurm

  cd ..
  sleep 3
done

