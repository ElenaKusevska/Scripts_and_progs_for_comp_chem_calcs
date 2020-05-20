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

   std::string line, temp;
   char test_char;
   int counts, finds_nl, temp_int;

   //---------------------------------------------
   // get the filename of the xyz coordinates,
   // count the total numbers of rings, and the
   // number of rings per molecule:
   //---------------------------------------------

   std::ifstream inputfile;
   inputfile.open(filename);
   finds_nl = 0; // finds new line
   inputfile.clear(); // To clear the EOF from previously
   inputfile.seekg(0, std::ios::beg); // set to beggining of file
   while (!inputfile.eof()) {
      inputfile.get(test_char);
      if (finds_nl == 0) { // if this is the first character in the line
         // if the first character in the line is f,
         // get the filename of the molecule:
         if (test_char == 'f') {
            getline(inputfile,line); // get this line
            std::stringstream ssin(line); // break up line in string stream
            counts = 1;
            while (ssin.good()){
               ssin >> temp;
               if (counts = 2) {
                  filename = temp;
               }
               counts = counts + 1;
            }
            // go back by 1 character so that get reads '\n' from
            // this line which was read by getline:
            inputfile.seekg(-1, std::ios::cur);
         }
         // if the first character in the line is r,
         // get the atoms that make up the ring:
         if (test_char == 'r') { 
            getline(inputfile,line);
            std::stringstream ssin(line);
            counts = 1;
            while (ssin.good()){
               ssin >> temp;
               std::cout << temp << " ";
               if (counts > 1) {
                  temp_int = std::atoi(temp.c_str());
                  ring_atoms.push_back(temp_int);
               }
               counts = counts + 1;
            }
            // go back by 1 character so that get reads '\n' from
            // this line which was read by getline:
            inputfile.seekg(-1, std::ios::cur);
         }
         // if the first character in the line is P,
         // get the atoms that make up the Pt fragment:
         if (test_char == 'P') {
            getline(inputfile,line);
            std::stringstream ssin(line);
            counts = 1;
            while (ssin.good()){
               ssin >> temp;
               std::cout << temp << " ";
               if (counts > 1) { 
                  temp_int = std::atoi(temp.c_str());
                  fragment_atoms.push_back(temp_int);
               }  
               counts = counts + 1;
            }
            // go back by 1 character so that get reads '\n' from
            // this line which was read by getline:
            inputfile.seekg(-1, std::ios::cur);
         }
      }
      finds_nl = finds_nl + 1; // because it's probably not the
                                       // end of the line
      if (test_char == '\n') { // though, if it is the end of the line:
         finds_nl = 0;
      }
   }

   inputfile.close();
   return 0;
}
