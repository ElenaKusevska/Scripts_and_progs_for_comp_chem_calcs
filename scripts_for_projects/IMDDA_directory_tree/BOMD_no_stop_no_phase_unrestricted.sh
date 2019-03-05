#!/bin/bash

for i in DA_TS1_run_1
do
   for j in gas
   do
      for k in b3lyp
      do
         echo $i $j $k
         if [ -d "$i" ]; then
            cd $i
            
            np=16 # number of processors
            mg=43 # memory line in gaussian input file
            ms=42 # requested memory in slurm file
            hr=100 # projected run time of job
            
            #-----------------------------------------------
            # Prepare the Gaussian input file:
            #-----------------------------------------------

            echo %NProc=$np | cat >> temp
            echo %Mem=$mg'GB' | cat >> temp
            #echo %chk=$i.chk | cat >> temp - don't really need chk in BOMD
            echo ' ' | cat >> temp
            
            # gaussian job specification line depending on solvent:
            if [[ $j == "DMF" ]]; then
               echo '#p BOMD(RTemp=300,MaxPoints=250) 5d u'$k'/6-31+g(d) scrf(smd,solvent=n,n-DiMethylFormamide) guess=(mix,always)' | cat >> temp
            elif [[ $j == "gas" ]]; then
               echo '#p BOMD(RTemp=300,MaxPoints=250) 5d u'$k'/6-31+g(d) guess=(mix,always)' | cat >> temp
            elif [[ $j == "o-DCB" ]]; then
               echo '#p BOMD(RTemp=300,MaxPoints=250) 5d u'$k'/6-31+g(d) scrf(smd,solvent=o-DiChloroBenzene) guess=(mix,always)' | cat >> temp
            fi

			   echo ' ' | cat >> temp
  			   echo 'job name: '$i | cat >> temp
  			   echo ' ' | cat >> temp

            # just the line with charge and multiplicity:
  			   sed -n '/^0\|^1\|^-1/ {p;q}' *.g16 | cat >> temp 

            # Get the coordinates at the last step in the geometry
            # optimization
            sed -n 'H; /Standard orientation/h; ${g;p;}' *.out | sed -n '/Standard orientation/,/Rotational/p' | sed -n '/1/,/----/p' | sed -n '/-------------/q;p' | cut -c 17-28,32-95 | sed -n 's/^17 / Cl /g;p' | sed -n 's/^ 6 / C /g;p' | sed -n 's/^ 1 / H /g;p' | sed -n 's/^ 7 / N /g;p' | sed -n 's/^ 8 / O /g;p' | sed -n 's/^16 / S /g;p' | cat >> temp

			   echo ' ' | cat >> temp

			   rm *.g16
			   mv temp $i.g16
            mv *.out $i-opt.log
			   rm -f *.slurm *.fchk *.chk *.xyz *.gjf *.out output

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
  			   echo '#SBATCH --partition=high-mem' | cat >> $i.slurm
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
  			   #echo cp $i.chk '$SLURM_SUBMIT_DIR' | cat >> $i.slurm
  			   echo ' ' | cat >> $i.slurm
  			   echo ' ' | cat >> $i.slurm

            cd .. 
            cd ..
         else
            echo 'not not exist'
            #exit
            pwd
            cd ..
         fi
         sleep 2
      done
   done
done
