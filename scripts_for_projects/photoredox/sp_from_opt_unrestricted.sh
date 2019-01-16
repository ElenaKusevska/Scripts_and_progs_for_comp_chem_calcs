#!/bin/bash

for i in 3
do
   echo $i
   if [ -d "$i" ]; then 
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
      echo '#p um062x/6-311+g(d,p) scrf(smd,solvent=chloroform) pop=nbo output=wfn Geom=Checkpoint gfinput' | cat >> temp

      echo ' ' | cat >> temp
      echo 'job title = '$i | cat >> temp
      echo ' ' | cat >> temp

      # spin and multiplicity:
      sed -n '/^0\|^1\|^-1/ {p;q}' $i.g09 | cat >> temp

      echo ' ' | cat >> temp
      echo $i.wfn  | cat >> temp
      echo ' ' | cat >> temp

      rm $i.g09
      mv temp $i.g09
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
     	echo module load gaussian/D.01 | cat >> $i.slurm
     	echo ' ' | cat >> $i.slurm
     	echo cp $i.g09 '$SLURM_SCRATCH' | cat >> $i.slurm
     	echo cp $i.chk '$SLURM_SCRATCH' | cat >> $i.slurm
     	echo cd '$SLURM_SCRATCH' | cat >> $i.slurm
     	echo ' ' | cat >> $i.slurm
     	echo ulimit -s unlimited | cat >> $i.slurm
     	echo export LC_COLLATE=C | cat >> $i.slurm
     	echo ' ' | cat >> $i.slurm
     	echo 'g09 < $SLURM_JOB_NAME.g09' | cat >> $i.slurm
     	echo cp $i.chk '$SLURM_SUBMIT_DIR' | cat >> $i.slurm
     	echo cp $i.wfn '$SLURM_SUBMIT_DIR' | cat >> $i.slurm
     	echo ' ' | cat >> $i.slurm
     	echo formchk $i.chk $i.fchk | cat >> $i.slurm
     	echo cp $i.fchk '$SLURM_SUBMIT_DIR' | cat >> $i.slurm
     	echo ' ' | cat >> $i.slurm
     	echo ' ' | cat >> $i.slurm
      
      cd ..
      sleep 2
   else
      echo $i does not exist
   fi
done


