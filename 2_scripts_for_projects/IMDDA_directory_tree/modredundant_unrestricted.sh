#!/bin/bash

redundantmod1='B 15 23 F' # ex: B 1 2 F
redundantmod2='B 36 24 F' # ex: B 1 2 F
charge=0
multiplicity=1

for i in 2-BT-e-DA_TS_OS_s-cis  3-BT-e-DA_TS_OS_s-cis 2-ind-e-DA_TS_OS_s-cis
do
   for j in DMF gas o-DCB
   do
      for k in b3lyp
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

         np=6 # number of processors
         mg=24 # memory line in gaussian input file
         ms=25 # requested memory in slurm file
         hr=40 # projected run time of job

         #-----------------------------------------------
         # Prepare the Gaussian input file:
         #-----------------------------------------------

         echo %NProc=$np | cat >> $i.g16
         echo %Mem=$mg'GB' | cat >> $i.g16
         echo %chk=$i.chk | cat >> $i.g16

         if [[ $j == "DMF" ]]; then
            echo '#p opt=modredundant freq=noraman 5d u'$k'/6-31+g(d) scrf(smd,solvent=n,n-DiMethylFormamide) guess=mix gfinput' | cat >> $i.g16
         elif [[ $j == "gas" ]]; then
            echo '#p opt=modredundant freq=noraman 5d u'$k'/6-31+g(d) guess=mix gfinput' | cat >> $i.g16
         elif [[ $j == "o-DCB" ]]; then
            echo '#p opt=modredundant freq=noraman 5d u'$k'/6-31+g(d) scrf(smd,solvent=o-DiChloroBenzene) guess=mix gfinput' | cat >> $i.g16
         fi

         echo ' ' | cat >> $i.g16
         echo 'job title = '$i | cat >> $i.g16
         echo ' ' | cat >> $i.g16

         echo $charge' '$multiplicity | cat >> $i.g16
         # delete training whitespaces before end of line character:
         sed -i 's/[ \t]*$//' $i.gjf
         sed -n "/^$charge/,/^$/p" $i.gjf | tail -n+2 | cat >> $i.g16
         # print all lines from line starting with '0 1 ', to first blank line

         # Add redundant mod
         echo $redundantmod1 | cat >> $i.g16
         echo $redundantmod2 | cat >> $i.g16
         echo ' ' | cat >> $i.g16
         echo ' ' | cat >> $i.g16

         # delete training whitespaces before end of line character:
         #sed -i 's/[ \t]*$//' $i.g16
         #sed -i -n  'N;/^\n$/d;P;D' $i.g16 # delete double blank lines

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
#        sleep 1
      done
   done
done
