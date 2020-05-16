#include "module.h"
#include <string>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <cmath>
#include <vector>

//-------------------------------------------------------------
// Program to generate an alpha-quartz SiO2 lattice with
// given lengths in the Cartesian x-, y-, and z- directions.
// The basis atoms are originally given in cartesian coordinates.
// The translations are performed in the hexagonal coordinate
// system. The lattice is centerd at (0,0,0) in Cartesian
// cordinates. The program outputs the generated coordinates
// in a .xyz file for visualization and a .in file, to be
// used as input for MBNexplorer calculation, expressed
// in Cartesian coordinates.
//
// The program also constructs a hydrogenated alpha-quartz
// SiO2 lattice.
//-------------------------------------------------------------

int main() {

   // Define the desired lengths in each direction here:
   double d1 = 23.5; // lenght in x-direction
   double d2 = 16.0; // length in y-direction
   double d3 = 16.0;  // length in z-direction

   // Define lattice constants of graphite here:
   std::vector<double> a = { 4.91, 4.91, 5.402 };
   
   int i, j, k, ipm, jpm, kpm, atom, returns, natoms;
   double dist, sum;
   double Si_H_bond = 1.6; // angstrom
   double O_H_bond = 1.2; // angstrom
   int n1, n2, n3; // number of times to translate in each direction.
                   // Will translate that many times in both the plus
                   // and minus direction.
   std::vector<double> pm = { 1.0, -1.0 }; // plus or minus

   std::vector<double> center; // center of mass
   std::vector<double> e1, e2, e3; // unit vectors of basis
   std::vector<std::vector<double>> Pe; // transformation matrix for 
                                        // change of basis to cartesian 
                                        // coordinates
   std::vector<std::vector<double>> Peinv;
   std::vector<std::vector<double>> final_coordinates;
   std::vector<double> atom_coordinates, new_H_coordinates;
   std::vector<double> v1, v2;
   std::vector<std::vector<double>> basis_atoms;
   std::vector<std::vector<double>> unit_cell;
   std::vector<double> final_structure;
   std::vector<std::string> xyz_file_lables;
   std::vector<std::string> in_file_lables;
   std::vector<std::vector<double>> connectivity_matrix;

   //------------------------------------------------------
   // Define the atoms of the basis, and redefine them
   // so that the unit cell is centered at
   // (0,0,0) of the Cartesian coordinate system
   //------------------------------------------------------

   // Independent (basis) points in graphite in Cartesian coordinates:
   basis_atoms.resize(9);
   for (i=0; i<basis_atoms.size(); i=i+1) {
      basis_atoms[i].resize(3);
   }

   // Point 1:   Si       -0.082  -0.048  -2.701
   basis_atoms[0][0] = -0.082;
   basis_atoms[0][1] = -0.048;
   basis_atoms[0][2] = -2.701;

   // Point 2:   Si        0.082  -2.503   0.900
   basis_atoms[1][0] = 0.082;
   basis_atoms[1][1] = -2.503;
   basis_atoms[1][2] = 0.900;

   // Point 3:   Si       -2.126   1.322  -0.900
   basis_atoms[2][0] = -2.126;
   basis_atoms[2][1] = 1.322;
   basis_atoms[2][2] = -0.900;

   // Point 4:   O        -1.487   0.440  -2.072
   basis_atoms[3][0] = -1.487;
   basis_atoms[3][1] = 0.440;
   basis_atoms[3][2] = -2.072;

   // Point 5:   O         0.363   0.947   1.530
   basis_atoms[4][0] = 0.363;
   basis_atoms[4][1] = 0.947;
   basis_atoms[4][2] = 1.530;

   // Point 6:   O        -1.002   2.296  -0.271
   basis_atoms[5][0] = -1.002;
   basis_atoms[5][1] = 2.296;
   basis_atoms[5][2] = -0.271;

   // Point 7:   O        -0.363  -1.507   2.072
   basis_atoms[6][0] = -0.363;
   basis_atoms[6][1] = -1.507;
   basis_atoms[6][2] = 2.072;

   // Point 8:   O         1.002  -0.160  -1.530
   basis_atoms[7][0] = 1.002;
   basis_atoms[7][1] = -0.160;
   basis_atoms[7][2] = -1.530;

   // Point 9:   O         1.488  -2.016   0.271
   basis_atoms[8][0] = 1.488;
   basis_atoms[8][1] = -2.016;
   basis_atoms[8][2] = 0.271;

   // Define hexagonal/cartesian transformations:
   e1 = {4.2522/4.91,   -2.455/4.91,    0.0};
   e2 = {0.0, 1.0, 0.0};
   e3 = {0.0, 0.0, 1.0};

   // Hexagonal -> cartesian transformation matrix:
   Pe.resize(3);
   Pe[0].resize(3);
   Pe[1].resize(3);
   Pe[2].resize(3);
   for (i=0; i<3; i=i+1) {
      Pe[0][i] = e1[i];
      Pe[1][i] = e2[i];
      Pe[2][i] = e3[i];
   }

   // Cartesian -> hexagonal transformation matrix:
   Peinv.resize(3);
   Peinv[0].resize(3);
   Peinv[1].resize(3);
   Peinv[2].resize(3);
   returns = inverse_3_3(Pe,Peinv);
   if (returns != 0) {
      return(0);
   }

   // Find center of mass of basis atoms:
   center.resize(3);
   for (i=0; i<3; i=i+1) {
      center[i] = 0.0;
      for (j=0; j<basis_atoms.size(); j=j+1) {
         center[i] = center[i] + basis_atoms[j][i];
      }
      center[i] = center[i] / basis_atoms.size();
   }
   std::cout << "center: ";
   print_vector_double(center);
   for (i=0; i<unit_cell.size(); i=i+1) {
      for (j=0; j<unit_cell[i].size(); j=j+1) {
         basis_atoms[i][j] = basis_atoms[i][j] - center[j];
      }
   }

   // Convert unit cell to hexagonal coordinates
   returns = matmatmul(basis_atoms, Peinv, 1);
   if (returns != 0) {
      return(0);
   }

   //---------------------------------------------------
   // Determine and write the final coordinates:
   //---------------------------------------------------

   // Determine how many times you want to translate in each direction:
   // (some large enough number of times)
   n1 = int( (d1/a[0])/2.0 + 3.0 );
   n2 = int( (d2/a[1])/2.0 + 3.0 );
   n3 = int( (d3/a[2])/2.0 + 3.0 );

   final_coordinates.resize(0);
   xyz_file_lables.resize(0);
   in_file_lables.resize(0);
   // For the number of times the unit cell has to be repliicated
   // in the 1-direction
   for (i=0; i<=n1; i=i+1) {
      // For the number of times the unit cell has to be repliicated
      // in the 2-direction
      for (j=0; j<=n2; j=j+1) {
         // For the number of times the unit cell has to be repliicated
         // in the 3-direction
         for (k=0; k<=n3; k=k+1) {
            // for the plus and minus in the 1-direction
            for (ipm=0; ipm<=1; ipm=ipm+1) {
               // for the plus and minus in the 2-direction
               for (jpm=0; jpm<=1; jpm=jpm+1) {
                  // for the plus and minus in the 3-direction
                  for (kpm=0; kpm<=1; kpm=kpm+1) {
                     if (i == 0) {
                        if (ipm == 1) {
                           continue; // ! Do not repeat twice for +0 and -0
                        }
                     }
                     if (j == 0) {
                        if (jpm == 1) {
                           continue; // ! Do not repeat twice for +0 and -0
                        }
                     }
                     if (k == 0) {
                        if (kpm == 1) {
                           continue; // ! Do not repeat twice for +0 and -0
                        }
                     }
                     for (atom=0; atom<basis_atoms.size(); atom=atom+1) {
                        // For each coordinate of that atom
                        atom_coordinates.resize(0);
                        atom_coordinates.push_back(basis_atoms[atom][0]+
                           a[0]*pm[ipm]*double(i));
                        atom_coordinates.push_back(basis_atoms[atom][1] +
                           a[1]*pm[jpm]*double(j));
                        atom_coordinates.push_back(basis_atoms[atom][2] +
                           a[2]*pm[kpm]*double(k));
                        returns = vecmatmul(atom_coordinates, Pe);
                        if (returns != 0) {
                           return(0);
                        }
                        // If the coordinates of this atom are 
                        // within the requested dimensions of the slab,
                        // then append them to the final coordinates
                        if (std::abs(atom_coordinates[0]) <= d1/2.0) {
                           if (std::abs(atom_coordinates[1]) <= d2/2.0) {
                              if (std::abs(atom_coordinates[2]) <= d3/2.0) {
                                 final_coordinates.push_back(atom_coordinates);
                                 if (atom <= 2) {
                                    xyz_file_lables.push_back("Si");
                                    in_file_lables.push_back("Si");
                                 }
                                 else if (atom > 1) {
                                    xyz_file_lables.push_back("O");
                                    in_file_lables.push_back("O");
                                 }
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
      }
   }

   //---------------------------------------------------------
   // Print the final coordinates to a .in and a .xyz file:
   //---------------------------------------------------------

   std::ofstream final_coords_xyz_file;
   final_coords_xyz_file.open("alpha-quartz.xyz");
   final_coords_xyz_file << final_coordinates.size() + 1  << std::endl;
   final_coords_xyz_file << "graphite coordinates with Cl at (0,0,0)"
                         << std::endl;
   final_coords_xyz_file << std::left << std::setw(2) << "Cl"
                         << std::setw(18) << std::right
                         << std::fixed << std::setprecision(7)
                         << 0.0
                         << std::setw(19) << std::right
                         << std::fixed << std::setprecision(7)
                         << 0.0
                         << std::setw(19) << std::right
                         << std::fixed << std::setprecision(7)
                         << 0.0
                         << std::endl;

   for (i=0; i<final_coordinates.size(); i=i+1) {
      final_coords_xyz_file << std::left << std::setw(2)
                            << xyz_file_lables[i]
                            << std::setw(18) << std::right
                            << std::fixed << std::setprecision(7)
                            << final_coordinates[i][0]
                            << std::setw(19) << std::right
                            << std::fixed << std::setprecision(7)
                            << final_coordinates[i][1]
                            << std::setw(19) << std::right
                            << std::fixed << std::setprecision(7)
                            << final_coordinates[i][2]
                            << std::endl;
   }

   std::ofstream final_coords_in_file;
   final_coords_in_file.open("alpha-quartz.in");
   for (i=0; i<final_coordinates.size(); i=i+1) {
      final_coords_in_file << std::left << std::setw(5)
                           << in_file_lables[i]
                           << std::setw(15) << std::right
                           << std::fixed << std::setprecision(7)
                           << final_coordinates[i][0]
                           << std::setw(19) << std::right
                           << std::fixed << std::setprecision(7)
                           << final_coordinates[i][1]
                           << std::setw(19) << std::right
                           << std::fixed << std::setprecision(7)
                           << final_coordinates[i][2]
                           << std::endl;
   }

   //-------------------------------------------------------------
   // Construct connectivity matrix and add hydrogen atoms
   // to top layer
   //-------------------------------------------------------------

   // Allocate memory for connectivity matrix:
   connectivity_matrix.resize(final_coordinates.size());
   for (i=0; i<connectivity_matrix.size(); i=i+1) {
      connectivity_matrix[i].resize(final_coordinates.size());
   }

   // Set all elements in connectivity matrix to 0:
   for (i=0; i<connectivity_matrix.size(); i=i+1) {
      for (j=0; j<connectivity_matrix.size(); j=j+1) {
         connectivity_matrix[i][j] = 0.0;
      }
   }

   // Identify bonds between two atoms and set the corresponding
   // connectivity matrix element to 1:
   for (i=0; i<final_coordinates.size(); i=i+1) {
      v1 = final_coordinates[i];
      for (j=0; j<final_coordinates.size(); j=j+1) {
         v2 = final_coordinates[j];
         dist = sqrt( (v1[0]-v2[0])*(v1[0]-v2[0]) + 
               (v1[1]-v2[1])*(v1[1]-v2[1]) +
               (v1[2]-v2[2])*(v1[2]-v2[2]) );
         if ( (std::abs(dist) <= Si_H_bond + 0.2) and (std::abs(dist) >= Si_H_bond - 0.2) ) {
            connectivity_matrix[i][j] = 1.0;
         }
      }
   }

   // Count the number of bonds for each atom. If it is
   // less than 3, and if the atom is on the layer in the, 
   // z-direction, add a hydrogen:
   natoms = connectivity_matrix.size();
   i = 0;
   while (i < natoms) {
      sum = 0.0;
      for (j=0; j<connectivity_matrix[i].size(); j=j+1) {
         sum = sum + connectivity_matrix[i][j];
      }
      if (xyz_file_lables[i] == "O") {
         if (final_coordinates[i][2] > d3/2 - 1.7) {
            if (sum <= 2.5) {
               new_H_coordinates.resize(3);
               new_H_coordinates[0] = final_coordinates[i][0];
	       new_H_coordinates[1] = final_coordinates[i][1];
	       new_H_coordinates[2] = final_coordinates[i][2] + O_H_bond;
               final_coordinates.push_back(new_H_coordinates);
               xyz_file_lables.push_back("H");
               in_file_lables.push_back("H");
            }
	 }
      }
      i = i + 1;
   }

   //--------------------------------------------------------------------
   // Print the final coordinates of the hydrogenated alpha-quartz SiO2
   //--------------------------------------------------------------------
   
   std::ofstream final_coords_xyz_file_2;
   final_coords_xyz_file_2.open("alpha-quartz-H.xyz");
   final_coords_xyz_file_2 << final_coordinates.size() + 1  << std::endl;
   final_coords_xyz_file_2 << "hydrogenated alpha-quartz"
                           << std::endl;
   final_coords_xyz_file_2 << std::left << std::setw(2) << "Cl"
                           << std::setw(18) << std::right
                           << std::fixed << std::setprecision(7)
                           << 0.0
                           << std::setw(19) << std::right
                           << std::fixed << std::setprecision(7)
                           << 0.0
                           << std::setw(19) << std::right
                           << std::fixed << std::setprecision(7)
                           << 0.0
                           << std::endl;
   
   for (i=0; i<final_coordinates.size(); i=i+1) {
      final_coords_xyz_file_2 << std::left << std::setw(2)
                              << xyz_file_lables[i]
                              << std::setw(18) << std::right
                              << std::fixed << std::setprecision(7)
                              << final_coordinates[i][0]
                              << std::setw(19) << std::right
                              << std::fixed << std::setprecision(7)
                              << final_coordinates[i][1]
                              << std::setw(19) << std::right
                              << std::fixed << std::setprecision(7)
                              << final_coordinates[i][2]
                              << std::endl;
   }
   
   std::ofstream final_coords_in_file_2;
   final_coords_in_file_2.open("alpha-quartz-H.in");
   for (i=0; i<final_coordinates.size(); i=i+1) {
      final_coords_in_file_2 << std::left << std::setw(5)
                             << in_file_lables[i]
                             << std::setw(15) << std::right
                             << std::fixed << std::setprecision(7)
                             << final_coordinates[i][0]
                             << std::setw(19) << std::right
                             << std::fixed << std::setprecision(7)
                             << final_coordinates[i][1]
                             << std::setw(19) << std::right
                             << std::fixed << std::setprecision(7)
                             << final_coordinates[i][2]
                             << std::endl;
   }

   return(0);
}
