#include "module.h"
#include <vector>
#include <string>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <sstream>
#include <math.h>

//--------------------------------------------
// Program to find the center of the ring
// And translate the Pt fragment from the
// center of the ring
//--------------------------------------------

int main() {

   //--------------------------------------------------
   // Relevant information that in future versions
   // will be read from an input file:
   //--------------------------------------------------

   std::string filename = "Pt_PF3_4";
   std::vector<int> fragment_1_atoms = {1, 2, 6, 7, 8, 4, 15, 16, 17, 5, 
      9, 10, 11, 13, 14, 3};
   std::vector<int> fragment_2_atoms = {12};
   std::vector<int> dissociating_bond_atoms = {3, 12};
   double increment = 0.1;

   //--------------------------------------------------------
   // Get the coordinates of the molecule, ring 
   // and fragment from the .xyz file, translate the
   // fragment, and print the final coordinates:
   //--------------------------------------------------------

   // Variables:
   std::string in_xyz_file_name, out_xyz_file_name;
   std::string line, temp;
   std::vector<std::string> lables_fragment_1, lables_fragment_2;
   std::vector<std::string> lables_dissociating_bond_atoms;
   std::vector<double> xf1, yf1, zf1, xf2, yf2, zf2;
   std::vector<double> x_bond_atoms, y_bond_atoms, z_bond_atoms;
   std::vector<double> bond_vector, bond_vector_normalized;
   double bond_vector_norm, new_bond_length;
   double temp_double;
   double dx, dy, dz;
   int i, k, line_num, ncycle;

   // reset the coordinate arrays:
   lables_fragment_1.resize(0);
   xf1.resize(0);
   yf1.resize(0);
   zf1.resize(0);
   lables_fragment_2.resize(0);
   xf2.resize(0);
   yf2.resize(0);
   zf2.resize(0);
   lables_dissociating_bond_atoms.resize(0);
   x_bond_atoms.resize(0);
   y_bond_atoms.resize(0);
   z_bond_atoms.resize(0);

   // Open the input file for that molecule and ring:
   in_xyz_file_name = filename + ".xyz";
   std::ifstream in_xyz_file;
   in_xyz_file.open(in_xyz_file_name);

   // get the coordinates of each fragment, and of the bond_vector:
   line_num = 1;
   while (!in_xyz_file.eof()) {
      getline(in_xyz_file,line);
      if (line_num > 2) {
         std::stringstream ssin(line);
         std::vector<std::string> split_line;
         split_line.resize(0);
         while (ssin.good()){
            ssin >> temp;
            split_line.push_back(temp);
         }
         if (split_line.size() > 1) {
            // get lables and coordinates for the atoms in the
            // dissociating bond:
            for (k=0; k<dissociating_bond_atoms.size(); k=k+1){
               if (line_num == dissociating_bond_atoms[k] + 2) {
                  lables_dissociating_bond_atoms.push_back(split_line[0]);
                  temp_double = std::stod(split_line[1]);
                  x_bond_atoms.push_back(temp_double);
                  temp_double = std::stod(split_line[2]);
                  y_bond_atoms.push_back(temp_double);
                  temp_double = std::stod(split_line[3]);
                  z_bond_atoms.push_back(temp_double);
               }
            }
            // get lables and coordinates for fragment 1
            for (k=0; k<fragment_1_atoms.size(); k=k+1){
               if (line_num == fragment_1_atoms[k] + 2) {
                  lables_fragment_1.push_back(split_line[0]);
                  temp_double = std::stod(split_line[1]);
                  xf1.push_back(temp_double);
                  temp_double = std::stod(split_line[2]);
                  yf1.push_back(temp_double);
                  temp_double = std::stod(split_line[3]);
                  zf1.push_back(temp_double);
               }
            }
            // get lables and coordinates for fragment 2:
            for (k=0; k<fragment_2_atoms.size(); k=k+1){
               if (line_num == fragment_2_atoms[k] + 2) {
                  lables_fragment_2.push_back(split_line[0]);
                  temp_double = std::stod(split_line[1]);
                  xf2.push_back(temp_double);
                  temp_double = std::stod(split_line[2]);
                  yf2.push_back(temp_double);
                  temp_double = std::stod(split_line[3]);
                  zf2.push_back(temp_double);
                  continue;
               }
            }
         }
      }
      line_num = line_num + 1;
   }
   in_xyz_file.close();

   std::cout << "fragment 1: " << std::endl;
   for (i=0; i<xf1.size(); i=i+1) {
      std::cout << lables_fragment_1[i] << " " << xf1[i] << " "  << yf1[i] << " " << zf1[i] << std::endl;
   }
   std::cout << " " << std::endl;
   std::cout << "fragment 2: " << std::endl; 
   for (i=0; i<xf2.size(); i=i+1) {
      std::cout << lables_fragment_2[i] << " " << xf2[i] << " "  << yf2[i] << " " << zf2[i] << std::endl;
   }

   // Find the vector describing the bond, and normalize it:
   bond_vector.resize(3);
   bond_vector_normalized.resize(3);

   bond_vector[0] = x_bond_atoms[0] - x_bond_atoms[1];
   bond_vector[1] = y_bond_atoms[0] - y_bond_atoms[1];
   bond_vector[2] = z_bond_atoms[0] - z_bond_atoms[1];
   
   bond_vector_norm = sqrt( bond_vector[0]*bond_vector[0] + 
         bond_vector[1]*bond_vector[1] +
         bond_vector[2]*bond_vector[2] );

   bond_vector_normalized[0] = bond_vector[0]/bond_vector_norm;
   bond_vector_normalized[1] = bond_vector[1]/bond_vector_norm;
   bond_vector_normalized[2] = bond_vector[2]/bond_vector_norm;

   std::cout << "bond_vector_norm: " << bond_vector_norm << std::endl;

   // Displace fragment 2 with respect to fregment 1 in the direction
   // of the bond, and write the new coordinates
   ncycle = -6;
   new_bond_length = bond_vector_norm + increment*double(ncycle);
   while (new_bond_length <= 10.0) {
      std::cout << "new_bond_length: " 
                << new_bond_length << std::endl;

      // Open file to write new coordinates
      out_xyz_file_name = filename + "_" +
         std::to_string(new_bond_length) + ".xyz";
      if_file_exist_delete(out_xyz_file_name);
      std::ofstream out_xyz_file;
      out_xyz_file.open(out_xyz_file_name);
      out_xyz_file << xf1.size() + xf2.size() << std::endl;
      out_xyz_file << "0 1 " << std::endl;

      // Print atoms in fragment 1, not displaced:
      for (k=0; k<xf1.size(); k=k+1) {
         out_xyz_file << std::left << std::setw(2) << lables_fragment_1[k]
                      << std::setw(18) << std::right
                      << std::fixed << std::setprecision(7)
                      << xf1[k]
                      << std::setw(19) << std::right
                      << std::fixed << std::setprecision(7)
                      << yf1[k]
                      << std::setw(19) << std::right
                      << std::fixed << std::setprecision(7)
                      << zf1[k] << std::endl;
      }
      
      // Print atoms in fragment 2, displaced:
      dx = bond_vector_normalized[0] * (bond_vector_norm - new_bond_length);
      dy = bond_vector_normalized[1] * (bond_vector_norm - new_bond_length);
      dz = bond_vector_normalized[2] * (bond_vector_norm - new_bond_length);
      for (k=0; k<fragment_2_atoms.size(); k=k+1) {
         out_xyz_file << std::left << std::setw(2) << lables_fragment_2[k] 
                      << std::setw(18) << std::right
                      << std::fixed << std::setprecision(7)
                      << xf2[k] + dx
                      << std::setw(19) << std::right
                      << std::fixed << std::setprecision(7)
                      << yf2[k] + dy
                      << std::setw(19) << std::right
                      << std::fixed << std::setprecision(7)
                      << zf2[k] + dz
                      << std::endl;
      }

      // Add blank line at end of file
      out_xyz_file << " " << std::endl;
      
      ncycle = ncycle + 1;
      new_bond_length = bond_vector_norm + increment*double(ncycle);
   }

   return 0;
}
