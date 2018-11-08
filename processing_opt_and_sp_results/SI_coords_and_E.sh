#!/bin/bash

# Script to get energies and coordinates out of output.txt files

opt='1_opt_m062x_6-31+gd'  
sp='2_sp_m062x_6-311+gdp'

if [ $# -eq 0 ]; then
   echo ' '
   echo $0: no arguments provided for "gauss_output.txt.sh"
   echo ' '
   exit 1
elif [ $# -ne 0 ]; then
  for i in $@
	do
    # single point energies
  	cd $sp
      cd $i
        echo $(pwd)

      	# reset all energies and level of theory:
      	level_of_theory_sp=' '
      	SCF_E_sp=' '

      	# assign energy and level of theory:
      	level_of_theory_sp_1=$(grep '#p' $i.g09 | awk -F'/' '{print $1}' |\
          awk 'NF>1{print $NF}')
        level_of_theory_sp_2=$(grep '#p' $i.g09 | awk -F'/' '{print $2}' |\
          awk '{print $1}')
        level_of_theory_sp=$level_of_theory_sp_1'/'$level_of_theory_sp_2
      	SCF_E_sp=$(grep 'SCF Done' *.out | tail -1 | cut -c26-39)
    	cd ..
  	cd ..
    # Optimization and printing coordinates:
  	cd $opt
    	cd $i
        echo  $(pwd)
      	# reset all energies and level of theory:
      	job_opt=' '
      	SCF_E_opt=' '
      	zero_point=' '
      	enthalpy=' '
      	gibbs=' '

      	# assign energies and level of theory:
        level_of_theory_opt_1=$(grep '#p' $i.g09 | \
          awk -F'/' '{print $1}' | awk '    NF>1{print $NF}')
        level_of_theory_opt_2=$(grep '#p' $i.g09 | \
          awk -F'/' '{print $2}' | awk '{print $1}')
        level_of_theory_opt=$level_of_theory_opt_1'/'$level_of_theory_opt_2
      	SCF_E_opt=$(grep 'SCF Done' *.out | tail -1 | cut -c26-39)
      	zero_point=$(grep 'Sum of electronic and zero-point Energies=' \
        	*.out | tail -1 | cut -c54-65)
      	enthalpy=$(grep 'Sum of electronic and thermal Enthalpies=' \
        	*out | tail -1 | cut -c54-65)
      	gibbs=$(grep 'Sum of electronic and thermal Free Energies=' \
        	*out | tail -1 | cut -c54-65)

      	# print to output.txt file:
      	echo '------------------------------' | cat >> ../../output.txt
      	echo '        ' $i | cat >> ../../output.txt
      	echo '------------------------------' | cat >> ../../output.txt
      	echo ' ' | cat >> ../../output.txt
      
      	echo $level_of_theory_opt 'SCF energy:         ' $SCF_E_opt \
          | cat >> ../../output.txt
      	echo $level_of_theory_opt 'zero point energy:  ' $zero_point \
          | cat >> ../../output.txt
      	echo $level_of_theory_opt 'enthalpy:           ' $enthalpy \
          | cat >> ../../output.txt
      	echo $level_of_theory_opt 'free energy:        ' $gibbs \
          | cat >> ../../output.txt
      	echo ' ' | cat >> ../../output.txt
      
      	echo $level_of_theory_sp 'SCF energy:      ' $SCF_E_sp | \
          cat >> ../../output.txt
      	echo ' ' | cat >> ../../output.txt
      
      	# get cordinates and print them to file:
      	echo 'Cartesian coordinates:' | cat >> ../../output.txt
        echo 'atom         x            y          z' | \
          cat >> ../../output.txt
      	sed -n 'H; /Standard orientation/h; ${g;p;}' $i.out | sed -n '/Standard orientation/,/Rotational/p' | sed -n '/1/,/----/p' | sed -n '/-------------/q;p' | sed -n 's/ 6 / C /g;p' | sed -n 's/ 1 / H /g;p' | sed -n 's/ 7 / N /g;p' | sed -n 's/ 8 / O /g;p' | sed -n 's/ 17 /  Cl/g;p' | cut -c 17-19,32-95 | cat >> ../../output.txt
      	echo ' ' | cat >> ../../output.txt

      	sed -n 'H; /Standard orientation/h; ${g;p;}' $i.out | sed -n '/Standard orientation/,/Rotational/p' | sed -n '/1/,/----/p' | sed -n '/-------------/q;p' | sed -n 's/ 6 / C /g;p' | sed -n 's/ 1 / H /g;p' | sed -n 's/ 7 / N /g;p' | sed -n 's/ 8 / O /g;p' | sed -n 's/ 17 /  Cl/g;p' | cut -c 17-19,32-95 | cat | wc -l | cat >> ../../coords.xyz
        echo $i | cat >> ../../coords.xyz
        sed -n 'H; /Standard orientation/h; ${g;p;}' $i.out | sed -n '/Standard orientation/,/Rotational/p' | sed -n '/1/,/----/p' | sed -n '/-------------/q;p' | sed -n 's/ 6 / C /g;p' | sed -n 's/ 1 / H /g;p' | sed -n 's/ 7 / N /g;p' | sed -n 's/ 8 / O /g;p' | sed -n 's/ 17 /  Cl/g;p' | cut -c 17-19,32-95 | cat >> ../../coords.xyz
#      	echo ' ' | cat >> ../../coords.xyz

    	cd ..
  	cd ..
	done
fi

#sed -n 'H; /Standard orientation/h; ${g;p;}' 1.out | sed -n '/Standard orientation/,/Rotational/p' | sed -n '/1/,/ ----/p'

#sed -n H; /Input/h; ${g;p;}' 1.out | sed -n '/Input orientation/,/Distance/p' | sed -n '/1/,/----/p'
