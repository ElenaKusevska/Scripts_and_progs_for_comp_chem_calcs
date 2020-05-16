import math
import os
import sys
import read_write_mod

#----------------------------------------------------------------
# Script to move the coordinates in molecular geometries and
# print them to a new file
#----------------------------------------------------------------

if (len(sys.argv) < 2):
    print("No arguments provided")
    sys.exit()

dx = 0.0
dy = 0.0
dz = 0.0
read_format = " "
infilename = " "
move_to_or_by = "to"
# Read the commandline arguments:
for i in range(0, len(sys.argv)):
    if (sys.argv[i] == "-i"):
        infilename = sys.argv[i+1]
    if (sys.argv[i] == "--read_by"):
        read_format = sys.argv[i+1] # possible values are "positional" and
                                    # "columnwise". Overrides the default for
                                    # the file type of the input file
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
ext = infilename.split(".")[1]
filename = infilename.split(".")[0]
outfilename = filename + "_moved." + ext

# If the input file is a PDB file:
if (ext == "pdb"):
    # Get relevant information from the .pdb file
    read_pdb_format = "positional"
    if (read_format == "columnwise"):
        read_pdb_format = read_format
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
    read_write_mod.get_info_from_pdb(infilename, read_pdb_format, 
            atom_name, residue_name, chain_ID, residue_number, x, y, z, 
            segment_ID, atomic_symbol, occupancy, temperature_factor,
            atomic_charges)

# Move the coordinates:
if (move_to_or_by == "by"): # moving all coordinates by a user defined amount
    for i in range(0,len(x)):
        x[i] = x[i] + dx
        y[i] = y[i] + dy
        z[i] = z[i] + dz

# Print the moved coordinates to an output file:
if (ext == "pdb"): # If printing a PDB file
    read_write_mod.print_pdb_file(outfilename, atom_name,
           residue_name, chain_ID, residue_number, x, y, z, segment_ID,
           atomic_symbol, occupancy, temperature_factor, atomic_charges)



