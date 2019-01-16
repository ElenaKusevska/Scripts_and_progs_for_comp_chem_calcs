#!/bin/bash

np=16 # number of processors
mg=24 # memory line in gaussian input file
ms=25 # requested memory in slurm file
hr=48 # projected run time of job

for i in 3
do
   echo $i
   if [ -d "$i" ]; then
   cd $i

   #-----------------------------------------------
   # Prepare the Gaussian input file:
   #-----------------------------------------------

   echo %NProc=$np | cat >> temp
   echo %Mem=$mg'GB' | cat >> temp
   echo %chk=$i.chk | cat >> temp
   echo '#p opt freq=noraman m062x/6-31+g(d) scrf=(smd,solvent=chloroform) gfinput' | cat >> temp
   echo ' ' | cat >> temp
  	echo 'job title = '$i | cat >> temp
  	echo ' ' | cat >> temp

   sed -n '/^0\|^1\|^-1/ {p;q}' $i.g09 | cat >> temp 
             	# just the line with charge and multiplicity
   sed -n 'H; /Standard orientation/h; ${g;p;}' $i.out | sed -n '/Standard orientation/,/Rotational/p' | sed -n '/1/,/----/p' | sed -n '/-------------/q;p' | cut -c 17-28,32-95 | sed -n 's/^17 / Cl/g;p' | sed -n 's/^ 6 / C /g;p' | sed -n 's/^ 1 / H /g;p' | sed -n 's/^ 7 / N /g;p' | sed -n 's/^ 8 / O /g;p' | sed -n 's/^16 / S /g;p' | cat >> temp
   echo ' ' | cat >> temp
   echo ' ' | cat >> temp

   rm $i.g09
   mv temp $i.g09
   mv $i.out $i-modredundant.log
   rm -f $i.slurm $i.chk $i.fchk $i.xyz $i.gjf output 

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

  fi
done
