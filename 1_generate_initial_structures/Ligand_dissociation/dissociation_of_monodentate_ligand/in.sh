#!/bin/bash

# To get the names of all xyz files in one line without the .xyz
# extension, so that they may be used as input for a loop on k,
# type the following command:
# ls *.xyz | cut -c1-29 | tr -d '\n' | sed 's/.xyz/ /g'

spin="1"
nproc="8"
memgauss=20

for i in "EmpiricalDispersion=GD3" #"No_dispersion_correction"
do
   for j in "method_6" # "method_1" "method_2" "method_3" "method_4" "method_5"
   do
      for k in geom_a geom_b geom_c geom_d geom_e geom_f
      do
         mkdir $k 2>/dev/null
         cd $k
         filename=$j"_"$k
         rm -f *.gjf *.sh

         #----------------------------------------------
         # Edit the input file:
         #----------------------------------------------

         echo "%NProcShared="$nproc >> $filename.gjf
         echo "%mem="$memgauss"GB" >> $filename.gjf
         echo "%chk="$filename".chk" >> $filename.gjf
         if [[ $j == "method_1" ]]
         then
            echo "#p opt=(calcfc) freq b3lyp/Gen Pseudo=Read gfinput" $i >> $filename.gjf
         fi
         if [[ $j == "method_2" ]]
         then
            echo "#p opt=(calcfc) freq b3lyp/Gen Pseudo=Read nosymm gfinput" $i >> $filename.gjf
         fi
         if [[ $j == "method_3" ]]
         then
            echo "#p opt=(calcfc) freq b3lyp/Gen Pseudo=Read Int=Ultrafine gfinput" $i >> $filename.gjf
         fi
         if [[ $j == "method_4" ]]
         then
            echo "#p opt=(calcfc) freq b3lyp/Gen Pseudo=Read Int=Ultrafine nosymm gfinput" $i >> $filename.gjf
         fi
         if [[ $j == "method_5" ]]
         then
            echo "#p opt=(calcfc,tight) freq b3lyp/Gen Pseudo=Read Int=Ultrafine gfinput" $i >> $filename.gjf
         fi
         if [[ $j == "method_6" ]]
         then
            echo "#p opt=(calcfc,tight) freq b3lyp/Gen Pseudo=Read Int=Ultrafine nosymm gfinput" $i >> $filename.gjf
         fi
         sed -i -e 's/No_dispersion_correction//g' $filename.gjf
         echo " " >> $filename.gjf
         echo " Optimization and frequency calculation" >> $filename.gjf
         echo " " >> $filename.gjf
         echo "0 "$spin >> $filename.gjf
      
         cp ../$k.gjf ./
         dos2unix $k.gjf
         sed -n '/^0/,/^$/p' $k.gjf | tail -n+2 | cat >> $filename.gjf

         echo "P F" >> $filename.gjf
         echo "6-31G+(d)" >> $filename.gjf
         echo "****" >> $filename.gjf
         echo "Pt 0" >> $filename.gjf
         echo "LANL2DZ" >> $filename.gjf
         echo "****" >> $filename.gjf
         echo " " >> $filename.gjf
         echo "Pt 0" >> $filename.gjf
         echo "LANL2DZ" >> $filename.gjf
         echo " " >> $filename.gjf
         
         cd ../
      done
   done
done
