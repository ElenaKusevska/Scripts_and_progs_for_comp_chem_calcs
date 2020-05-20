import math
import os
import sys
import mod

#--------------------------------------------------
# Script to write the .psf and .pdb file from a 
# given .xyz file
#--------------------------------------------------

# Define the name of the input file:
infilename = "input"
if (len(sys.argv) > 1):
    for i in range(0, len(sys.argv)):
        if (sys.argv[i] == "-i"):
            infilename = sys.argv[i+1]

# Get the name of the .pdb file, the ranges of lengths for the
# bonds, and the values of the atomic charges, if provided:
bond_info = []
input_charges = []
files = mod.get_info_from_input(infilename,
        bond_info, input_charges)
outfilename = files[0]
xyzfilename = files[1]
pdbfilename = xyzfilename.split('.')[0] + ".pdb"
psffilename = xyzfilename.split('.')[0] + ".psf"

# Delete .psf file if it exists in the directory
if os.path.isfile("./" + psffilename):
    os.remove("./" + psffilename)
    print(psffilename + " found and deleted" )

# Get relevant information from the .xyz file:
# (The ATOM section in a PDB file typically consists of columns
# Atom nr, Atom name, Residue name + chain ID, Residue nr, x, y, z, 
# occupancy, temperature factor, Segment_ID, Atomic symbol)
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
atomic_charge = [] # for PDB
mod.get_info_from_xyz(outfilename, xyzfilename,
        residue_name, chain_ID, residue_number, x, y, z, segment_ID,
        atomic_symbol, occupancy, temperature_factor, atomic_charge)

# Determine atom_name:
# Count the number of atoms of each type and lable them:
atom_types_in_molecule = [] # eg: [ [W, 1], [C, 4], [O, 4] ]
atom_name = []
for i in range(0, len(atomic_symbol)):
    duplicate = "no"
    for j in range(0, len(atom_types_in_molecule)):
        if (atomic_symbol[i] == atom_types_in_molecule[j][0]):
            atom_types_in_molecule[j][1] = atom_types_in_molecule[j][1] + 1
            atom_name.append(atomic_symbol[i] + str(atom_types_in_molecule[j][1]))
            duplicate = "yes"
    if (duplicate == "no"):
        new_type = []
        new_type.append(atomic_symbol[i])
        new_type.append(1)
        atom_types_in_molecule.append(new_type)
        atom_name.append(atomic_symbol[i] + "1")

# Print the PDB file:
mod.print_pdb_file(pdbfilename, atom_name, residue_name, chain_ID,
        residue_number, x, y, z, segment_ID, atomic_symbol, occupancy,
        temperature_factor, atomic_charge, segment_ID)

# Assign atomic charges:
atomic_charges = []
for i in range(0, len(atomic_symbol)):
    atomic_charges.append(0.0)
    if (len(input_charges) > 0):
        for j in range (0, len(input_charges)):
            if (input_charges[j][0] == str(i+1)):
                atomic_charges[i] = float(input_charges[j][1])

# Assign atomic masses:
atom_mass = []
for i in range(0, len(atomic_symbol)):
    atom_mass.append(mod.periodic_table(atomic_symbol[i]))

# Write some information to the output file:
outfile = open(outfilename, 'a')
outfile.write("======================================================\n")
outfile.write("Atomic charges:" + "\n")
outfile.write("======================================================\n")
for i in range(0, len(atomic_symbol)):
    outfile.write(str(i) + " " + str(atomic_symbol[i]) + " ")
    outfile.write(str(atom_name[i]) + " " + str(i+1) + " ")
    outfile.write(str(atomic_charges[i]) + "\n")
outfile.write("-----------------------------------------------------")
outfile.write("\n")
outfile.write("\n")

#--------------------------------------------------------------------
# Now, we start writing to the PSF file, according to the 
# following formatting requirements:
#--------------------------------------------------------------------
# The information on the formatting of PSF files is taken from the webpage 
# https://fossies.org/diffs/pymol/v1.8.4.0_vs_v1.8.6.0/contrib/uiuc/plugins/molfile_plugin/src/psfplugin.c-diff.html),
# which contains the source code of the pymol psf plugin
#
# Here, the format of the atoms section in a CHARMM PSF file 
# is specified in FORTRAN format as:
# '(I8,1X,A4,1X,A4,1X,A4,1X,A4,1X,A4,1X,G14.6,G14.4,I8)'
# And the formats of the lists of bonds, angles, and dihedrals
# are specified as '(8I8)', '(9I8), and '(8I8)', respectively.
#
# CHARMM PSF EXT format is defined as:
# '(I10,1X,A8,1X,A8,1X,A8,1X,A8,1X,A4,1X,G14.6,G14.4,I8)'
# And the formats of the lists of bonds, angles, and dihedrals
# are specified as '(8I10)', '(9I10), and '(8I10)', respectively.
#
# Note that in FORTRAN format I and G are right justified,
# and A is left justified. Also, I made some corrections to the formats
# above compared to what was written on the website, because I found
# some obvious typos.
#
# The atoms section of a PSF file consists of the following columns:
# Atom nr, Segment ID, Residue nr, Residue name, Atom name, Atomic symbol
# Charge,  Atomic mass, unused 0
#-----------------------------------------------------------------

