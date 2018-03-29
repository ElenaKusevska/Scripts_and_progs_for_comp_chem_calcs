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
#   rm $i.out $i.chk
#   rm output
   sed -i -e 's/0 1/1 2/g' $i.g09
   cd ..
done

