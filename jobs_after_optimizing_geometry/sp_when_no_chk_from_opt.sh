#!/bin/bash

for i in 9
do
   j= # solvent: DMF gas o-DCB
   k= # functional: b3lyp m062x
   if [ -d "$l" ]; then
      cd $i
      
      np=8 # number of processors
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
         echo '#p 5d '$k'/6-311+g(d,p) scrf(smd,solvent=n,n-DiMethylFormamide) pop=nbo output=wfn gfinput' | cat >> temp
      elif [[ $j == "gas" ]]; then
      echo '#p 5d '$k'/6-311+g(d,p) pop=nbo output=wfn gfinput' | cat >> temp
      elif [[ $j == "o-DCB" ]]; then
      echo '#p 5d '$k'/6-311+g(d,p) scrf(smd,solvent=o-DiChloroBenzene) pop=nbo output=wfn gfinput' | cat >> temp
      fi

	   echo ' ' | cat >> temp
  	   echo $i | cat >> temp
  	   echo ' ' | cat >> temp

      # just the line with charge and multiplicity:
  	   sed -n '/^0\|^1\|^-1/ {p;q}' $i.g16 | cat >> temp 

      # Get the coordinates at the last step in the geometry
      # optimization
      sed -n 'H; /Standard orientation/h; ${g;p;}' $i.out | sed -n '/Standard orientation/,/Rotational/p' | sed -n '/1/,/----/p' | sed -n '/-------------/q;p' | cut -c 17-28,32-95 | sed -n 's/^17 / Cl /g;p' | sed -n 's/^ 6 / C /g;p' | sed -n 's/^ 1 / H /g;p' | sed -n 's/^ 7 / N /g;p' | sed -n 's/^ 8 / O /g;p' | sed -n 's/^16 / S /g;p'

	   echo ' ' | cat >> temp
	   echo $i.wfn  | cat >> temp
	   echo ' ' | cat >> temp

	   rm $i.g16
	   mv temp $i.g16
      mv $i.out $i-opt.log
	   rm -f $i.slurm $i.fchk $i.xyz $i.gjf $i.out output

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
  	   echo cp $i.wfn '$SLURM_SUBMIT_DIR' | cat >> $i.slurm
  	   echo ' ' | cat >> $i.slurm
  	   echo formchk $i.chk $i.fchk | cat >> $i.slurm
  	   echo cp $i.fchk '$SLURM_SUBMIT_DIR' | cat >> $i.slurm
  	   echo ' ' | cat >> $i.slurm
  	   echo ' ' | cat >> $i.slurm

      cd .. 
   else
      echo 'does not exist'
      #exit
      pwd
   fi
   sleep 2
done
