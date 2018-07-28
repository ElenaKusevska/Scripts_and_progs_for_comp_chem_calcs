#!/bin/bash

np=8 # number of processors
m=16 # memory

for i in 4
do
  echo $i
  cd $i

  #-----------------------------------------------
  # Prepare the Gaussian input file:
  #-----------------------------------------------

  echo %NProc=$np | cat >> temp
  echo %Mem=$m'GB' | cat >> temp
  echo %chk=$i.chk | cat >> temp
  echo '#p m062x/6-311+g(d,p) scrf=(smd,solvent=chloroform) Geom=Checkpoint pop=nbo output=wfn gfinput' | cat >> temp
  echo ' ' | cat >> temp
  echo $i | cat >> temp
  echo ' ' | cat >> temp

  sed -n 8p $i.g09 >> temp # just the line with charge and
                               # multiplicity

  echo ' ' | cat >> temp
  echo $i.wfn  | cat >> temp
  echo ' ' | cat >> temp

  rm $i.g09
  mv temp $i.g09
  rm -f $i.out $i.slurm $i.fchk $i.xyz $i.gjf output

  #-------------------------------------------
  # Prepare the slurm script:
  #-------------------------------------------

  echo '#!/usr/bin/env bash' | cat >> $i.slurm
  echo '#SBATCH --time=8:00:00' | cat >> $i.slurm
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
  echo cp $i.chk '$SLURM_SCRATCH' | cat >> $i.slurm
  echo cd '$SLURM_SCRATCH' | cat >> $i.slurm
  echo ' ' | cat >> $i.slurm
  echo ulimit -s unlimited | cat >> $i.slurm
  echo export LC_COLLATE=C | cat >> $i.slurm
  echo ' ' | cat >> $i.slurm
  echo 'g09 < $SLURM_JOB_NAME.g09' | cat >> $i.slurm
  echo cp $i.chk '$SLURM_SUBMIT_DIR' | cat >> $i.slurm
  echo cp $i.wfn '$SLURM_SUBMIT_DIR' | cat >> $i.slurm
  echo ' ' | cat >> $i.slurm
  echo formchk $i.chk $i.fchk | cat >> $i.slurm
  echo cp $i.fchk '$SLURM_SUBMIT_DIR' | cat >> $i.slurm
  echo ' ' | cat >> $i.slurm
  echo ' ' | cat >> $i.slurm

  cd ..
  sleep 3
done

