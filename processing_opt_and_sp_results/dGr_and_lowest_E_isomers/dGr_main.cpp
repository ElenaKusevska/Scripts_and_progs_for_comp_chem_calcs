#include "functions.h"
#include "get_from_gaussian_output.h"
#include <cstdlib>
#include <stdlib.h>
#include <stdio.h>
#include <vector>
#include <string>
#include <sstream>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <unistd.h>
#include <limits.h>

int main() {

   //--------------------------------
   // Variables:
   //--------------------------------

   // Variables to hold the information about reactions, reactants
   // and products, levels of theory:
   std::vector <std::vector <int> > reactants, products; // indeces to 
                                    //specify location of reactants' 
                                    // and products' lables 
                                    // in chemical_species array
   std::vector<std::string> chemical_species; // every reactant/product
   std::vector<std::string> lowest_E_isomer;
   std::vector<std::string> reactions; // reactions to calculate dG
   std::string lower_level_of_theory;
   std::string higher_level_of_theory;

   // Variables to get information out of .out file:
   std::vector<std::string> ls_output_dir;
   std::string one_up = ".."; // go one directory up
   std::string two_up = "../../"; // go two directories up

   // Variables to hold information from .out file:
   std::vector<double> E_opt, G_opt, freq, cpu_time;
   std::vector<double> E_sp, G_sp, dGrs;  
   std::vector<int> imaginary_freq; // 1=yes; 0=no

   // Other variables:
   std::string goutfilename, dGroutfilename;
   int i, j, k ;

   //---------------------------------------------
   // Get the information from the input file:
   //---------------------------------------------

   read_from_input(reactants, products, reactions, chemical_species, lower_level_of_theory, higher_level_of_theory);
   
   //---------------------------------------------
   // Get values from gaussian output:
   //---------------------------------------------

   E_opt.resize(chemical_species.size());
   E_sp.resize(chemical_species.size());
   G_opt.resize(chemical_species.size());
   G_sp.resize(chemical_species.size());
   freq.resize(chemical_species.size());
   imaginary_freq.resize(chemical_species.size());
   cpu_time.resize(chemical_species.size());
   lowest_E_isomer.resize(chemical_species.size());

   // Assuming we only have one geometry for each species:
   for (i=0; i<chemical_species.size(); i=i+1) {
      lowest_E_isomer[i] = "only_geometry";
   }

   for (i=0; i<chemical_species.size(); i=i+1) {

      // Are there multiple low E isomers for chemical_species[i] ?
      change_directory(lower_level_of_theory) ;
      change_directory(chemical_species[i]);
      run_bash_command("ls -d */  2> /dev/null",ls_output_dir);
      pop_back_dir_array(ls_output_dir); // because of //n at the end
      change_directory(two_up);
      
      // If there are multiple low E isomers 
      // there will be several subdirectories in this directory:
      if (!ls_output_dir.empty()) {
         std::cout << chemical_species[i] 
            << " has several isomers: " << std::endl;
         print_vector_string(ls_output_dir);

         // Find the lowest energy isomer:
         sort_multiple_geometries (ls_output_dir, chemical_species[i], 
               lower_level_of_theory, higher_level_of_theory,
               lowest_E_isomer[i]);

         // Get the energies, smallest frequency and cpu time
         // for the lowest energy isomer
         gauss_output_multiple_isomers(chemical_species[i], 
               lowest_E_isomer[i], E_opt[i], G_opt[i], freq[i], 
               cpu_time[i], E_sp[i], G_sp[i], imaginary_freq[i],
               lower_level_of_theory, higher_level_of_theory);
      }
      
      // If there is only one structure:
      else if (ls_output_dir.empty()) {
         gauss_output_one_isomer(chemical_species[i], E_opt[i], G_opt[i], 
               freq[i], cpu_time[i], E_sp[i], G_sp[i], imaginary_freq[i],
               lower_level_of_theory, higher_level_of_theory);

      }
   }

   //---------------------------------------------
   // Print values from Gaussian output to file:
   //---------------------------------------------
   
   goutfilename = "gaussian_output";
   if_file_exist_delete(goutfilename);
   std::ofstream goutput;
   goutput.open (goutfilename.c_str());
   goutput << "species lowest_E_isomer E_opt G_opt E_sp " 
           << "G_sp freq cpu_time_minutes" << std::endl;
   for (i=0; i<chemical_species.size(); i=i+1) {
      goutput << chemical_species[i] << " " << lowest_E_isomer[i] << " " 
              << E_opt[i] << " " << G_opt[i] << " " 
              << E_sp[i] << " " << G_sp[i] << " " 
              << freq[i] << " " << cpu_time[i] << std::endl;
   }

   goutput.close();

   //---------------------------------------
   // Gibbs free energies of reagtion:
   //---------------------------------------

   dGrs.resize(reactions.size());
   for (k=0; k<reactions.size(); k=k+1) {

      dGrs[k] = 0.0;
      for (j=0; j<products[k].size(); j=j+1) {
         dGrs[k] = dGrs[k] + G_sp[products[k][j]];
      }
      for (j=0; j<reactants[k].size(); j=j+1) {
         dGrs[k] = dGrs[k] - G_sp[reactants[k][j]];
      }
   }

   //---------------------------------------
   // Print Gibbs free energies to file:
   //---------------------------------------

   dGroutfilename = "free_energies_of_reaction";
   if_file_exist_delete(dGroutfilename);
   std::ofstream reaction_energies;
   reaction_energies.open (dGroutfilename.c_str());

   reaction_energies << "R_i: reactants_j(freq_j) ---> products_j(freq_j)"
                     << std::endl;

   for (i=0; i<reactions.size(); i=i+1) {
      reaction_energies << "--------------------------------------------\n";
      reaction_energies << reactions[i] << ": ";
      for (j=0; j<reactants[i].size(); j=j+1) { 
         reaction_energies << chemical_species[reactants[i][j]]
                           << "(" << freq[reactants[i][j]] << ")" << " ";
      }
      reaction_energies << "---> ";
      for (j=0; j<products[i].size(); j=j+1) {
         reaction_energies << chemical_species[products[i][j]]
                           << "(" << freq[products[i][j]] << ")" << " ";
      }
      reaction_energies << "dGr = " << dGrs[i]*627.51 
                        << " kcal/mol" << std::endl;
   }   
   reaction_energies << "--------------------------------------------\n";
   
   reaction_energies.close();

   return 0;
}
