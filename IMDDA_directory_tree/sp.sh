#!/bin/bash

for i in 9 9_1 9_2 9_3 9_4 9_5 9_6 9_7 9_8 9_9 9_10 9_11
do
   for j in DMF gas o-DCB
   do
      for k in m062x b3lyp
      do
         cd $j'_'$k # solvent and functional directory
         echo $i $j $k 
         if [ -d "$l" ]; then
            cd $i # chemical species directory
            
            np=16 # number of processors
            mg=24 # memory line in gaussian input file
            ms=25 # requested memory in slurm file
            hr=6 # projected run time of job
            
            #-----------------------------------------------
            # Prepare the Gaussian input file:
            #-----------------------------------------------

            echo %NProc=$np | cat >> temp
            echo %Mem=$mg'GB' | cat >> temp
            echo %chk=$i.chk | cat >> temp
            
            # gaussian job specification line depending on solvent:
            if [[ $j == "DMF" ]]; then
               echo '#p 5d '$k'/6-311+g(d) scrf(smd,solvent=n,n-DiMethylFormamide) Geom=Checkpoint pop=nbo output=wfn gfinput' | cat >> temp
            elif [[ $j == "gas" ]]; then
               echo '#p 5d '$k'/6-311+g(d) Geom=Checkpoint pop=nbo output=wfn gfinput' | cat >> temp
            elif [[ $j == "o-DCB" ]]; then
               echo '#p 5d '$k'/6-311+g(d) scrf(smd,solvent=o-DiChloroBenzene) Geom=Checkpoint pop=nbo output=wfn gfinput' | cat >> temp
            fi

			   echo ' ' | cat >> temp
  			   echo $i | cat >> temp
  			   echo ' ' | cat >> temp

  			   sed -n '/^0\|^1\|^-1/ {p;q}' $i.g16 | cat >> temp 
             			# just the line with charge and multiplicity

			   echo ' ' | cat >> temp
			   echo $i.wfn  | cat >> temp
			   echo ' ' | cat >> temp

			   rm $i.g16
			   mv temp $i.g16
			   mv $i.out $i-opt.log
			   rm -f $i.slurm $i.fchk $i.xyz $i.gjf output

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
  			   echo cp $i.chk '$SLURM_SCRATCH' | cat >> $i.slurm
  			   echo cd '$SLURM_SCRATCH' | cat >> $i.slurm
  			   echo ' ' | cat >> $i.slurm
  			   echo ulimit -s unlimited | cat >> $i.slurm
  			   echo export LC_COLLATE=C | cat >> $i.slurm
  			   echo ' ' | cat >> $i.slurm
  			   echo 'g16 < $SLURM_JOB_NAME.g16' | cat >> $i.slurm
  			   echo cp $i.chk '$SLURM_SUBMIT_DIR' | cat >> $i.slurm
  			   echo cp $i.wfn '$SLURM_SUBMIT_DIR' | cat >> $i.slurm
  			   echo ' ' | cat >> $i.slurm
  			   echo formchk $i.chk $i.fchk | cat >> $i.slurm
  			   echo cp $i.fchk '$SLURM_SUBMIT_DIR' | cat >> $i.slurm
  			   echo ' ' | cat >> $i.slurm
  			   echo ' ' | cat >> $i.slurm
            
            cd ..
            cd ..
            sleep 2
         else
            echo $pwd ' - does not exist'
            # exit
            cd ..
            sleep 5
         fi
      done
   done
done
