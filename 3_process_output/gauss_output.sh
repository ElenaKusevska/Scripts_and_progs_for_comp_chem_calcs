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
            # reset thermochemistry variables:
            energy=' '
            zero_point=' '
            enthalpy=' '
            gibbs=' '

            # start processing the putput file
            #echo '--------------------------------'
            #echo $i
            #echo '--------------------------------'
            #echo ' '
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
            grep '#p' -A4 *.g16 >> output
            echo ' ' | cat >> output

            # Did the job finish succesfully?
            echo '--------------------------------' | cat >> output
            echo 'Did the job finish succesfully?' | cat >> output
            echo '--------------------------------' | cat >> output
            echo ' ' | cat >> output
            cat *.out | tail -7 >> output
            echo ' ' | cat >> output

            # HOMO/LUMO (pop=full):
            echo '--------------------------------' | cat >> output
            echo 'HOMO/LUMO' | cat >> output
            echo '--------------------------------' | cat >> output
            echo ' ' | cat >> output
            grep 'Population analysis using the SCF' -A 1000 *.out | tail -1001 | grep ' Alpha  occ. eigenvalues --' | tail -1 >> output
            grep 'Population analysis using the SCF' -A 1000 *.out | tail -1001 | grep ' Alpha virt. eigenvalues --' | head -1 >> output   
            echo ' ' | cat >> output

            # Are there any negative frequencies?
            echo '--------------------------------' | cat >> output
            echo 'Frequencies' | cat >> output
            echo '--------------------------------' | cat >> output
            echo ' ' | cat >> output
            grep 'Frequencies' *.out | head -1 >> output 
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

            zero_point=$(grep 'Sum of electronic and zero-point Energies=' *.out \
            | tail -1 | cut -c54-65)

            enthalpy=$(grep 'Sum of electronic and thermal Enthalpies=' *out \
            | tail -1 | cut -c54-65)

            gibbs=$(grep 'Sum of electronic and thermal Free Energies=' *out \
            | tail -1 | cut -c54-65)

            cpu_time=$(grep 'Job cpu time:' *out | cut -c22-65 \
            | sed -e 's/ /_/g' | sed -e 's/days/d/g' \
            | sed -e 's/hours/h/g' | sed -e 's/minutes/m/g'\
            | sed -e 's/seconds/s/g' | sed -e 's/__/_/g' )

            elapsed_time=$(grep 'Elapsed time' *out | cut -c22-65 \
            | sed -e 's/ /_/g' | sed -e 's/days/d/g' \
            | sed -e 's/hours/h/g' | sed -e 's/minutes/m/g'\
            | sed -e 's/seconds/s/g' | sed -e 's/__/_/g' ) 

            frequencies=$(grep 'Frequencies' *out | tail -1 | cut -c16-35)

            echo ' ' | cat >> output

            #echo ' '
            #echo '    thermochemistry (E, E0, H, G) frequencies cpu_time elapsed_time:'
            echo $i $energy $zero_point $enthalpy $gibbs '    ' $frequencies '    ' $cpu_time $elapsed_time
            #echo ' '

            cd ..
         else
            echo the file $(pwd)/$i.out does not exist
         fi
      else
         echo the directory $(pwd)/$i does not exist
      fi
      sleep 2
   done
fi

