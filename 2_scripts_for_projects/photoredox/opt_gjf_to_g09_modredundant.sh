#!/bin/bash
redundantmod1='B 38 40 F' # N-H
redundantmod2='' # H-O

np=16 # number of processors
mg=24 # memory line in gaussian input file
ms=25 # requested memory in slurm file
hr=72 # projected run time of job

charge=0
multiplicity=1

for i in 38_Cl_a_modred_40_38 38_Cl_b_modred_40_38
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
  echo %Mem=$mg'GB' | cat >> $i.g09
  echo %chk=$i.chk | cat >> $i.g09
  echo '#p opt=modredundant freq=noraman m062x/6-31+g(d) scrf=(smd,solvent=chloroform) geom=connectivity gfinput' | cat >> $i.g09
  echo ' ' | cat >> $i.g09
  echo 'job title = '$i | cat >> $i.g09
  echo ' ' | cat >> $i.g09

  echo $charge' '$multiplicity | tail -n+1 | cat >> $i.g09
  sed -n '/^ /,/^$/p' $i.gjf | cat >> $i.g09
  # print all instances of from line starting with ' ', to first blank line
      # -n - supress double printing

  #echo ' ' | cat >> $i.g09
  echo $redundantmod1 | cat >> $i.g09
  #echo $redundantmod2 | cat >> $i.g09
  echo ' ' | cat >> $i.g09

  #-------------------------------------------
  # Prepare the slurm script:
  #-------------------------------------------

  echo '#!/usr/bin/env bash' | cat >> $i.slurm
  echo '#SBATCH --time='$hr':00:00' | cat >> $i.slurm
  echo '#SBATCH --nodes=1' | cat >> $i.slurm
  echo '#SBATCH --ntasks=1' | cat >> $i.slurm
  echo '#SBATCH --cpus-per-task='$np | cat >> $i.slurm
  echo '#SBATCH --mem='$ms'gb' | cat >> $i.slurm
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
  sleep 1
done

