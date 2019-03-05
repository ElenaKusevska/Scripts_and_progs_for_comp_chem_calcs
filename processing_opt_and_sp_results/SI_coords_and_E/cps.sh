SI='SI_coords'
mkdir SI_coords/sp
mkdir SI_coords/opt

for i in opt sp
do
   cp -r  $i'/36_Cl/36_1_modred_52_54_b' $SI'/'$i'/Ia' 
   cp -r  $i'/38_Cl/38_Cl_a_3_39_b_38_40' $SI'/'$i'/38_Cl'
   cp -r  $i'/37/37_4' $SI'/'$i'/Ib'
   cp -r  $i'/43/43_11' $SI'/'$i'/Ic'
   cp -r  $i'/44/44_a' $SI'/'$i'/Id'
   cp -r  $i'/40/40_b_13' $SI'/'$i'/Ie'
   cp -r  $i'/11/11b' $SI'/'$i'/If'
   cp -r  $i'/8/8_doublet' $SI'/'$i'/Ic_'
   cp -r  $i'/7/7b' $SI'/'$i'/IIc_'
   cp -r  $i'/39/39_6' $SI'/'$i'/IIIc_'
   cp -r  $i'/41/41' $SI'/'$i'/Id_'
   cp -r  $i'/45/45_b_20' $SI'/'$i'/IId_'
done
