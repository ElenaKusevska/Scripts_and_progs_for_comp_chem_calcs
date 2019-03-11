#!/bin/bash

np=16 # number of processors
mg=24 # memory line in gaussian input file
ms=25 # requested memory in slurm file
hr=48 # projected run time of job

for i in 3
do
   for j in DMF gas o-DCB
   do
      for k in m062x b3lyp
      do
         echo $i $j $k
         maindir=$j'_'$k
         if [ -d "$maindir" ]
         then
         cd $j'_'$k
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
       
                  if [[ $j == "DMF" ]]; then
                     echo '#p opt freq=noraman 5d '$k'/6-31+g(d) scrf(smd,solvent=n,n-DiMethylFormamide) gfinput' | cat >> temp
                  elif [[ $j == "gas" ]]; then
                     echo '#p opt freq=noraman 5d '$k'/6-31+g(d) gfinput' | cat >> temp
                  elif [[ $j == "o-DCB" ]]; then
                     echo '#p opt freq=noraman 5d '$k'/6-31+g(d) scrf(smd,solvent=o-DiChloroBenzene) gfinput' | cat >> temp
                  fi
       
                  echo ' ' | cat >> temp
                  echo 'job title = '$i | cat >> temp
                  echo ' ' | cat >> temp
       
                  # take charge and multiplicity from original input file
                  sed -n '/^0\|^1\|^-1/ {p;q}' $i.g16 | cat >> temp

                  # print lines starting with ' C', ' H', ' N', ' O',
                  # ' Cl',  or ' S' in the .xyz file with the 
                  # intermediate geometry to the Gaussian input file: 
                  # (-n - supress double printing)
                  sed -n '/^ C\|^ H\|^ N \|^ O\|^Cl\|^ S/p' $xyzfile | cat >> temp
                  echo ' ' | cat >> temp

                  rm $i.g16
                  mv temp $i.g16
                  mv $i.out $i-failed_opt.log
                  rm -f $i.slurm $i.chk $i.fchk

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

               else
                  echo $xyzfile does not exist
                  exit
               fi

               cd ..
               cd ..
         
            else
               echo $i does not exist
               cd ..
            fi
         
         else
            echo $j'_'$k does not exist
         fi

      sleep 1

      done
   done
done
