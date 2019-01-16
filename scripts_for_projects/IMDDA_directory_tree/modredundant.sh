#!/bin/bash

redundantmod1='B 17 25 F' # ex: B 1 2 F
redundantmod2='B 7 26 F' # ex: B 1 2 F
charge=0
multiplicity=1

for i in TS1_birad_1  TS1_birad_2
do
   for j in DMF gas o-DCB
   do
      for k in m062x b3lyp
      do
         mkdir $j'_'$k 2>/dev/null
         cd $j'_'$k
			echo $i $j $k
         mkdir $i
         if [ $? -ne 0 ] ; then
            echo "mkdir error"
            exit
         fi
         cd $i
         cp ../../$i'.gjf' ./
         dos2unix $i'.gjf'

			np=16 # number of processors
			mg=24 # memory line in gaussian input file
			ms=25 # requested memory in slurm file
			hr=72 # projected run time of job

  			#-----------------------------------------------
  			# Prepare the Gaussian input file:
  			#-----------------------------------------------

  			echo %NProc=$np | cat >> $i.g16
  			echo %Mem=$mg'GB' | cat >> $i.g16
  			echo %chk=$i.chk | cat >> $i.g16

			if [[ $j == "DMF" ]]; then
  				echo '#p opt=modredundant freq=noraman 5d '$k'/6-31+g(d) scrf(smd,solvent=n,n-DiMethylFormamide) geom=connectivity gfinput' | cat >> $i.g16
			elif [[ $j == "gas" ]]; then
            echo '#p opt=modredundant freq=noraman 5d '$k'/6-31+g(d) geom=connectivity gfinput' | cat >> $i.g16
         elif [[ $j == "o-DCB" ]]; then
            echo '#p opt=modredundant freq=noraman 5d '$k'/6-31+g(d)scrf(smd,solvent=o-DiChloroBenzene) geom=connectivity gfinput' | cat >> $i.g16
         fi

  			echo ' ' | cat >> $i.g16
  			echo 'job title = '$i | cat >> $i.g16
  			echo ' ' | cat >> $i.g16

  			echo $charge' '$multiplicity | cat >> $i.g16
  			sed -n '/^ /,/^$/p' $i.gjf | cat >> $i.g16
  			# print all instances of from line starting with ' ', to first blank line

         # Add redundant mod
         echo $redundantmod1 | cat >> $i.g16
         echo $redundantmod2 | cat >> $i.g16
         echo ' ' | cat >> $i.g16

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


         cd ..
         cd ..
         sleep 1
      done
   done
done
