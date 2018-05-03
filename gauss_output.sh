for i in "PhBr_PhBr"  "PhNO2_PhBr"  "PhNO2_PhNO2"  "PhOCH3_PhBr"  "PhOCH3_PhNO2"  "PhOCH3_PhOCH3"
do
   cd $i
   if [ $i == "PhOCH3_PhBr" ]
   then
      i="Br_OCH3"
   fi
   if [ $i == "PhBr_PhBr" ]
   then
      i="Br_Br"
   fi
   
   echo $i
   echo ' ' | cat >> ../output
   echo '--------------------------------' | cat >> ../output
   echo $i: | cat >> ../output
   echo '--------------------------------' | cat >> ../output
   echo ' ' | cat >> ../output
   
   # Level of theory:
   grep '#p' -A4 *.g09 >> ../output
   echo ' ' | cat >> ../output

   # HOMO/LUMO:
   grep 'Population analysis using the SCF' -A 1000 *.out | tail -1001 | grep ' Alpha  occ. eigenvalues --' | tail -1 >> ../output
   grep 'Population analysis using the SCF' -A 1000 *.out | tail -1001 | grep ' Alpha virt. eigenvalues --' | head -1 >> ../output   

   # Energy:
   grep 'SCF Done' *.out | tail -1 >> ../output

   echo ' ' | cat >> ../output
   echo '--------------------------------' | cat >> ../output
   
   cd ..
done

