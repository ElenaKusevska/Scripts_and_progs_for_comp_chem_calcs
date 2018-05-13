#!/bin/bash

if [ $# -eq 0 ]; then
   echo ' '
   echo $0: no arguments provided for "gauss_output.sh"
   echo ' '
   exit 1
elif [ $# -ne 0 ]; then
   for i in $@
   do
      if [ -d "$(pwd)/$i" ]; then
         cd $i
         if [ -f "$(pwd)/$i.out" ]; then
            echo $i
            echo ' ' | cat >> output
            echo '--------------------------------' | cat >> output
            echo $i: | cat >> output
            echo '--------------------------------' | cat >> output
            echo ' ' | cat >> output
   
            # Level of theory:
            echo '--------------------------------' | cat >> output
            echo 'Level of Theory:' | cat >> output
            echo '--------------------------------' | cat >> output
            echo ' ' | cat >> output
            grep '#p' -A4 *.g09 >> output
            echo ' ' | cat >> output

            # Did the job finish succesfully?
            echo '--------------------------------' | cat >> output
            echo 'Did the job finish succesfully?' | cat >> output
            echo '--------------------------------' | cat >> output
            echo ' ' | cat >> output
            cat *.out | tail -7 >> output
            echo ' ' | cat >> output

            # HOMO/LUMO:
            echo '--------------------------------' | cat >> output
            echo 'HOMO/LUMO' | cat >> output
            echo '--------------------------------' | cat >> output
            echo ' ' | cat >> output
            grep 'Population analysis using the SCF' -A 1000 *.out | tail -1001 | grep ' Alpha  occ. eigenvalues --' | tail -1 >> output
            grep 'Population analysis using the SCF' -A 1000 *.out | tail -1001 | grep ' Alpha virt. eigenvalues --' | head -1 >> output   
            echo ' ' | cat >> output

            # Energy:
            echo '--------------------------------' | cat >> output
            echo 'Electronic energy:' | cat >> output
            echo '--------------------------------' | cat >> output
            echo ' ' | cat >> output
            grep 'SCF Done' *.out | tail -1 >> output
            echo ' ' | cat >> output
            energy=$(grep 'SCF Done' *.out | tail -1 | cut -c26-39)
      
            # Thermochemistry:
            echo '--------------------------------' | cat >> output
            echo 'Thermochemistry:' | cat >> output
            echo '--------------------------------' | cat >> output
            echo ' ' | cat >> output

            grep 'Thermal correction' $i.out >> output
            grep 'Sum of electronic' $i.out >> output

            zero_point=$(grep 'Sum of electronic and zero-point Energies=' *.out | tail -1 | cut -c55-65)

            enthalpy=$(grep 'Sum of electronic and thermal Enthalpies=' *out | tail -1 | cut -c55-65)

            gibbs=$(grep 'Sum of electronic and thermal Free Energies=' *out | tail -1 | cut -c55-65)

            echo ' ' | cat >> output
            cd ..
            
            echo 'thermochemistry (E, E0, H, G):'
            echo $energy $zero_point $enthalpy $gibbs
         else
            echo the file $(pwd)/$i.out does not exist
         fi
      else
         echo the directory $(pwd)/$i does not exist
      fi
      sleep 5
   done
fi

