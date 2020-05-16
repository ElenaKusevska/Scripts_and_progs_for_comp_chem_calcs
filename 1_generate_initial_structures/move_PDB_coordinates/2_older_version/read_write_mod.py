import os

# Get the information from a .pdb file:
def get_info_from_pdb(pdbfilename, read_pdb_format, atom_name, residue_name, 
        chain_ID, residue_number, x, y, z, segment_ID, atomic_symbol, 
        occupancy, temperature_factor, atomic_charges):
    
    pdbinputfile=open(pdbfilename,"r")
    lines_in_pdbinputfile = pdbinputfile.readlines()
   
    # Read the ATOM/HETATM records from the pdb file
    # The ATOM/HETATM record in a PDB file typically consists of columns:
    # Atom nr, Atom name, Residue name + chain ID, Residue nr, x, y, z,
    # occupancy, temperature factor, Segment_ID, Atomic symbol

    # Note that in python to iterate from for example, the first to the 
    # sixth element i.e. from element 0 to element 5 of a string, 
    # you should do string[0:6]

    if (read_pdb_format == "positional"):
        for i in range(0,len(lines_in_pdbinputfile)):

            # Record name (1-6, character, left-justified)
            lable = "".join(lines_in_pdbinputfile[i][0:6].split())
            print(lable)
            if (lable == "ATOM" or lable == "HETATM"):

                # Atom name (13-16, character, right justified to the length of
                # the longest atom name. The remaining fields are filled 
                # with spaces)
                s1 = "".join(lines_in_pdbinputfile[i][12:16].split())
                atom_name.append(s1)
            
                # Residue name (18-20, character, right-justified)
                s2 = "".join(lines_in_pdbinputfile[i][17:20].split())
                if (len(s2) == 0):
                    s2 = "MOL"
                residue_name.append(s2)
                
                # Chain identifier (22, character)
                s3 = lines_in_pdbinputfile[i][21]
                if (s3 == " "):
                    s3 = "A"
                chain_ID.append(s3)

                # Residue sequence number (23-26, integer, right justified)
                s4 = "".join(lines_in_pdbinputfile[i][22:26].split())
                if (len(s4) == 0):
                    s4 = "1"
                residue_number.append(int(s4))

                # x-coordinate (31-38, Real(8.3))
                x.append(float(lines_in_pdbinputfile[i][30:38]))

                # y-coordinate (39-46, Real(8.3))
                y.append(float(lines_in_pdbinputfile[i][38:46]))

                # z-coordinate (47-54, Real(8.3)
                z.append(float(lines_in_pdbinputfile[i][46:54]))

                # Occupancy (55-60, Real(6.2))
                s5 = "".join(lines_in_pdbinputfile[i][54:60].split())
                if (len(s5) == 0):
                    s6 = 0.00
                else:
                    s6 = float(s5)
                occupancy.append(s6)

                # Temperature factor (61-66, Real(6.2))
                s7 = "".join(lines_in_pdbinputfile[i][60:66].split())
                if (len(s7) == 0):
                    s8 = 0.0
                else:
                    s8 = float(s7)
                temperature_factor.append(s8)

                # 68 - 77 should be blank spaces according to the official
                # standard formatting of the ATOM/HETATM records specified
                # by the Protein Data Bank standards of 1998 through 2012.
                # Some visualization programs however, also print a segment ID
                # on positions (73-76)
                s9 = " ".join(lines_in_pdbinputfile[i][72:76].split())
                if (len(s9) == 0):
                    s9 = s2 + s3
                segment_ID.append(s9)

                # Element symbol (77-78, character, right justified)
                s10 = " ".join(lines_in_pdbinputfile[i][76:78].split())
                if (len(s10) == 0):
                    s10 = s1
                atomic_symbol.append(s10)

                # Charge on the atom (79-80, character, right justified)
                s11 = " ".join(lines_in_pdbinputfile[i][78:80].split())
                if (len(s11) == 0):
                    s11 = "0"
                atomic_charges.append(int(s11))

                print(s1, s2, s3, s4, x[-1], y[-1], z[-1], s6, s8, s9, s10, s11)

    elif (read_pdb_format == "columnwise"):
        for i in range(0,len(lines_in_pdbinputfile)):
            words_in_line = lines_in_pdbinputfile[i].split()
            if (len(words_in_line) > 0):
                # PDB type :
                if (words_in_line[0] == "ATOM"):
                    # PDB type 1 and vmd small molecule PDB:
                    if (words_in_line[4].isdigit() or 
                            words_in_line[4].lstrip('-').isdigit()):
                        if (len(words_in_lin[3]) > 1):
                            print("PDB type 1")
                            atom_name.append(words_in_line[2])
                            residue_name.append(words_in_line[3][:-1])
                            chain_ID.append(words_in_line[3][-1:])
                            residue_number.append(words_in_line[4])
                            x.append(float(words_in_line[5]))
                            x.append(float(words_in_line[6]))
                            z.append(float(words_in_line[7]))
                            segment_ID.append(words_in_line[10])
                            atomic_symbol.append(words_in_line[11])
                        else:
                            print("PDB type vmd small molecule PDB")
                            atom_name.append(words_in_line[2])
                            residue_name.append("MOL")
                            chain_ID.append(words_in_line[3][-1:])
                            residue_number.append(words_in_line[4])
                            x.append(float(words_in_line[5]))
                            x.append(float(words_in_line[6]))
                            z.append(float(words_in_line[7]))
                            segment_ID.append("MOL")
                            atomic_symbol.append(words_in_line[10])
                    # PDB type 2:
                    else:
                        print("PDB type 2")
                        atom_name.append(words_in_line[2])
                        residue_name.append(words_in_line[3])
                        chain_ID.append(words_in_line[4])
                        residue_number.append(words_in_line[5])
                        xyz.append(float(words_in_line[6]))
                        xyz.append(float(words_in_line[7]))
                        xyz.append(float(words_in_line[8]))
                        coords.append(xyz)
                        segment_ID.append(words_in_line[11])
                        atomic_symbol.append(words_in_line[12])
                # PDB type molden and gaussview:
                elif (words_in_line[0] == "HETATM"):
                    # PDB type molden:
                    if (words_in_line[4].isdigit() or
                            words_in_line[4].lstrip('-').isdigit()):
                        print("PDB type molden")
                        atom_name.append(words_in_line[2])
                        residue_name.append("MOL")
                        chain_ID.append(words_in_line[3][-1:])
                        residue_number.append(words_in_line[4])
                        x.append(float(words_in_line[5]))
                        y.append(float(words_in_line[6]))
                        z.append(float(words_in_line[7]))
                        segment_ID.append("MOL")
                        atomic_symbol.append(words_in_line[2])
                    # PDB type gaussview
                    elif (words_in_line[4].replace('.','',1).lstrip('-').isdigit()):
                        print("PDB type gaussview")
                        atom_name.append(words_in_line[2])
                        residue_name.append("MOL")
                        chain_ID.append("X")
                        residue_number.append(words_in_line[3])
                        x.append(float(words_in_line[4]))
                        y.append(float(words_in_line[5]))
                        z.append(float(words_in_line[6]))
                        segment_ID.append("MOL")
                        atomic_symbol.append(words_in_line[7])
    pdbinputfile.close()

