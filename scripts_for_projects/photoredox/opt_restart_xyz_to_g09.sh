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
      xyzfile=$i'.xyz'
      if [ -e "$xyzfile" ]
      then
    
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

         # take charge and multiplicity from original input file
         sed -n '/^0\|^1\|^-1/ {p;q}' $i.g09 | cat >> temp

         # print lines starting with ' C', ' H', ' N', ' O', 
         # ' Cl',  or ' S' in the .xyz file with the intermediate geometry
         # to the Gaussian input file: (-n - supress double printing)
         sed -n '/^ C\|^ H\|^ N \|^ O\|^Cl\|^ S/p' $xyzfile | cat >> temp
         echo ' ' | cat >> temp

         rm $i.g09
         mv temp $i.g09
         mv $i.out $i-failed_opt.log
         rm -f $i.slurm $i.chk $i.fchk $i.gjf

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
         echo $xyz file does not exist
         exit
      fi
   else
      echo $i does not exist
      exit
   fi
done
