import os

# Get the name of the .pdb file, the ranges of lengths for the
# bonds, and the values of the atomic charges, if provided:
def get_info_from_input(infilename, bond_info, charges):
   inputfile=open(infilename, "r")
   lines_in_inputfile = inputfile.readlines()

   # First, look for relevant keywords, and their location in the file:
   bond_info_line = 0
   atomic_charges_line = 0
   xyzfilename = ".xyz"
   for i in range(0,len(lines_in_inputfile)):
       words_in_line = lines_in_inputfile[i].split()
       # Get the name of the .pdb file:
       for j in range(0,len(words_in_line)):
           if ".xyz" in words_in_line[j]:
               xyzfilename = words_in_line[j]
       # Get the line where the information about
       # the bond lengths and bond orders starts:
       if "thresholdmin thresholdmax" in lines_in_inputfile[i]:
           bond_info_line = i + 1
       # Get the line where the atomic charges start:
       if "Charges:" in lines_in_inputfile[i]:
           if "---" in lines_in_inputfile[i+1]:
               atomic_charges_line = i + 2

   # If no filename for the .pdb file was provided:
   if (xyzfilename == ".xyz"):
       print("ERROR: No .pdb filename provided")
       exit()

   # Get the information about bond lengths and bond orders:
   if (bond_info_line == 0):
       print("ERROR: No information about bond lengths and bond orders")
       exit()
   else:
       i = 0
       words_in_line = lines_in_inputfile[i + bond_info_line].split()
       while (len(words_in_line) > 0):
           current_line = []
           for j in range(0, len(words_in_line)):
               current_line.append(words_in_line[j])
           bond_info.append(current_line)
           i = i + 1
           words_in_line = lines_in_inputfile[i + bond_info_line].split()

   # Check to make sure there are no duplicates in the bond info:
   for i in range(0, len(bond_info)):
       for j in range(i + 1, len(bond_info)):
           # if atom1[i]=atom1[j], atom2[i]=atom2[j], 
           #and the bond order is the same:
           if (bond_info[i][0] == bond_info[j][0]):
               if (bond_info[i][1] == bond_info[j][1]):
                   if (bond_info[i][4] == bond_info[j][4]):
                       print("ERROR: found duplicate bond info entries at lines", i+1, j+1)
                       exit()
           # if atom1[i]=atom2[j], atom2[i]=atom1[j], 
           #and the bond order is the same:
           if (bond_info[i][0] == bond_info[j][1]):
               if (bond_info[i][1] == bond_info[j][0]):
                   if (bond_info[i][4] == bond_info[j][4]):
                       print("ERROR: found duplicate bond info entries at lines", i+1, j+1)
                       exit()

   # Get the information about atomic charges:
   if (atomic_charges_line > 0):
       i = 0
       words_in_line = lines_in_inputfile[i + atomic_charges_line].split()
       while (len(words_in_line) > 0):
           current_line = []
           for j in range(0, len(words_in_line)):
               current_line.append(words_in_line[j])
           charges.append(current_line)
           i = i + 1
           words_in_line = lines_in_inputfile[i + atomic_charges_line].split()

   inputfile.close()

   # Define the name of the output file, and delete it if it exists
   # in the current directory
   outfilename = xyzfilename.split('.')[0] + ".output"
   if os.path.isfile("./" + outfilename):
       os.remove("./" + outfilename)
       print(outfilename + " found and deleted")

   # Write some information about get_info_from_input
   # to the output file:
   outfile = open(outfilename,'a')
   outfile.write("=======================================================")
   outfile.write('\n')
   outfile.write("Got the following information out of the input file:")
   outfile.write('\n')
   outfile.write("=======================================================")
   outfile.write('\n')
   outfile.write(".xyz filename: " + xyzfilename)
   outfile.write('\n')
   outfile.write("bond info starts on line (counting starts from 0): ")
   outfile.write(str(bond_info_line))
   outfile.write('\n')
   outfile.write("charge info starts on line (counting starts from 0): ")
   outfile.write(str(atomic_charges_line))
   outfile.write(str(atomic_charges_line))
   outfile.write('\n')
   outfile.write("---------------------------------------------------------")
   outfile.write('\n')
   outfile.write("bond info:" + '\n')
   for i in range (0, len(bond_info)):
       outfile.write(str(i) + " " + str(bond_info[i]) + '\n')
   outfile.write("atomic charges:" + '\n')
   if (atomic_charges_line > 0):
       for i in range(0, len(charges)):
           outfile.write(str(i) + " " + str(charges[i]) + '\n')
   else:
       outfile.write("No atomic charges provided" + '\n')
   outfile.write("----------------------------------------------------")
   outfile.write('\n')
   outfile.write('\n')
   outfile.write('\n')
   outfile.close()

   return [outfilename, xyzfilename]

