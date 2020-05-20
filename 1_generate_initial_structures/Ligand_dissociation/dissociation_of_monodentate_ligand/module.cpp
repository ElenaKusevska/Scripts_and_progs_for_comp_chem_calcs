#include <array>
#include <vector>
#include <string>
#include <iostream>
#include <fstream>
#include <sstream>
#include <cstdlib>
#include <math.h>

int print_vector_int(std::vector<int> A) {
   int i;
   for (i=0; i<A.size(); i=i+1) {
      std::cout << A[i] <<  " " ;
   }
   std::cout << " " << std::endl;
   std::cout << " " << std::endl;
   return 0;
}

int print_vector_double(std::vector<double> A) {
   int i;
   for (i=0; i<A.size(); i=i+1) {
      std::cout << A[i] <<  " " ;
   }
   std::cout << " " << std::endl;
   std::cout << " " << std::endl;
   return 0;
}

int print_vector_string(std::vector<std::string> A) {
   int i;
   for (i=0; i<A.size(); i=i+1) {
      std::cout << A[i] << " ";
   }
   std::cout << " " << std::endl;
   std::cout << " " << std::endl;
   return 0;
}

int print_matrix_int(std::vector<std::vector<int> > A) {
   int i, j;
   for (i=0; i<A.size(); i=i+1) {
      for (j=0; j<A[i].size(); j=j+1) {
         std::cout << A[i][j] << " ";
      }
      std::cout << " " << std::endl;
   }
   std::cout << " " << std::endl;
   return 0;
}

bool fexists(const char *filename) {
   std::ifstream ifile(filename);
   return ifile.good();
}

int if_file_exist_delete (std::string filename) {
   if (fexists(filename.c_str())) {
      if (std::remove(filename.c_str()) != 0) {
          std::cout << "failed to remove " << filename << std::endl;
          exit(1);
       }
       else {
          std::cout << filename << " found and deleted " << std::endl;
       }
   }
   return 0;
}

int read_input_file(std::string& filename, std::vector<int>& ring_atoms, \
      std::vector<int>& fragment_atoms) {

   return 0;
}
