#include "module.h"
#include <string>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <cmath>
#include <vector>

//-------------------------------------------------------------
// Program to generate a graphite lattice with given
// lengths in the 1-, 2-, and 3- directions of the
// hexagonal coordinate system. The lattice is centerd
// at (0,0,0) in cartesian coordinates. The program outputs
// the generated coordinates in cartesian coordiantes.
//-------------------------------------------------------------

int main() {

   // Define the desired lengths in each direction here:
   double d1 = 14.5; // lenght in 1-direction
   double d2 = 9.5; // length in 2-direction
   double d3 = 9.0;  // length in 3-direction

   // Define lattice constants of graphite here:
   std::vector<double> a = { 2.45, 2.45, 6.70 };
   
   int i, j, k, ipm, jpm, kpm, atom, returns, runs;
   int natoms, natoms_removed;
   int n1, n2, n3; // number of times to translate in each direction.
                   // Will translate that many times in both the plus
                   // and minus direction.
   double CC_bond = 1.4;
   double dist, sum; // distance between two points
   std::vector<double> pm = { 1.0, -1.0 }; // plus or minus

   std::vector<double> center; // center of mass
   std::vector<double> e1, e2, e3; // unit vectors of basis
   std::vector<std::vector<double>> Pe; // transformation matrix for 
                                        // change of basis to cartesian 
                                        // coordinates
   std::vector<std::vector<double>> Peinv;
   std::vector<std::vector<double>> final_coordinates;
   std::vector<double> atom_coordinates;
   std::vector<double> v1, v2;
   std::vector<std::vector<double>> basis_atoms;
   std::vector<std::vector<double>> unit_cell;
   std::vector<double> final_structure;
   std::vector<std::string> xyz_file_lables;
   std::vector<std::string> in_file_lables;
   std::vector<std::vector<double>> connectivity_matrix;

   //------------------------------------------------------
   // Define the atoms of the basis, and redefine them in
   // such a way that the unit cell is centered at
   // (0,0,0) of the Cartesian coordinate system
   //------------------------------------------------------

   // Independent (basis) points in graphite in hexagonal coordinates:
   basis_atoms.resize(4);
   for (i=0; i<basis_atoms.size(); i=i+1) {
      basis_atoms[i].resize(3);
   }

   // Point 1:
   basis_atoms[0][0] = 0.0;
   basis_atoms[0][1] = 0.0;
   basis_atoms[0][2] = 0.0;

   // Point 2:
   basis_atoms[1][0] = 1.0/3.0;
   basis_atoms[1][1] = 1.0/3.0;
   basis_atoms[1][2] = 0.0;

   // Point 3:
   basis_atoms[2][0] = 0.0;
   basis_atoms[2][1] = 0.0;
   basis_atoms[2][2] = 0.5;

   // Point 4:
   basis_atoms[3][0] = 2.0/3.0;
   basis_atoms[3][1] = 2.0/3.0;
   basis_atoms[3][2] = 0.5;

   // Scale the coordinates of the basis atoms by the size 
   // of the lattice constant:
   for (i=0; i<basis_atoms.size(); i=i+1) {
      for (j=0; j<basis_atoms[i].size(); j=j+1) {
         basis_atoms[i][j] = basis_atoms[i][j]*a[j];
      }
   }

   std::cout << "basis_atoms:" << std::endl;
   for (i=0; i<basis_atoms.size(); i=i+1) {
      print_vector_double(basis_atoms[i]);
   }

   // Define hxagonal/cartesian transformations:
   e1 = {1.0, 0.5, 0.0}; // x-axis
   e2 = {0.0, sqrt(3.0)/2.0, 0.0}; // y-axis
   e3 = {0.0, 0.0, 1.0}; // z-axis

   // Hexagonal -> cartesian transformation matrix:
   Pe.resize(3);
   Pe[0].resize(3);
   Pe[1].resize(3);
   Pe[2].resize(3);
   for (i=0; i<3; i=i+1) {
      Pe[i][0] = e1[i];
      Pe[i][1] = e2[i];
      Pe[i][2] = e3[i];
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

   std::cout << "Peinv:" << std::endl;
   for (i=0; i<Peinv.size(); i=i+1) {
      print_vector_double(Peinv[i]);
   }

   unit_cell.resize(0);
   // Define the unit cell in hexagonal coordinates,
   // and convert it to Cartesian coordinates:
   std::cout << "unit_cell:" << std::endl;
   for (i=0; i<=1; i=i+1) {
      for (j=0; j<=1; j=j+1) {
         for (k=0; k<=1; k=k+1) {
            // (only in the plus direction)
            ipm = 0;
            jpm = 0;
            kpm = 0;
            // For each atom in the unit cell:
            for (atom=0; atom<basis_atoms.size(); atom=atom+1) {
               atom_coordinates.resize(0);
               atom_coordinates.push_back(basis_atoms[atom][0] + 
                     a[0]*pm[ipm]*double(i));
               atom_coordinates.push_back(basis_atoms[atom][1] + 
                     a[1]*pm[jpm]*double(j));
               atom_coordinates.push_back(basis_atoms[atom][2] + 
                     a[2]*pm[kpm]*double(k));
               // If the coordinates of this atom are 
               // within the dimensions of the unit cell, 
               // then append them to the unit_cell:
               if (std::abs(atom_coordinates[0]) <= a[0]+0.1) {
                  if (std::abs(atom_coordinates[1]) <= a[1]+0.1) {
                     if (std::abs(atom_coordinates[2]) <= a[2]+0.1) {
                        returns = vecmatmul(atom_coordinates, Pe);
                        if (returns != 0) {
                           return(0);
                        }
                        unit_cell.push_back(atom_coordinates);
                        std::cout << atom_coordinates[0] << "   "
                                  << atom_coordinates[1] << "   "
                                  << atom_coordinates[2] << "   "
                                  << std::endl;
                     }
                  }
               }
            }
         }
      }
   }

   // Find center of mass of unit cell:
   center.resize(3);
   for (i=0; i<3; i=i+1) {
      center[i] = 0.0;
      for (j=0; j<unit_cell.size(); j=j+1) {
         center[i] = center[i] + unit_cell[j][i];
      }
      center[i] = center[i] / unit_cell.size();
   }
   std::cout << "center: "; 
   print_vector_double(center);

   //  move center of mass to (0,0,0)
   for (i=0; i<unit_cell.size(); i=i+1) {
      for (j=0; j<unit_cell[i].size(); j=j+1) {
         unit_cell[i][j] = unit_cell[i][j] - center[j];
      }
   }

   // Write unit_cell.xyz for viewing with molden
   std::ofstream unit_cell_xyz_file;
   unit_cell_xyz_file.open("unit_cell.xyz");
   unit_cell_xyz_file << unit_cell.size() + 1  << std::endl;
   unit_cell_xyz_file << "graphite unit cell with O at the center"  
                      << std::endl;
   unit_cell_xyz_file << std::left << std::setw(2) << "O"
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
   for (i=0; i<unit_cell.size(); i=i+1) {
      unit_cell_xyz_file << std::left << std::setw(2) << "C"
                         << std::setw(18) << std::right
                         << std::fixed << std::setprecision(7)
                         << unit_cell[i][0]
                         << std::setw(19) << std::right
                         << std::fixed << std::setprecision(7)
                         << unit_cell[i][1]
                         << std::setw(19) << std::right
                         << std::fixed << std::setprecision(7)
                         << unit_cell[i][2]
                         << std::endl;
   }

   // Take the first four vectors from unit_cell as the
   // cartesian coordinates of the basis when the unit cell is
   // centered at (0,0,0), and convert them to hexagonal coordinates:
   returns = matmatmul(unit_cell,Peinv,1);
   if (returns != 0) {
      return(0);
   }
   for (i=0; i<4; i=i+1) {
      for (j=0; j<unit_cell[i].size(); j=j+1) {
         basis_atoms[i][j] = unit_cell[i][j];
      }
   }

   std::cout << " " << std::endl;
   for (i=0; i<basis_atoms.size(); i=i+1) {
      for (j=0; j<basis_atoms[i].size(); j=j+1) {
         std::cout << basis_atoms[i][j];
      }
      std::cout << " " << std::endl;
   }


   //---------------------------------------------------
   // Determine and write the final coordinates:
   //---------------------------------------------------

   // Determine how many times you want to translate in each direction:
   // (some large enough number of times)
   n1 = int( (d1/a[0])/2.0 + 3.0 );
   n2 = int( (d2/a[1])/2.0 + 3.0 );
   n3 = int( (d3/a[2])/2.0 + 3.0 );

   std::cout << " " << std::endl;
   std::cout << "final coordinates:" << std::endl;
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
                                 

                                 std::cout <<  i << " " << j << " " 
                                           << k << " " 
                                           << atom_coordinates[0] << " " << d1/2.0 << " "
                                           << atom_coordinates[1] << " " << d2/2.0 << " "
                                           << atom_coordinates[2] << " " << d3/2.0 << " "
                                           << std::endl;


                                 if (atom <= 1) {
                                    xyz_file_lables.push_back("C");
                                    in_file_lables.push_back("C C1");
                                 }
                                 else if (atom > 1) {
                                    xyz_file_lables.push_back("N");
                                    in_file_lables.push_back("C C2");
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
   final_coords_xyz_file.open("graphite.xyz");
   final_coords_xyz_file << final_coordinates.size() + 1  << std::endl;
   final_coords_xyz_file << "graphite coordinates with O at the center"
                         << std::endl;
   final_coords_xyz_file << std::left << std::setw(2) << "O"
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
   final_coords_in_file.open("graphite.in");
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
   // Construct connectivity matrix and remove singly bonded
   // or nonbonded atoms
   //-------------------------------------------------------------

   for (runs=0; runs<2; runs=runs+1) { // So that all bonds are removed

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
            std::cout << dist << std :: endl;
            if ( (std::abs(dist) <= CC_bond + 0.2) and (std::abs(dist) >= CC_bond - 0.2) ) {
               connectivity_matrix[i][j] = 1.0;
               std::cout << "bond" << std :: endl;
            }
         }
      }

      // Count the number of bonds for each atom. If it is
      // one or zero, remove that atom:
      natoms_removed = 0;
      natoms = connectivity_matrix.size();
      i = 0;
      while (i < natoms) {
         print_vector_double(final_coordinates[i]);
         sum = 0.0;
         for (j=0; j<connectivity_matrix[i].size(); j=j+1) {
            sum = sum + connectivity_matrix[i+natoms_removed][j];
         }
         std::cout << i << " " << final_coordinates.size() << " " << sum << std::endl;
         if (sum <= 1.2) {
            final_coordinates.erase(final_coordinates.begin() + i);
            xyz_file_lables.erase(xyz_file_lables.begin() + i);
            in_file_lables.erase(in_file_lables.begin() + i);
            natoms_removed = natoms_removed + 1;
            natoms = natoms - 1;
            i = i - 1;
            std::cout << "removed" << std::endl;
         }
         i = i + 1;
      }
   }

   //---------------------------------------------------------
   // Print the final coordinates with the singly bonded
   // and nobonded atoms removed to a .in and a .xyz file:
   //---------------------------------------------------------

   std::ofstream final_coords_xyz_file_2;
   final_coords_xyz_file_2.open("graphite_no_dangling_bonds.xyz");
   final_coords_xyz_file_2 << final_coordinates.size() + 1  << std::endl;
   final_coords_xyz_file_2 << "graphite coordinates with no atoms with "
                           << " only one bond to another atom"
                           << std::endl;
   final_coords_xyz_file_2 << std::left << std::setw(2) << "O"
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
   final_coords_in_file_2.open("graphite_no_dangling_bonds.in");
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
