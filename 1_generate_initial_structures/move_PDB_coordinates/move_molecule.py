import math
import os
import sys
import read_write_mod

#--------------------------------------------------------------
# Script to move the coordinates in a PDB file of a small
# molecule and print them to a new file. In the new file
# the atoms in the molecule are specified through the ATOM
# record, which is formatted according to the official
# standard of the protein data bank, regardless of whether
# in the original PDB they had been specified as ATOM or
# HETATM, and whether the file was formatted properly or not.
#--------------------------------------------------------------

if (len(sys.argv) < 2):
    print("No arguments provided")
    sys.exit()

dx = 0.0
dy = 0.0
dz = 0.0
infilename = " "
move_to_or_by = "to"
# Read the commandline arguments:
for i in range(0, len(sys.argv)):
    if (sys.argv[i] == "-i"):
        infilename = sys.argv[i+1]
    if (sys.argv[i] == "-m"):
        move_to_or_by = sys.argv[i+1] # possible values are "to" and "by"
    if (sys.argv[i] == "-x"):
        dx = float(sys.argv[i+1])
    if (sys.argv[i] == "-y"):
        dy = float(sys.argv[i+1])
    if (sys.argv[i] == "-z"):
        dz = float(sys.argv[i+1])

# Define the filenames
if (infilename == " "):
    print("No input file specified")
    sys.exit()
ext = infilename.split(".")[-1]
filename = ".".join(infilename.split(".")[:-1])
outfilename = (filename + "_moved_" + move_to_or_by + "_" + str(dx) +
        "_" + str(dy) + "_" + str(dz) + "." + ext)

# Get relevant information from the .pdb file
atom_name = []
residue_name = []
chain_ID = []
residue_number = []
x = []
y = []
z = []
segment_ID = []
atomic_symbol = []
occupancy = []
temperature_factor = []
atomic_charges = []
read_write_mod.get_info_from_pdb(infilename, atom_name,
        residue_name, chain_ID, residue_number, x, y, z, 
        segment_ID, atomic_symbol, occupancy, temperature_factor,
        atomic_charges)

# Move the coordinates:
if (move_to_or_by == "by"): # moving all coordinates by a user defined amount
    for i in range(0,len(x)):
        x[i] = x[i] + dx
        y[i] = y[i] + dy
        z[i] = z[i] + dz

elif (move_to_or_by == "to"): # moving center of mass to specified location
    # Find the unweighted center of mass:
    center = []
    for i in range(0,3):
        center.append(0.0)
    for i in range(0,len(x)):
        center[0] = center[0] + x[i]
        center[1] = center[1] + y[i]
        center[2] = center[2] + z[i]
    center[0] = center[0] / len(x)
    center[1] = center[1] / len(y)
    center[2] = center[2] / len(z)

    print("center", center)

    # move center of mass to (0,0,0):
    for i in range(0,len(x)):
        x[i] = x[i] - center[0]
        y[i] = y[i] - center[1]
        z[i] = z[i] - center[2]

else:
    print("you probably did not specify whether to move -by- or -to- properly")
    sys.exit()

# Print the moved coordinates to a PDB file:
read_write_mod.print_pdb_file(outfilename, atom_name,
       residue_name, chain_ID, residue_number, x, y, z, segment_ID,
       atomic_symbol, occupancy, temperature_factor, atomic_charges)



