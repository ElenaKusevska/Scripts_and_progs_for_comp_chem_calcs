#!/usr/bin/python

# Script to perform conformer search for preparing good initial structures
# close to the global minimum for DFT optimization

import dft_conf_routines
import sys
import os
import time
import pybel
import openbabel
from pybel import ob

start = time.time()

# Check if the the correct number of commandline arguments has 
# been used, as in: python3 find_best_conformer.py test_mol.xyz
if len(sys.argv) != 2:
    print('number of arguments is ' + str(len(sys.argv)) + '. Should be 2', '\n')
    sys.exit()

# From the given input xyz, for example test_mol.xyz, get the
# filename (test_mol) and the extension (.xyz)
filename = sys.argv[1]
extension = os.path.splitext(filename)[1]

# Details for the gaussian input file:
gaussinputname = os.path.splitext(filename)[0]
job_type = 'opt freq'
method = 'm062x/6-31+g(d)'
other_keywords = 'scrf=(smd,solvent=chloroform) gfinput'
charge = '0'
multiplicity = '1'
memory = '16'
nproc = '8'

# Read the molecule from the supplied file:
mol1 = next(pybel.readfile(extension[1:], filename))
mol2 = next(pybel.readfile(extension[1:], filename))
mol3 = next(pybel.readfile(extension[1:], filename))
print("Molecule read. Number of atoms: ", len(mol3.atoms), '\n')

# Do you want to find a good structure for dft optimization,
# Or do you just want to print a gaussian input file and
# slurm file?
opt = input('Search for low energy conformer [Y], or just create gaussian input file and slurm script? [N] ')

# If you want to find a good input geometry for DFT for the structure
# in the original .xyz file:
if opt == 'Y':
   # Set up the force field / check if the force field can be set up 
   # successfully:
   ff = pybel._forcefields["mmff94"]
   if ff.Setup(mol1.OBMol) is False:
       ff = pybel._forcefields["uff"]
       if ff.Setup(mol1.OBMol) is False:
           exit("Cannot set up forcefield")

   # File to print structures generated from optimization
   # and rotor searches:
   outputname = 'initial_final_structure'
   
   # Find a global minimum / good initial geometry for DFT optimization
   # and print the geometries / energies for each of these steps to a
   # .xyz file:
      
   # E1 - mol1 - random rotor search:
   ff.SetCoordinates(mol1.OBMol)
   E1 = ff.Energy(False) # false = don't compute gradients
   dft_conf_routines.writesxyz(mol1, outputname, E1, overwrite=False)
   
   ff.SteepestDescent(1000, 1.0e-4)
   ff.GetCoordinates(mol1.OBMol)
   E1 = ff.Energy(False)
   dft_conf_routines.writesxyz(mol1, outputname, E1, overwrite=False)
   print('mol1 - SteepestDescent - done', '\n')
   
   ff.RandomRotorSearch(250,150)
   E1 = ff.Energy(False)
   ff.GetCoordinates(mol1.OBMol)
   dft_conf_routines.writesxyz(mol1, outputname, E1, overwrite=False)
   print('mol1  RandomRotorSearch - done', '\n')
   
   # E2 - mol2 - weighted rotor search:
   ff.SetCoordinates(mol2.OBMol)
   E2 = ff.Energy(False)
   dft_conf_routines.writesxyz(mol2, outputname, E2, overwrite=False)
   
   ff.SteepestDescent(1000, 1.0e-4)
   ff.GetCoordinates(mol2.OBMol)
   E2 = ff.Energy(False) 
   dft_conf_routines.writesxyz(mol2, outputname, E2, overwrite=False)
   print('mol2 - SteepestDescent - done', '\n')
   
   ff.WeightedRotorSearch(250, 150)
   E2 = ff.Energy(False) 
   ff.GetCoordinates(mol2.OBMol)
   dft_conf_routines.writesxyz(mol2, outputname, E2, overwrite=False)
   print('mol2 - WeightedRotorSearch 1 - done', '\n')
   
   # E3 - mol3 - weighted rotor search:
   ff.SetCoordinates(mol3.OBMol)
   E3 = ff.Energy(False)
   dft_conf_routines.writesxyz(mol3, outputname, E3, overwrite=False)
   
   ff.SteepestDescent(1000, 1.0e-4)
   ff.GetCoordinates(mol3.OBMol)
   E3 = ff.Energy(False) 
   dft_conf_routines.writesxyz(mol3, outputname, E3, overwrite=False)
   print('mol3 - SteepestDescent - done', '\n')
   
   ff.WeightedRotorSearch(250, 200)
   E3 = ff.Energy(False)
   ff.GetCoordinates(mol3.OBMol)
   dft_conf_routines.writesxyz(mol3, outputname, E3, overwrite=False)
   print('mol3 - WeightedRotorSearch 1 - done', '\n')
   
   # Conjugate gradients on the lowest energy 
   # result from the rotor searches:
   if E1 <= E2:
      if E1 <= E3:
         ff.SetCoordinates(mol1.OBMol)
         E1 = ff.Energy(False)
         dft_conf_routines.writesxyz(mol1, outputname, E1, overwrite=False)
   
         ff.ConjugateGradients(500, 1.0e-6)
         ff.GetCoordinates(mol1.OBMol)
         E1 = ff.Energy(False) # false = don't compute gradients
         dft_conf_routines.writesxyz(mol1, outputname, E1, overwrite=False)
         print('mol1 - conjugate gradients - done', '\n')
         dft_conf_routines.prepare_gauss_input(mol1, gaussinputname, job_type, method, other_keywords, charge, multiplicity, memory, nproc)
   if E2 <= E1:
      if E2 <= E3:
         ff.SetCoordinates(mol2.OBMol)
         E2 = ff.Energy(False)
         dft_conf_routines.writesxyz(mol2, outputname, E2, overwrite=False)
   
         ff.ConjugateGradients(500, 1.0e-6)
         ff.GetCoordinates(mol2.OBMol)
         E2 = ff.Energy(False) # false = don't compute gradients
         dft_conf_routines.writesxyz(mol2, outputname, E2, overwrite=False)
         print('mol2 - conjugate gradients - done', '\n')
         dft_conf_routines.prepare_gauss_input(mol2, gaussinputname, job_type, method, other_keywords, charge, multiplicity, memory, nproc)
   if E3 <= E1:
      if E3 <= E2:
         ff.SetCoordinates(mol3.OBMol)
         E3 = ff.Energy(False)
         dft_conf_routines.writesxyz(mol3, outputname, E3, overwrite=False)
   
         ff.ConjugateGradients(500, 1.0e-6)
         ff.GetCoordinates(mol3.OBMol)
         E3 = ff.Energy(False) # false = don't compute gradients
         dft_conf_routines.writesxyz(mol3, outputname, E3, overwrite=False)
         dft_conf_routines.prepare_gauss_input(mol3, gaussinputname, job_type, method, other_keywords, charge, multiplicity, memory, nproc)
         print('mol3 - conjugate gradients - done', '\n')

# If you just want to write a gaussian input file with the geometry in
# the original .xyz file:
else:
   print('Printing Gaussian input file with structure from ' + filename + ':', '\n')
   dft_conf_routines.prepare_gauss_input(mol1, gaussinputname, job_type, method, other_keywords, charge, multiplicity, memory, nproc)

# Finally, prepare slurm gaussian job file:
dft_conf_routines.prepare_slurm_file(gaussinputname, memory, nproc)

elapsed = time.time() - start
print('elapsed time:', elapsed, '\n')
