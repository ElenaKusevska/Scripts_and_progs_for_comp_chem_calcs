for i in TS2_stepwise
do
   for j in DMF gas o-DCB
   do
      for k in m062x b3lyp
      do
         mkdir $j'_'$k
         cd $j'_'$k
			echo $i
         mkdir $i
         cd $i

         cp ../../$i'.gjf' ./

			np=16 # number of processors
			mg=24 # memory line in gaussian input file
			ms=25 # requested memory in slurm file
			hr=36 # projected run time of job

  			dos2unix $i.gjf

  			#-----------------------------------------------
  			# Prepare the Gaussian input file:
  			#-----------------------------------------------

  			echo %NProc=$np | cat >> $i.g16
  			echo %Mem=$mg'GB' | cat >> $i.g16
  			echo %chk=$i.chk | cat >> $i.g16

			if [[ $j == "DMF" ]]; then
  				echo '#p opt=(calcfc,ts,noeigen) freq=noraman 5d u'$k'/6-31+g(d) scrf(smd,solvent=n,n-DiMethylFormamide) guess=mix gfinput' | cat >> $i.g16
			elif [[ $j == "gas" ]]; then
            echo '#p opt=(calcfc,ts,noeigen) freq=noraman 5d u'$k'/6-31+g(d) gfinput guess=mix' | cat >> $i.g16
         elif [[ $j == "o-DCB" ]]; then
            echo '#p opt=(calcfc,ts,noeigen) freq=noraman 5d u'$k'/6-31+g(d)scrf(smd,solvent=o-DiChloroBenzene) guess=mix gfinput' | cat >> $i.g16
         fi

  			echo ' ' | cat >> $i.g16
  			echo 'job title ='$i | cat >> $i.g16
  			echo ' ' | cat >> $i.g16

  			echo '0 1' | cat >> $i.g16
  			sed -n '/^0\|^1\|^-1/,/^$/p' $i.gjf | tail -n+2 | cat >> $i.g16
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
         sleep 4
      done
   done
done
