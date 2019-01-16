#!/bin/bash

np=16 # number of processors
mg=24 # memory line in gaussian input file
ms=25 # requested memory in slurm file
hr=12 # projected run time of job
charge=0
multiplicity=1

for i in 3
do
   echo $i
   if [ -d "$i" ]
   then
      cd $i
      if [ -e $i'.g16' ]
      then
         mv $i'.g16' $i'.gjf'
      else
         echo $i'.g16 does not exist'
         exit
      fi
      rm $i.slurm

      #-----------------------------------------------
      # Prepare the Gaussian input file:
      #-----------------------------------------------

      echo %NProc=$np | cat >> $i.g09
      echo %Mem=$mg'GB' | cat >> $i.g09
      echo %chk=$i.chk | cat >> $i.g09
      echo '#p opt freq=noraman m062x/6-31+g(d) scrf=(smd,solvent=chloroform) gfinput' | cat >> $i.g09
      echo ' ' | cat >> $i.g09
      echo 'job title = '$i | cat >> $i.g09
      echo ' ' | cat >> $i.g09

      echo $charge' '$multiplicity | cat >> $i.g09
      #sed -n '/^0\|^1\|^-1/p' $i.gjf | cat >> $i.g09
          # print lines starting with 0, 1, or -1 (charge and multiplicity line)
      #sed -n '/^ C\|^ H\|^ N \|^ O/p' $i.gjf | cat >> $i.g09
          # print lines starting with ' C', ' H', ' N', or ' O'
      sed -n '/^0\|^1\|^-1/,/^$/p' $i.gjf | tail -n+2 | cat >> $i.g09
          # print from after multiplicity line to first blank line
          # will not work properly without dos2unix first.
      #sed -n '/^0\|^1\|^-1/,/^$/p' $i.gjf | cat >> $i.g09
          # same as above, including first line
          # -n - supress double printing

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
   else
      echo $i does not exist
   fi
done

