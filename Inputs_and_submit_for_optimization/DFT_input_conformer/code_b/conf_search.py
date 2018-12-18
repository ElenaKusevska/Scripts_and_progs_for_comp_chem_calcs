import dft_conf_routines
import sys
import os
import time
import pybel
import openbabel
from pybel import ob

def weighted_rotor_search_on_mol(first_i, last_i, main_input, main_ext, outputname, gaussinputname, job_type, method, other_keywords, charge, multiplicity, memory, nproc, jobtime):

    # Read the molecule from the supplied file:
    mol = next(pybel.readfile(main_ext[1:], main_input))
    print("Molecule read. Number of atoms: ", len(mol.atoms), '\n')

    for i in range(first_i, last_i):
   
        # Set up the force field / check if the force field can be set up 
        # successfully:
        ff = pybel._forcefields["mmff94"]
        if ff.Setup(mol.OBMol) is False:
             ff = pybel._forcefields["uff"]
             if ff.Setup(mol.OBMol) is False:
                 exit("Cannot set up forcefield")

        print('WeightedRotorSearch -', i, 'start', '\n')

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
        dft_conf_routines.prepare_slurm_file(ginputname, memory, 
                 nproc, jobtime)

        # create directory "ginputname":
        current_directory = os.getcwd()
        final_directory = os.path.join(current_directory, ginputname)
        if not os.path.exists(final_directory):
                os.makedirs(final_directory)

        # move gaussian input file and slurm file there:
        os.rename(current_directory + "/" + ginputname + ".g16", 
                 final_directory + "/" + ginputname + ".g16")
        os.rename(current_directory + "/" + ginputname + ".slurm",
                 final_directory + "/" + ginputname + ".slurm")

        print('WeightedRotorSearch -', i, 'done', '\n')
      
def random_rotor_search_on_mol(first_i, last_i, main_input, main_ext, outputname, gaussinputname, job_type, method, other_keywords, charge, multiplicity, memory, nproc, jobtime):

    # Read the molecule from the supplied file:
    mol = next(pybel.readfile(main_ext[1:], main_input))
    print("Molecule read. Number of atoms: ", len(mol.atoms), '\n')

    for i in range(first_i, last_i):
   
        # Set up the force field / check if the force field can be set up 
        # successfully:
        ff = pybel._forcefields["mmff94"]
        if ff.Setup(mol.OBMol) is False:
             ff = pybel._forcefields["uff"]
             if ff.Setup(mol.OBMol) is False:
                 exit("Cannot set up forcefield")
  
        print('RandomRotorSearch -',i, 'start', '\n')

        # find some conformer:
        ff.SetCoordinates(mol.OBMol)
        ff.RandomRotorSearch(250,150)
        ff.GetCoordinates(mol.OBMol)
        E = ff.Energy(False)
     
        # write geometry to files:
        dft_conf_routines.writesxyz(mol, outputname, E, overwrite=False)
        ginputname = gaussinputname + '_' + str(i)
        dft_conf_routines.prepare_gauss_input(mol, ginputname, 
                 job_type, method, other_keywords, charge, 
                 multiplicity, memory, nproc)
        dft_conf_routines.prepare_slurm_file(ginputname, memory, 
                 nproc, jobtime)
      
        # create directory "ginputname":
        current_directory = os.getcwd()
        final_directory = os.path.join(current_directory, ginputname)
        if not os.path.exists(final_directory):
                os.makedirs(final_directory)
 
        # move gaussian input file and slurm file there:
        os.rename(current_directory + "/" + ginputname + ".g16", 
                 final_directory + "/" + ginputname + ".g16")
        os.rename(current_directory + "/" + ginputname + ".slurm",
                 final_directory + "/" + ginputname + ".slurm")
   
        print('RandomRotorSearch -', i, 'done', '\n')    

