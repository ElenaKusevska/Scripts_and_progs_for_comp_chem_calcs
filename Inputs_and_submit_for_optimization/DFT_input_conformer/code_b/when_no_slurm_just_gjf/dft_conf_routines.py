#!/usr/bin/python

import openbabel
import pybel
from pybel import ob
import os

def writesxyz(molecule, fname, energy, overwrite):
    
    fname = fname + '.xyz'

    # If overwriting, delete file if it already exists:
    if overwrite == True:
        if os.path.isfile('./' + fname):
            os.remove('./' + fname)
            print( fname + ' found and deleted', '\n' )

    # edit .xyz file:
    outputfile = open(fname, 'a')
    outputfile.write('{:d}'.format(len(molecule.atoms)))
    outputfile.write('\n')
    outputfile.write('{:.12f}'.format(energy)) #there was a string on energy
    outputfile.write('\n')
    for atom in molecule:
        outputfile.write('{:8} {:20.9f} {:20.9f} {:20.9f}'.format\
                ( str(ob.etab.GetSymbol(int(atom.atomicnum))), \
                atom.coords[0], atom.coords[1], atom.coords[2] ))
        outputfile.write('\n')
    outputfile.close()

def prepare_gauss_input(molecule, inputname, job_type, method, other_keywords, charge, multiplicity, memory, nproc):
    # create file name. Delete it if it exists.
    filename = inputname + '.gjf'
    if os.path.isfile('./' + filename):
        os.remove('./' + filename)
        print( filename, ' found and deleted' )

    # edit .gjf file:
    gaussfile = open(filename, 'w')
    gaussfile.write('%NProc=' + nproc)
    gaussfile.write('\n')
    gaussfile.write('%Mem=' + memory + 'GB')
    gaussfile.write('\n')
    gaussfile.write('%chk=' + inputname + '.chk')
    gaussfile.write('\n')
    gaussfile.write('#p' + ' ' + job_type + ' ' + method + ' ' + other_keywords)
    gaussfile.write('\n')
    gaussfile.write('\n')
    gaussfile.write('Title card required')
    gaussfile.write('\n')
    gaussfile.write('\n')
    gaussfile.write(charge + ' ' + multiplicity)
    gaussfile.write('\n')
    for atom in molecule:                
        gaussfile.write('{:8} {:20.9f} {:20.9f} {:20.9f}'.format\
                ( str(ob.etab.GetSymbol(int(atom.atomicnum))), \
                atom.coords[0], atom.coords[1], atom.coords[2] ))
        gaussfile.write('\n')
    gaussfile.write('\n')
    gaussfile.write('\n')
    gaussfile.close()

def prepare_slurm_file(inputname, memory, nproc, jobtime):
    # create file name. Delete it if it exists.
    filename = inputname + '.slurm'
    if os.path.isfile('./' + filename):
        os.remove('./' + filename)
        print( filename, ' found and deleted' )

    slurmfile = open(filename, 'w')
    slurmfile.write('#!/usr/bin/env bash')
    slurmfile.write('\n')
    slurmfile.write('#SBATCH --time=' + jobtime)
    slurmfile.write('\n')
    slurmfile.write('#SBATCH --nodes=1')
    slurmfile.write('\n')
    slurmfile.write('#SBATCH --ntasks=1')
    slurmfile.write('\n')
    slurmfile.write('#SBATCH --cpus-per-task=' + nproc)
    slurmfile.write('\n')
    slurmfile.write('#SBATCH --mem=' + memory + 'gb')
    slurmfile.write('\n')
    slurmfile.write('#SBATCH --job-name=' + inputname)
    slurmfile.write('\n')
    slurmfile.write('#SBATCH --output=' + inputname + '.out')
    slurmfile.write('\n')
    slurmfile.write('#SBATCH --partition=smp')
    slurmfile.write('\n')
    slurmfile.write(' ')
    slurmfile.write('\n')
    slurmfile.write('module purge')
    slurmfile.write('\n')
    slurmfile.write('module load gaussian/16-A.03')
    slurmfile.write('\n')
    slurmfile.write(' ')
    slurmfile.write('\n')
    slurmfile.write('cp ' + inputname + '.g16 $SLURM_SCRATCH')
    slurmfile.write('\n')
    slurmfile.write('cd $SLURM_SCRATCH')
    slurmfile.write('\n')
    slurmfile.write(' ')
    slurmfile.write('\n')
    slurmfile.write('ulimit -s unlimited')
    slurmfile.write('\n')
    slurmfile.write('export LC_COLLATE=C')
    slurmfile.write('\n')
    slurmfile.write(' ')
    slurmfile.write('\n')
    slurmfile.write('g16 < $SLURM_JOB_NAME.g16')
    slurmfile.write('\n')
    slurmfile.write('cp ' + inputname + '.chk $SLURM_SUBMIT_DIR')
    slurmfile.write('\n')
    slurmfile.write(' ')
    slurmfile.write('\n')
    #slurmfile.write('formchk ' + inputname + '.chk ' + inputname + '.fchk')
    #slurmfile.write('\n')
    #slurmfile.write('cp ' + inputname + '.fchk $SLURM_SUBMIT_DIR')
    #slurmfile.write('\n')
    slurmfile.write(' ')
    slurmfile.write('\n')

