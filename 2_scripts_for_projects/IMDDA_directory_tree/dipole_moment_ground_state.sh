#!/bin/bash

top_dir=$(pwd)
for i in '1/1_7' '2_adduct_cis/2' 4 3 '2_diene_cis/2_new_dd' '5/5_8' '6_adduct_cis/6_cis_6' 8 7 '6_diene_cis/6_new_uu' '9/9_10' '10_adduct_cis/10_cis_11' 12 11 '10_diene_cis/10_new_dd' '13/13_16' '14_adduct_cis' 16 '15/15_150' '14_diene_cis/14_diene_dd' '17/17_2' '18_adduct_cis' 20 19 '18_diene_cis/18_diene_uu' '21/21_18' '22_adduct_cis/22_cis_uu' 24 '23/23_d' '22_diene_cis/22_diene_uu'
do
   cd $i
   dipole=$(grep 'Dipole moment' -A 1 *.out | tail -1 | sed -n -e 's/^.*\(Tot= \)/\1/p')
   echo $i': '$dipole >> $top_dir'/dipole_moment'
   cd $top_dir
done
