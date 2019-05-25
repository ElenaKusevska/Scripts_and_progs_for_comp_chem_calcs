#!/bin/bash

for i in 1
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

         hr=48 # projected run time of job
			np=12 # number of processors
         # determine memory for job (memory line in gaussian input file):
         float=$(bc <<< $np*4.5) # 4.5 gb per processor
         last=${float#*.}
         if [ $last -eq 5 ] # if $np*4.5 = xx.5
         then
            mg=$float
         elif [ $last -eq 0 ] # if $np*4.5 = xx.0, i.e. is a whole number
         then
            mg=${float%.*} # remove the .0 at the end
         else
            echo 'some kind of unusual result happened:'
            echo '$float='$float' $last='$last
            exit
         fi

  			#-----------------------------------------------
  			# Prepare the Gaussian input file:
  			#-----------------------------------------------

  			echo %nprocshared=$np | cat >> $i.com
  			echo %Mem=$mg'GB' | cat >> $i.com
  			echo %chk=$i.chk | cat >> $i.com

			if [[ $j == "DMF" ]]; then
  				echo '#p opt freq=noraman 5d '$k'/6-31+g(d) scrf(smd,solvent=n,n-DiMethylFormamide) gfinput' | cat >> $i.com
			elif [[ $j == "gas" ]]; then
            echo '#p opt freq=noraman 5d '$k'/6-31+g(d) gfinput' | cat >> $i.com
         elif [[ $j == "o-DCB" ]]; then
            echo '#p opt freq=noraman 5d '$k'/6-31+g(d) scrf(smd,solvent=o-DiChloroBenzene) gfinput' | cat >> $i.com
         fi

  			echo ' ' | cat >> $i.com
  			echo 'job title = '$i | cat >> $i.com
  			echo ' ' | cat >> $i.com

  			echo '0 1' | cat >> $i.com
  			sed -n '/^0/,/^$/p' $i.gjf | tail -n+2 | cat >> $i.com
  			echo ' ' | cat >> $i.com

  			#-------------------------------------------
  			# Prepare the slurm script:
  			#-------------------------------------------

 			echo '#!/usr/bin/csh' | cat >> $i.cmd
  			echo '#SBATCH -t '$hr':00:00' | cat >> $i.cmd
  			echo '#SBATCH -N 1' | cat >> $i.cmd
  			echo '#SBATCH -p RM-shared' | cat >> $i.cmd
  			echo '#SBATCH --ntasks-per-node '$np | cat >> $i.cmd
  			echo ' ' | cat >> $i.cmd
         echo 'set echo on' | cat >> $i.cmd
  			echo 'module load gaussian' | cat >> $i.cmd
  			echo 'setenv GAUSS_SCRDIR $LOCAL' | cat >> $i.cmd
         echo 'setenv OMP_NUM_THREADS '$np | cat >> $i.cmd
         echo ' ' | cat >> $i.cmd
         echo 'source $g16root/g16/bsd/g16.login' | cat >> $i.cmd
         echo 'cd $SLURM_SUBMIT_DIR' | cat >> $i.cmd
         echo 'numactl -N +0 -m +0 g16 < '$i'.com  >& '$i'.out' | cat >> $i.cmd
         echo 'cp $LOCAL/* .' | cat >> $i.cmd
         echo ' ' | cat >> $i.cmd

         cd ..
         cd ..
         #sleep 1
      done
   done
done