#IMPORTANT: res_name_chain_ID is actually Segment ID, which
# is already defined beforehabd (when reading from xyz) as
# consisting of 4 characters. Therefore, it is
# not likely that an extended PSF file would be printed.
# It's OK to leave it though, 
# In case the user changed the code to read xyz to make the segment
# ID longer. But still, at least this part of the code here
# should be cleaned up. For example there is no need to have res_name_chain_ID 
# as a separate variable.

res_name_chain_ID = []
for i in range (0, len(residue_name)):
    res_name_chain_ID.append(residue_name[i] + chain_ID[i])
max_len_res_name_chain_ID = mod.longest_string_in_list(res_name_chain_ID)
if (max_len_res_name_chain_ID <= 4):
    psffile = "PSF" # We will write a CHARMM PSF file
    npos1 = '{:>8}' # number of positions in titles of sections
                    # and in lists of bonds, angles, and dihedrals
                    # (riht justified)
    npos2 = 5 # number of positions in atom specifications
    print("Longest (Residue name + Chain ID) is " +
            str(max_len_res_name_chain_ID) +
            ". Will print a PSF file")
elif ((max_len_res_name_chain_ID <= 8) and (max_len_res_name_chain_ID >= 5)):
    psffile = "PSF EXT" # We will write an extended CHARMM PSF file
    npos1 = '{:>10}'
    npos2 = 9
    print("Longest (Residue name + Chain ID) is " +
            str(max_len_res_name_chain_ID) +
            ". Will print an extended PSF file")
else:
    print("ERROR: Residue name is too long")
    exit()
psfoutfile = open(psffilename, 'a')
psfoutfile.write(psffile + "\n")
psfoutfile.write("\n")

psfoutfile.write(npos1.format("1"))
psfoutfile.write(" !NTITLE\n")
psfoutfile.write(npos1.format("REMARKS"))
psfoutfile.write(" " + psffile + " file generated from " +
        xyzfilename + " \n")
psfoutfile.write("\n")
psfoutfile.write(npos1.format(str(len(atomic_symbol))))
psfoutfile.write(" !NATOM\n")
for i in range(0, len(atomic_symbol)):
    psfoutfile.write(npos1.format(i+1) + " ")
    psfoutfile.write(segment_ID[i] + (npos2-len(segment_ID[i]))*" ")
    psfoutfile.write(str(residue_number[i]) +
            (npos2-len(str(residue_number[i])))*" ")
    psfoutfile.write(str(residue_name[i]) +
            (npos2-len(residue_name[i]))*" ")
    psfoutfile.write(atom_name[i] + (npos2-len(atom_name[i]))*" ")
    psfoutfile.write(atomic_symbol[i] + (5-len(atomic_symbol[i]))*" ")
    psfoutfile.write('{:>14.6f}'.format(atomic_charges[i]))
    psfoutfile.write('{:>14.4f}'.format(atom_mass[i]))
    psfoutfile.write('{:>9}'.format("0") + "\n")

#------------------------------------------------
# Construct the connectivity matrix and
# list of bonds:
#------------------------------------------------

# first set all elements to zero:
connectivity_matrix = []
for i in range(0,len(atomic_symbol)):
    ith_row = []
    for j in range(0,len(atomic_symbol)):
        ith_row.append(0.0)
    connectivity_matrix.append(ith_row)

