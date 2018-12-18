#!/bin/bash

np=16 # number of processors
mg=24 # memory in gaussian input file
ms=25 # requested memory in slurm file
#redundantmod1='B 14 6 F' # ex: B 1 2 F
#redundantmod2='B 15 2 F' # ex: B 1 2 F
functional='b3lyp'
solvent='scrf=(smd,solvent=n,n-DiMethylFormamide)'
#solvent='scrf=(smd,solvent=o-DiChloroBenzene)'
#solvent=''

for i in TS3_1_DMF_b3lyp TS3_2_DMF_b3lyp TS3_1_H_DMF_b3lyp  TS3_2_H_DMF_b3lyp
do

  echo $i
  mkdir $i
  if [ $? -ne 0 ] ; then
    echo "mkdir error"
    exit
  fi
  cp $i.gjf $i
  cd $i
  dos2unix $i.gjf

  #-----------------------------------------------
  # Prepare the Gaussian input file:
  #-----------------------------------------------

  echo %NProc=$np | cat >> $i.g16
  echo %Mem=$mg'GB' | cat >> $i.g16
  echo %chk=$i.chk | cat >> $i.g16
  echo '#p opt=modredundant freq=noraman '$functional'/6-31+g(d) '$solvent' geom=connectivity gfinput' | cat >> $i.g16
  echo ' ' | cat >> $i.g16
  echo $i | cat >> $i.g16
  echo ' ' | cat >> $i.g16

  echo '0 1' | cat >> $i.g16
  sed -n '/^ /,/^$/p' $i.gjf | cat >> $i.g16
  # print all instances of from line starting with ' ', to first blank line

  # Add redundant mod
#  echo $redundantmod1 | cat >> $i.g16
#  echo $redundantmod2 | cat >> $i.g16
#  echo ' ' | cat >> $i.g16

  #-------------------------------------------
  # Prepare the slurm script:
  #-------------------------------------------

  echo '#!/usr/bin/env bash' | cat >> $i.slurm
  echo '#SBATCH --time=96:00:00' | cat >> $i.slurm
  echo '#SBATCH --nodes=1' | cat >> $i.slurm
  echo '#SBATCH --ntasks=1' | cat >> $i.slurm
  echo '#SBATCH --cpus-per-task='$np | cat >> $i.slurm
  echo '#SBATCH --mem='$ms'gb' | cat >> $i.slurm
  echo '#SBATCH --job-name='$i | cat >> $i.slurm
  echo '#SBATCH --output='$i.out | cat >> $i.slurm
  echo '#SBATCH --partition=smp' | cat >> $i.slurm
  echo ' ' | cat >> $i.slurm  
  echo module purge | cat >> $i.slurm
  echo module load gaussian/16-A.03 | cat >> $i.slurm
  echo ' ' | cat >> $i.slurm
  echo cp $i.g16 '$SLURM_SCRATCH' | cat >> $i.slurm
  echo cd '$SLURM_SCRATCH' | cat >> $i.slurm
  echo ' ' | cat >> $i.slurm
  echo ulimit -s unlimited | cat >> $i.slurm
  echo export LC_COLLATE=C | cat >> $i.slurm
  echo ' ' | cat >> $i.slurm
  echo 'g16 < $SLURM_JOB_NAME.g16' | cat >> $i.slurm
  echo cp $i.chk '$SLURM_SUBMIT_DIR' | cat >> $i.slurm
  echo ' ' | cat >> $i.slurm  
  echo ' ' | cat >> $i.slurm

  cd ..
  sleep 3
done