# Get the information from the .xyz file:
def get_info_from_xyz(outfilename, xyzfilename,
        residue_name, chain_ID, residue_number, x, y, z,
        segment_ID, atomic_symbol, occupancy, temperature_factor, 
        atomic_charges):
    xyzinputfile=open(xyzfilename,"r")
    lines_in_xyzinputfile = xyzinputfile.readlines()

    # Get atom symbols and coordinates from the .xyz files
    # and assign residue information
    for i in range(2,int(lines_in_xyzinputfile[0])+2):
        words_in_line = lines_in_xyzinputfile[i].split()
        if (len(words_in_line) > 0):
            x.append(float(words_in_line[1]))
            y.append(float(words_in_line[2]))
            z.append(float(words_in_line[3]))
            residue_name.append("MOL")
            chain_ID.append("A")
            residue_number.append(1)
            segment_ID.append("MOLA")
            atomic_symbol.append(words_in_line[0])
            occupancy.append(0.00)
            temperature_factor.append(0.0)
            atomic_charges.append(0)
            # write to outfile instead of printing
            # print(x[i-2], y[i-2], z[i-2])

# Print the PDB file:
def print_pdb_file(outfilename, atom_name, residue_name, chain_ID,
        residue_number, x, y, z, segment_ID, atomic_symbol, occupancy,
        temperature_factor, atomic_charges, Segment_ID):

    # Delete PDB file if it exists in the directory
    if os.path.isfile("./" + outfilename):
        os.remove("./" + outfilename)
        print(outfilename + " found and deleted" )

    # Write the PDB file:
    pdboutfile = open(outfilename,'a')

    pdboutfile.write("REMARK PDB file generated from xyz file \n")

    # (The ATOM/HETATM record in a PDB file typically consists of columns:
    # Atom nr, Atom name, Residue name + chain ID, Residue nr, x, y, z,
    # occupancy, temperature factor, Segment_ID, Atomic symbol)

    # Find longest atom name:
    longest_atom_name = longest_string_in_list(atom_name)

    # (In the comments below, I am using character as synonymous with string,
    # as was done in the official document of the PDB standard)

    # Write the ATOM records:
    for i in range(0, len(atomic_symbol)):

        # Record name (1-6, character, left-justified)
        pdboutfile.write("ATOM  ")

        # Atom serial number (7-11, integer, right-justified)
        pdboutfile.write('{:>5}'.format(i+1))
        pdboutfile.write(" ")

        # Atom name (13-16, character, right justified to the length of
        # the longest atom name. The remaining fields are filled with spaces)
        pdboutfile.write('{:>{l}}'.format(atom_name[i], l=longest_atom_name))

        pdboutfile.write((4-longest_atom_name)*" ")

        # Alternate location indicator (17, not used in our case)
        pdboutfile.write(" ")

        # Residue name (18-20, character, right-justified)
        pdboutfile.write('{:>3}'.format(residue_name[i]))
        pdboutfile.write(" ")

        # Chain identifier (22, character)
        pdboutfile.write(chain_ID[i])

        # Residue sequence number (23-26, integer, right justified)
        pdboutfile.write('{:>4}'.format(residue_number[i]))

        # Code for insertion of residues (27, character, not used in our case)
        pdboutfile.write(" ")

        # 3 blank spaces
        pdboutfile.write(3*" ")
        # x-coordinate (31-38, Real(8.3))
        pdboutfile.write('{:>8.3f}'.format(x[i]))

        # y-coordinate (39-46, Real(8.3))
        pdboutfile.write('{:>8.3f}'.format(y[i]))

        # z-coordinate (47-54, Real(8.3)
        pdboutfile.write('{:>8.3f}'.format(z[i]))

        # Occupancy (55-60, Real(6.2))
        pdboutfile.write('{:>6.2f}'.format(occupancy[i]))

        # Temperature factor (61-66, Real(6.2))
        pdboutfile.write('{:>6.2f}'.format(temperature_factor[i]))

        # 68 - 76 should be blank spaces according to the official
        # standard formatting of the ATOM/HETATM records specified
        # by the Protein Data Bank standards of 1998 through 2012.
        # Some visualization programs however, also print a segment ID
        # on positions (73-76)
        pdboutfile.write(6*" ")
        pdboutfile.write(Segment_ID[i])
        pdboutfile.write((4-len(Segment_ID[i]))*" ")

        # Element symbol (77-78, character, right justified)
        pdboutfile.write('{:>2}'.format(atomic_symbol[i]))

        # Charge on the atom (79-80, character, right justified)
        pdboutfile.write('{:>2}'.format(atomic_charges[i]))

        # Finally, add new line character:
        pdboutfile.write('\n')

    pdboutfile.write("END")
    pdboutfile.close()

