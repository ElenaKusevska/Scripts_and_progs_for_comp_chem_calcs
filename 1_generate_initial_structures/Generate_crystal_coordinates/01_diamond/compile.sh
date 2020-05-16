rm -f *.xyz *.in compile_out first_cell
gfortran -Wunused -Wall -Og -pedantic main.f95 > compile_out
cat compile_out
