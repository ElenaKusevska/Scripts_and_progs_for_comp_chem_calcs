#ifndef GET_FROM_GAUSSIAN_OUTPUT_H
#define GET_FROM_GAUSSIAN_OUTPUT_H
#include <vector>
#include <string>

int print_vector_int(std::vector<int> A);

int print_vector_double(std::vector<double> A);

int print_vector_string(std::vector<std::string> A);

int print_matrix_int(std::vector<std::vector<int> > A);

bool fexists(const char *filename);

int if_file_exist_delete (std::string filename);

int read_input_file(std::string& filename, std::vector<int>& ring_atoms, \
      std::vector<int>& fragment_atoms);

#endif