def longest_string_in_list(list_in):
    max_length = 0
    for i in range(0, len(list_in)):
        if (len(list_in[i]) > max_length):
            max_length = len(list_in[i])
    return max_length

def periodic_table(atomic_symbol):

    atomic_symbols = ['H', 'He', 'Li', 'Be', 'B', 'C', 'N', 'O', 'F',
            'Ne', 'Na', 'Mg', 'Al', 'Si', 'P', 'S', 'Cl', 'Ar', 'K', 'Ca',
            'Sc', 'Ti', 'V', 'Cr', 'Mn', 'Fe', 'Co', 'Ni', 'Cu', 'Zn',
            'Ga', 'Ge', 'As', 'Se', 'Br', 'Kr', 'Rb', 'Sr', 'Y', 'Zr',
            'Nb', 'Mo', 'Tc', 'Ru', 'Rh', 'Pd', 'Ag', 'Cd', 'In', 'Sn',
            'Sb', 'Te', 'I', 'Xe', 'Cs', 'Ba', 'La', 'Ce', 'Pr', 'Nd',
            'Pm', 'Sm', 'Eu', 'Gd', 'Tb', 'Dy', 'Ho', 'Er', 'Tm', 'Yb',
            'Lu', 'Hf', 'Ta', 'W', 'Re', 'Os', 'Ir', 'Pt', 'Au', 'Hg',
            'Tl', 'Pb', 'Bi', 'Po', 'At', 'Rn', 'Fr', 'Ra', 'Ac', 'Th',
            'Pa', 'U', 'Np', 'Pu', 'Am', 'Cm', 'Bk', 'Cf', 'Es', 'Fm',
            'Md', 'No', 'Lr', 'Rf', 'Db', 'Sg', 'Bh', 'Hs', 'Mt', 'Ds',
            'Rg', 'Cn', 'Uut', 'Fl', 'Uup', 'Lv', 'Uus', 'Uuo']


    atomic_masses = [1.008, 4.0026, 6.94, 9.0122, 10.81, 12.011, 14.007,
            15.999, 18.998, 20.180, 22.990, 24.305, 26.982, 28.085,
            30.974, 32.06, 35.45, 39.948, 39.098, 40.078, 44.956, 47.867,
            50.942, 51.996, 54.938, 55.845, 58.933, 58.693, 63.546, 65.38,
            69.723, 72.63, 74.922, 78.96, 79.904, 83.798, 85.468, 87.62,
            89.906, 91.224, 92.906, 95.96, 97.91, 101.07, 102.91, 106.42,
            107.87, 112.41, 114.82, 118.71, 121.76, 127.60, 126.90,
            131.29, 132.91, 137.33, 138.91, 140.12, 140.91, 144.24,
            144.91, 150.36, 151.96, 157.25, 158.93, 162.50, 164.93,
            167.26, 168.93, 173.05, 174.97, 178.49, 180.95, 183.84,
            186.21, 190.23, 192.22, 195.08, 196.97, 200.59, 204.38,
            207.2, 208.98, 208.98, 209.99, 222.02, 223.02, 226.03, 227.03,
            232.04, 231.04, 238.03, 237.05, 244.06, 243.06, 247.07,
            247.07, 251.08, 252.08, 257.10, 258.10, 259.10, 262.11,
            265.12, 268.13, 271.13, 270.0, 277.15, 276.15, 281.16, 280.16,
            285.17, 284.18, 289.19, 288.19, 293.0, 294.0, 294.0]

    atomic_mass = 0.0
    for i in range(0, len(atomic_symbols)):
        if (atomic_symbols[i] == atomic_symbol):
            atomic_mass = atomic_masses[i]

    return(atomic_mass)

def test_for_angle(atom1, atom2, atom3, bond1, bond2, angles, found_angle):
    if (bond1 > 0.0):
        if (bond2 > 0.0):
            angle = []
            angle.append(atom1)
            angle.append(atom2)
            angle.append(atom3)
            angles.append(angle)
            found_angle = True

def test_for_dihedral(atom1, atom2, atom3, atom4, bond1, bond2, bond3, dihedrals, found_dihedral):
    if (bond1 > 0.0):
        if (bond2 > 0.0):
            if (bond3 > 0.0):
                dihedral = []
                dihedral.append(atom1)
                dihedral.append(atom2)
                dihedral.append(atom3)
                dihedral.append(atom4)
                dihedrals.append(dihedral)
                found_dihedral = True


