rm -f *.xyz *.in compile_out first_cell
gfortran -Wunused -Wall -Og -pedantic module.f95 main.f95 > compile_out
cat compile_out
