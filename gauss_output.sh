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
      
            # Thermochemistry:
            echo '--------------------------------' | cat >> output
            echo 'Thermochemistry:' | cat >> output
            echo '--------------------------------' | cat >> output
            echo ' ' | cat >> output

            grep 'Thermal correction' 1.out >> output
            grep 'Sum of electronic' 1.out >> output

            echo ' ' | cat >> output
            grep 'Thermo' -A 60 1.out >> output 
            cd ..
         else
            echo the file $(pwd)/$i.out does not exist
         fi
      else
         echo the directory $(pwd)/$i does not exist
      fi
   done
fi