# Find the nonzero elements in the connectivity matrix, and construct
# the aray that holds information about bonds in the molecule:
bonds = []
for i in range(0,len(atomic_symbol)):
    for j in range(i+1,len(atomic_symbol)):
        i_j_bonds_found = 0
        found_atomic_symbols_in_bond_info = "n"
        for p in range(0,len(bond_info)):
            if (atomic_symbol[i] == bond_info[p][0]) and (atomic_symbol[j] == bond_info[p][1]):
                found_atomic_symbols_in_bond_info = "y"
                l = math.sqrt( (x[i]-x[j])**2 +
                               (y[i]-y[j])**2 +
                               (z[i]-z[j])**2 )
                if (l <= float(bond_info[p][3])):
                    if (l >= float(bond_info[p][2])):
                        connectivity_matrix[i][j] = float(bond_info[p][4])
                        connectivity_matrix[j][i] = float(bond_info[p][4])
                        bond = []
                        bond.append(i+1)
                        bond.append(j+1)
                        bonds.append(bond)
                        i_j_bonds_found = i_j_bonds_found + 1
            elif (atomic_symbol[j] == bond_info[p][0]) and (atomic_symbol[i] == bond_info[p][1]):
                found_atomic_symbols_in_bond_info = "y"
                l = math.sqrt( (x[i]-x[j])**2 +
                               (y[i]-y[j])**2 +
                               (z[i]-z[j])**2 )
                if (l <= float(bond_info[p][3])):
                    if (l >= float(bond_info[p][2])):
                        connectivity_matrix[i][j] = float(bond_info[p][4])
                        connectivity_matrix[j][i] = float(bond_info[p][4])
                        bond = []
                        bond.append(i+1)
                        bond.append(j+1)
                        bonds.append(bond)
                        i_j_bonds_found = i_j_bonds_found + 1
        if (found_atomic_symbols_in_bond_info == "n"):
            print("ERROR: Bond info for " + atomic_symbol[i] +
                    "-" + atomic_symbol[j] + " is not given in " +
                    "the input. Can't check for bonds")
            exit()
        if (i_j_bonds_found > 1):
            print("ERROR: Based on your bond info, it is possible" +
                    " to define more than one bond between atoms " +
                    atomic_symbol[i] + " and " + atomic_symbol[j])
            exit()

outfile.write("connectivity_matrix" + '\n')
outfile.write("-------------------------------------------" + '\n')
for i in range(0,len(connectivity_matrix)):
    outfile.write(str(connectivity_matrix[i]) + '\n')
outfile.write('\n')
outfile.write('\n')

psfoutfile.write('\n')
psfoutfile.write(npos1.format(len(bonds)) + " !NBOND: bonds" + '\n')
for i in range (0, len(bonds)):
    psfoutfile.write(npos1.format(bonds[i][0]))
    psfoutfile.write(npos1.format(bonds[i][1]))
    if ( (i+1)%4 == 0 ):
        psfoutfile.write('\n') # new line every four bonds
if (len(bonds)%4 != 0):
    psfoutfile.write('\n')

#------------------------------------------------------
# Find all the angles and dihedrals in the molecule:
#------------------------------------------------------

# Angles: There are only three ways that there can be
# an angle between atom i, j, and k. If i is the
# central atom (i-j and i-k bonds exist),
# if j is the central atom (j-i and j-k bonds exist),
# and if k is the central atom (k-i and k-j bonds exist)
angles = []
for i in range(0, len(atomic_symbol)):
        for j in range(i+1, len(atomic_symbol)):
            for k in range(j+1, len(atomic_symbol)):
                found_angle = False
                mod.test_for_angle(j+1, i+1, k+1,
                        connectivity_matrix[j][i],
                        connectivity_matrix[i][k],
                        angles, found_angle)
                if found_angle:
                    continue
                mod.test_for_angle(i+1, j+1, k+1,
                        connectivity_matrix[i][j],
                        connectivity_matrix[j][k],
                        angles, found_angle)
                if found_angle:
                    continue
                mod.test_for_angle(i+1, k+1, j+1,
                        connectivity_matrix[i][k],
                        connectivity_matrix[k][j],
                        angles, found_angle)

psfoutfile.write('\n')
psfoutfile.write(npos1.format(len(angles)) + " !NTHETA: angles" + '\n')
for i in range (0, len(angles)):
    psfoutfile.write(npos1.format(angles[i][0]))
    psfoutfile.write(npos1.format(angles[i][1]))
    psfoutfile.write(npos1.format(angles[i][2]))
    if ( (i+1)%3 == 0 ):
        psfoutfile.write('\n') # new line every three angles
if (len(angles)%3 != 0):
    psfoutfile.write('\n')