def print_pdb_file(outfilename, atom_name, residue_name, chain_ID, 
        residue_number, x, y, z, segment_ID, atomic_symbol, occupancy,
        temperature_factor, atomic_charges):

    # Delete PDB file if it exists in the directory
    if os.path.isfile("./" + outfilename):
        os.remove("./" + outfilename)
        print(outfilename + " found and deleted" )
    
    # Write the PDB file:
    pdboutfile = open(outfilename,'a')

    pdboutfile.write("REMARK PDB file generated from DFT optimized geometry \n")

    # (The ATOM/HETATM record in a PDB file typically consists of columns:
    # Atom nr, Atom name, Residue name + chain ID, Residue nr, x, y, z,
    # occupancy, temperature factor, Segment_ID, Atomic symbol)

    # Find longest atom name:
    # (In the comments below, I am using character as synonymous with string,
    # as was done in the official document of the PDB standard)
    longest_atom_name = longest_string_in_list(atom_name)

    # Write the ATOM records:
    for i in range(0, len(atom_name)):

        # Record name (1-6, character, left-justified)
        pdboutfile.write("ATOM  ")
        
        # Atom serial number (7-11, integer, right-justified)
        pdboutfile.write('{:>5}'.format(i+1))
        pdboutfile.write(" ")

        # Atom name (13-16, character, right justified to the length of
        # the longest atom name. The remaining fields are filled with spaces)
        #l = longest_atom_name
        #pos = f"{:>{longest_atom_name}}"
        #print('\n{:^{}}'.format('some text here', display_width))
        #pdboutfile.write("{atomname:<{pos}}".format(atomname=atom_name[i], pos=longest_atom_name))
        #pos = '{:>' + str(longest_atom_name) + '}'
        #pdboutfile.write(pos.format(atom_name[i]))
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
        pdboutfile.write(10*" ")

        # Element symbol (77-78, character, right justified)
        pdboutfile.write('{:>2}'.format(atomic_symbol[i]))

        # Charge on the atom (79-80, character, right justified)
        pdboutfile.write('{:>2}'.format(atomic_charges[i]))

        # Finally, add new line character:
        pdboutfile.write('\n')

    pdboutfile.close()

def longest_string_in_list(list_in):
    max_length = 0
    for i in range(0, len(list_in)):
        if (len(list_in[i]) > max_length):
            max_length = len(list_in[i])
    return max_length
