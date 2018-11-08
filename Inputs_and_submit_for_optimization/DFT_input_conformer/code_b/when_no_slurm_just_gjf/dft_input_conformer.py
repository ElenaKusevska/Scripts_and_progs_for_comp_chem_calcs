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
    print('number of arguments is ' + str(len(sys.argv)) + 
            '. Should be 2', '\n')
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
jobtime='48:00:00'

# Read the molecule from the supplied file:
mol = next(pybel.readfile(extension[1:], filename))
mol1 = next(pybel.readfile(extension[1:], filename))
print("Molecule read. Number of atoms: ", len(mol.atoms), '\n')

# Do you want to find a good structure for dft optimization,
# Or do you just want to print a gaussian input file and
# slurm file?
opt = input('Search for low energy conformer [Y], '
      'or just create gaussian input file and slurm script? [N] \n')

# If you want to find a good input geometry for DFT for the structure
# in the original .xyz file:
if opt == 'Y':
   # Set up the force field / check if the force field can be set up 
   # successfully:
   ff = pybel._forcefields["mmff94"]
   if ff.Setup(mol.OBMol) is False:
       ff = pybel._forcefields["uff"]
       if ff.Setup(mol.OBMol) is False:
           exit("Cannot set up forcefield")

   # File to print structures generated from optimization
   # and rotor searches:
   outputname = 'generated_geometries'

   # Write gaussian and slurm file for initian geometry:
   print('Writing Gaussian input file and slurm file ' 
           'with structure from initial geometry \n')
   
   dft_conf_routines.prepare_gauss_input(mol, gaussinputname, 
           job_type, method, other_keywords, charge, 
           multiplicity, memory, nproc)
   
#   dft_conf_routines.prepare_slurm_file(gaussinputname, memory, 
#           nproc, jobtime)

   # create directory "gaussinputname":
   current_directory = os.getcwd()
   final_directory = os.path.join(current_directory, gaussinputname)
   if not os.path.exists(final_directory):
          os.makedirs(final_directory)
   # move gaussian input file and slurm file there:
   os.rename(current_directory + "/" + gaussinputname + ".gjf", 
           final_directory + "/" + gaussinputname + ".gjf")
#   os.rename(current_directory + "/" + gaussinputname + ".slurm",
#           final_directory + "/" + gaussinputname + ".slurm")

   print('Writing initial geometry to generated_geometries.xyz\n')
   ff.SetCoordinates(mol.OBMol)
   E = ff.Energy(False)
   dft_conf_routines.writesxyz(mol, outputname, E, overwrite=True)

   # Find some random geometries for DFT optimization
   # and print the geometries / energies for each of these steps to a
   # .xyz file:

   # E1-E5 weighted rotor search:
   for i in range(1, 2):
      print('mol - WeightedRotorSearch -', i, 'start', '\n')

      # find some conformer
      ff.SetCoordinates(mol.OBMol)  
      ff.WeightedRotorSearch(250, 150)
      ff.GetCoordinates(mol.OBMol)
      E = ff.Energy(False) 
     
      # write geometry to files:
      dft_conf_routines.writesxyz(mol, outputname, E, overwrite=False)
      ginputname = gaussinputname + '_' + str(i)
      dft_conf_routines.prepare_gauss_input(mol, ginputname, 
              job_type, method, other_keywords, charge, 
              multiplicity, memory, nproc)
      #dft_conf_routines.prepare_slurm_file(ginputname, memory, 
#              nproc, jobtime)

      # create directory "ginputname":
      current_directory = os.getcwd()
      final_directory = os.path.join(current_directory, gaussinputname)
      if not os.path.exists(final_directory):
             os.makedirs(final_directory)
      # move gaussian input file and slurm file there:
      os.rename(current_directory + "/" + ginputname + ".gjf", 
              final_directory + "/" + ginputname + ".gjf")
 #     os.rename(current_directory + "/" + ginputname + ".slurm",
#              final_directory + "/" + ginputname + ".slurm")
#
      print('mol - WeightedRotorSearch -', i, 'done', '\n')
      
   # E1 - mol - random rotor search:
   for i in range(5, 6):
      print('mol  RandomRotorSearch -',i, 'start', '\n')

      # find some conformer:
      ff.SetCoordinates(mol1.OBMol)
      ff.RandomRotorSearch(250,150)
      ff.GetCoordinates(mol1.OBMol)
      E = ff.Energy(False)
     
      # write geometry to files:
      dft_conf_routines.writesxyz(mol1, outputname, E, overwrite=False)
      ginputname = gaussinputname + '_' + str(i)
      dft_conf_routines.prepare_gauss_input(mol1, ginputname, 
              job_type, method, other_keywords, charge, 
              multiplicity, memory, nproc)
      #dft_conf_routines.prepare_slurm_file(ginputname, memory, 
     #         nproc, jobtime)
      
      # create directory "ginputname":
      current_directory = os.getcwd()
      final_directory = os.path.join(current_directory, gaussinputname)
      if not os.path.exists(final_directory):
             os.makedirs(final_directory)
      # move gaussian input file and slurm file there:
      os.rename(current_directory + "/" + ginputname + ".gjf", 
              final_directory + "/" + ginputname + ".gjf")
      #os.rename(current_directory + "/" + ginputname + ".slurm",
      #        final_directory + "/" + ginputname + ".slurm")

      print('mol1  RandomRotorSearch -', i, 'done', '\n')

# If you just want to write a gaussian input file and slurm script
# with the geometry in the original .xyz file:
else:
   print('Printing Gaussian input file and slurm script '
           'with structure from ' + filename + ':', '\n')

   dft_conf_routines.prepare_gauss_input(mol1, gaussinputname, 
           job_type, method, other_keywords, charge, 
           multiplicity, memory, nproc)

   dft_conf_routines.prepare_slurm_file(gaussinputname, memory, nproc)

# Calculate and print time:
elapsed = time.time() - start
print('elapsed time:', elapsed, '\n')
