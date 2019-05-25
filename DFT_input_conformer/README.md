# conformer_search

code a:
Script to generate a good conformer i.e. a good initial structure that is likely to be very close to the global minimum, that when used in a QM calculation will likely converge to the global minimum.

code b:
Script to generate several random conformers and print their gaussian
input files.

both:
It prints all the intermediary structures from the search to a .xyz 'optimization' file. It also prepares a gaussian input file and a slurm gaussian job script with the specified keywords and requested memory and number of processors. The name of the gaussian input file is the same as the name of the .xyz inputfile for the script.

Use as: python3 dft_input_conformer.py dft_conf_routines.py test_mol.xyz

But first, enter gaussian keywords on line: 28 

