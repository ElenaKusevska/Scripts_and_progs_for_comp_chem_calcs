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

   //---------------------------------------------
   // Get the information out of the input file:
   //--------------------------------------------- 

   // Variables to get out of input file:
   std::string filename;
   std::vector<int> ring_atoms; // atoms making up the ring
   std::vector<int> fragment_atoms; // atoms making up the fragment
                                    // interacting with the ring
   
   // Read input file:
   filename = "input";
   read_input_file(filename, ring_atoms, fragment_atoms);
   std::cout << "read input from input file: " << filename << std::endl;
   std::cout << "ring atoms: " ;
   print_vector_int(ring_atoms);
   std::cout << "fragment atoms: ";
   print_vector_int(fragment_atoms);

   //--------------------------------------------------------
   // Get the coordinates of the molecule, ring 
   // and fragment from the .xyz file, translate the
   // fragment, and print the final coordinates:
   //--------------------------------------------------------

   // Variables:
   std::string in_xyz_file_name, out_xyz_file_name;
   std::string line, temp;
   std::vector<std::string> lables_ring, lables;
   std::vector<double> xring, yring, zring,  x, y, z;
   std::vector<double> Pt_rvec, Pt_rvec_normalized;
   std::vector<double> Pt_rvec_new, Pt_rvec_old;
   double Pt_rvec_norm, Pt_rvec_new_length, Pt_rvec_old_length;
   double dx_Pt, dy_Pt, dz_Pt;
   double temp_double;
   double xsum, ysum, zsum, xcenter, ycenter, zcenter;
   int i, k, kk, line_num;

   // reset the coordinate arrays:
   lables.resize(0);
   x.resize(0);
   y.resize(0);
   z.resize(0);
   lables_ring.resize(0);
   xring.resize(0);
   yring.resize(0);
   zring.resize(0);

   // Open the input file for that molecule and ring:
   in_xyz_file_name = filename + ".xyz";
   std::ifstream in_xyz_file;
   in_xyz_file.open(in_xyz_file_name);

   // get the coordinates of the ring and the molecule:
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
            // get lables and coordinates for whole molecule
            lables.push_back(split_line[0]);
            temp_double = std::stod(split_line[1]);
            x.push_back(temp_double);
            temp_double = std::stod(split_line[2]);
            y.push_back(temp_double);
            temp_double = std::stod(split_line[3]);
            z.push_back(temp_double);
            for (k=0; k<ring_atoms.size(); k=k+1){
               if (line_num == ring_atoms[k] + 2) {
                  // get lables and coordinates for ring:
                  lables_ring.push_back(split_line[0]);
                  temp_double = std::stod(split_line[1]);
                  xring.push_back(temp_double);
                  temp_double = std::stod(split_line[2]);
                  yring.push_back(temp_double);
                  temp_double = std::stod(split_line[3]);
                  zring.push_back(temp_double);
                  continue;
               }
            }
         }
      }
      line_num = line_num + 1;
   }
   in_xyz_file.close();

   std::cout << "ring coordinates: " << std::endl;
   for (i=0; i<xring.size(); i=i+1) {
      std::cout << xring[i] << " "  << yring[i] << " " << zring[i] << std::endl;
   }

   // Find center of ring:
   xsum = 0.0;
   ysum = 0.0;
   zsum = 0.0;
   for (k=0; k<xring.size(); k=k+1) {
      xsum = xsum + xring[k];
      ysum = ysum + yring[k];
      zsum = zsum + zring[k];
   }
   xcenter = xsum/xring.size();
   ycenter = ysum/yring.size();
   zcenter = zsum/zring.size();

   // Move the coordinates vectors for the 
   // entire molecule so that the center of the 
   // ring is positioned at (0,0,0):
   for (k=0; k<x.size(); k=k+1) {
      x[k] = x[k] - xcenter;
      y[k] = y[k] - ycenter;
      z[k] = z[k] - zcenter;
   }

   // Find radius vector for platinum atom
   // (first atom in fragment is Pt)
   // And normalize it:
   Pt_rvec.resize(3);
   Pt_rvec_normalized.resize(3);
   Pt_rvec_new.resize(3);
   Pt_rvec_old.resize(3);

   Pt_rvec[0] = x[fragment_atoms[0]-1];
   Pt_rvec[1] = y[fragment_atoms[0]-1];
   Pt_rvec[2] = z[fragment_atoms[0]-1];
   
   Pt_rvec_norm = sqrt( Pt_rvec[0]*Pt_rvec[0] + Pt_rvec[1]*Pt_rvec[1] +
         Pt_rvec[2]*Pt_rvec[2] );

   Pt_rvec_normalized[0] = Pt_rvec[0]/Pt_rvec_norm;
   Pt_rvec_normalized[1] = Pt_rvec[1]/Pt_rvec_norm;
   Pt_rvec_normalized[2] = Pt_rvec[2]/Pt_rvec_norm;

   std::cout << "Pt - optimized distance: " << Pt_rvec_norm << std::endl;
   Pt_rvec_old_length = Pt_rvec_norm;
   Pt_rvec_new[0] = 0.0;
   Pt_rvec_new[1]= 0.0;
   Pt_rvec_new[2] = 0.0;
   Pt_rvec_old[0] = Pt_rvec[0];
   Pt_rvec_old[1] = Pt_rvec[1];
   Pt_rvec_old[2] = Pt_rvec[2];
   while (Pt_rvec_new_length < 10.0) {
      // Increase length of Pt radius atom, and translate the
      // atoms of the fragment correspondingly
      Pt_rvec_new_length = Pt_rvec_old_length + 0.2;
      std::cout << "Pt_rvec_new_length: " 
                << Pt_rvec_new_length << std::endl;
      Pt_rvec_new[0] = Pt_rvec_normalized[0] * Pt_rvec_new_length;
      Pt_rvec_new[1] = Pt_rvec_normalized[1] * Pt_rvec_new_length;
      Pt_rvec_new[2] = Pt_rvec_normalized[2] * Pt_rvec_new_length;
      dx_Pt = Pt_rvec_new[0] - Pt_rvec_old[0];
      dy_Pt = Pt_rvec_new[1] - Pt_rvec_old[1];
      dz_Pt = Pt_rvec_new[2] - Pt_rvec_old[2];
      for (k=0; k<fragment_atoms.size(); k=k+1) {
         x[fragment_atoms[k]-1] = x[fragment_atoms[k]-1] + dx_Pt;
         y[fragment_atoms[k]-1] = y[fragment_atoms[k]-1] + dy_Pt;
         z[fragment_atoms[k]-1] = z[fragment_atoms[k]-1] + dz_Pt;
         std::cout << "fragment_atoms[k] " << fragment_atoms[k] << std::endl;
      }

      // Open file to print the new coordinates:
      out_xyz_file_name = "Pt-ring_" + 
                           std::to_string(Pt_rvec_new_length) + ".xyz";
      if_file_exist_delete(out_xyz_file_name);
      std::ofstream out_xyz_file;
      out_xyz_file.open(out_xyz_file_name);

      // printing:
      out_xyz_file << x.size()  << std::endl;
      out_xyz_file << "0 1 " << std::endl;
      for (kk=0; kk<x.size(); kk=kk+1) {
         out_xyz_file << std::left << std::setw(2) << lables[kk] 
                      << std::setw(18) << std::right
                      << std::fixed << std::setprecision(7)
                      << x[kk] 
                      << std::setw(19) << std::right
                      << std::fixed << std::setprecision(7)
                      << y[kk] 
                      << std::setw(19) << std::right
                      << std::fixed << std::setprecision(7)
                      << z[kk] << std::endl;
      }
      
      // Reset for next iteration:
      Pt_rvec_old_length = Pt_rvec_new_length;
      Pt_rvec_old[0] = Pt_rvec_new[0];
      Pt_rvec_old[1] = Pt_rvec_new[1];
      Pt_rvec_old[2] = Pt_rvec_new[2];
   }

   return 0;
}
