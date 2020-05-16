#!/bin/bash

for i in 1_21 2 3 4 5_21 6 7 8 9_11 10 11 12
do
   for j in DMF gas o-DCB
   do
      for k in m062x b3lyp
      do
         mkdir $j'_'$k 2>/dev/null # add a propper if here - if directory
                           # does not exist, then create it...
         cd $j'_'$k
			echo $i $j $k
         mkdir $i
         cd $i
         cp -r ../../$i'.gjf' ./
         dos2unix $i.gjf

			np=8 # number of processors
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
            echo '#p opt freq=noraman 5d u'$k'/6-31+g(d) scrf(smd,solvent=n,n-DiMethylFormamide) guess=(mix,always) gfinput' | cat >> $i.g16
			elif [[ $j == "gas" ]]; then
            echo '#p opt freq=noraman 5d u'$k'/6-31+g(d) guess=(mix,always) gfinput' | cat >> $i.g16
         elif [[ $j == "o-DCB" ]]; then
            echo '#p opt freq=noraman 5d u'$k'/6-31+g(d) scrf(smd,solvent=o-DiChloroBenzene) guess=(mix,always) gfinput' | cat >> $i.g16
         fi

  			echo ' ' | cat >> $i.g16
  			echo 'job title = '$i | cat >> $i.g16
  			echo ' ' | cat >> $i.g16

  			echo '0 1' | cat >> $i.g16
  			sed -n '/^0/,/^$/p' $i.gjf | tail -n+2 | cat >> $i.g16
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
         #sleep 1
      done
   done
done