# Dihedrals: There are 12 ways that there can be a dihedral between
# four atoms, i, j, p, and q. Setting the central bond between two
# of the central atoms, the following combinations are possible:
# p-i-j-q   j-i-p-q   p-i-q-j   q-j-p-i   i-j-q-p   i-p-q-j
# q-i-j-p   q-i-p-j   j-i-q-p   i-j-p-q   p-j-q-i   j-p-q-i
dihedrals = []
for i in range(0, len(atomic_symbol)):
    for j in range(i+1, len(atomic_symbol)):
        for p in range(j+1, len(atomic_symbol)):
            for q in range(p+1, len(atomic_symbol)):
                found_dihedral = False
                mod.test_for_dihedral(p+1, i+1, j+1, q+1,
                        connectivity_matrix[p][i],
                        connectivity_matrix[i][j],
                        connectivity_matrix[j][q],
                        dihedrals, found_dihedral)
                if (found_dihedral):
                    continue
                mod.test_for_dihedral(q+1, i+1, j+1, p+1,
                        connectivity_matrix[q][i],
                        connectivity_matrix[i][j],
                        connectivity_matrix[j][p],
                        dihedrals, found_dihedral)
                if (found_dihedral):
                    continue
                mod.test_for_dihedral(j+1, i+1, p+1, q+1,
                        connectivity_matrix[j][i],
                        connectivity_matrix[i][p],
                        connectivity_matrix[p][q],
                        dihedrals, found_dihedral)
                if (found_dihedral):
                    continue
                mod.test_for_dihedral(q+1, i+1, p+1, j+1,
                        connectivity_matrix[q][i],
                        connectivity_matrix[i][p],
                        connectivity_matrix[p][j],
                        dihedrals, found_dihedral)
                if (found_dihedral):
                    continue
                mod.test_for_dihedral(p+1, i+1, q+1, j+1,
                        connectivity_matrix[p][i],
                        connectivity_matrix[i][q],
                        connectivity_matrix[q][j],
                        dihedrals, found_dihedral)
                if (found_dihedral):
                    continue
                mod.test_for_dihedral(j+1, i+1, q+1, p+1,
                        connectivity_matrix[j][i],
                        connectivity_matrix[i][q],
                        connectivity_matrix[q][p],
                        dihedrals, found_dihedral)
                if (found_dihedral):
                    continue
                mod.test_for_dihedral(q+1, j+1, p+1, i+1,
                        connectivity_matrix[q][j],
                        connectivity_matrix[j][p],
                        connectivity_matrix[p][i],
                        dihedrals, found_dihedral)
                if (found_dihedral):
                    continue
                mod.test_for_dihedral(i+1, j+1, p+1, q+1,
                        connectivity_matrix[i][j],
                        connectivity_matrix[j][p],
                        connectivity_matrix[p][q],
                        dihedrals, found_dihedral)
                if (found_dihedral):
                    continue
                mod.test_for_dihedral(i+1, j+1, q+1, p+1,
                        connectivity_matrix[i][j],
                        connectivity_matrix[j][q],
                        connectivity_matrix[q][p],
                        dihedrals, found_dihedral)
                if (found_dihedral):
                    continue
                mod.test_for_dihedral(p+1, j+1, q+1, i+1,
                        connectivity_matrix[p][j],
                        connectivity_matrix[j][q],
                        connectivity_matrix[q][i],
                        dihedrals, found_dihedral)
                if (found_dihedral):
                    continue
                mod.test_for_dihedral(i+1, p+1, q+1, j+1,
                        connectivity_matrix[i][p],
                        connectivity_matrix[p][q],
                        connectivity_matrix[q][j],
                        dihedrals, found_dihedral)
                if (found_dihedral):
                    continue
                mod.test_for_dihedral(j+1, p+1, q+1, i+1,
                        connectivity_matrix[j][p],
                        connectivity_matrix[p][q],
                        connectivity_matrix[q][i],
                        dihedrals, found_dihedral)
                if (found_dihedral):
                    continue

psfoutfile.write('\n')
psfoutfile.write(npos1.format(len(dihedrals)))
psfoutfile.write(" !NPHI: dihedrals" + '\n')
for i in range (0, len(dihedrals)):
    psfoutfile.write(npos1.format(dihedrals[i][0]))
    psfoutfile.write(npos1.format(dihedrals[i][1]))
    psfoutfile.write(npos1.format(dihedrals[i][2]))
    psfoutfile.write(npos1.format(dihedrals[i][3]))
    if ( (i+1)%2 == 0 ):
        psfoutfile.write('\n') # new line every two dihedrals
if (len(dihedrals)%2 != 0):
    psfoutfile.write('\n')
psfoutfile.write('\n')

outfile.close()
psfoutfile.close()

