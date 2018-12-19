#!/bin/bash

# DFT calculation details:
charge=0
multiplicity=1
solvent=gas
#solvent=n,n-DiMethylFormamide
#solvent=o-DiChloroBenzene
k= # functional: m062x b3lyp

# job details:
np=16 # number of processors
mg=24 # memory line in gaussian input file
ms=25 # requested memory in slurm file
hr=36 # projected run time of job

for i in 1 1_12  1_15  1_18  1_20  1_5 1_1   1_13  1_16  1_19  1_3 1_11  1_14  1_17  1_2   1_4 
do         
   mkdir $i
   if [ $? -ne 0 ] ; then
      echo "mkdir error"
      exit
   fi
   cp $i.gjf $i
   cd $i
   dos2unix $i.gjf

  	#-----------------------------------------------
  	# Prepare the Gaussian input file:
  	#-----------------------------------------------

  	echo %NProc=$np | cat >> $i.g16
  	echo %Mem=$mg'GB' | cat >> $i.g16
  	echo %chk=$i.chk | cat >> $i.g16

	if [[ $solvent == "gas" ]]; then
      echo '#p opt freq=noraman 5d '$k'/6-31+g(d) gfinput' | cat >> $i.g16
   else
      echo '#p opt freq=noraman 5d '$k'/6-31+g(d)scrf(smd,solvent='$solvent') gfinput' | cat >> $i.g16
   fi

  	echo ' ' | cat >> $i.g16
  	echo 'job title = '$i | cat >> $i.g16
  	echo ' ' | cat >> $i.g16

  	echo $charge' '$multiplicity | cat >> $i.g16

   # get coordinates out of .gjf file:
  	sed -n '/^0/,/^$/p' $i.gjf | tail -n+2 | cat >> $i.g16
         # print from after multiplicity line to first blank line
         # will not work properly without dos2unix first.

   #Other options for getting coordinates out of .gjf file:
   #sed -n '/^ C\|^ H\|^ N \|^ O/p' $i.gjf | cat >> $i.g16
         # print lines starting with ' C', ' H', ' N', or ' O'
   #sed -n '/^0\|^1\|^-1/,/^$/p' $i.gjf | cat >> $i.g16
         # same as above, including first line
         # -n - supress double printing

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
   sleep 3
done