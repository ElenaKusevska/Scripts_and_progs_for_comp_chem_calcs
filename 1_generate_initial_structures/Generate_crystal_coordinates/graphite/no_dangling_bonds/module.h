#ifndef MODULE_H
#define MODULE_H
#include <vector>

int print_vector_double(std::vector<double> A);

int inverse_3_3(std::vector<std::vector<double>> A, std::vector<std::vector<double>> &Ainv);

int vecmatmul (std::vector<double> &Prod, std::vector<std::vector<double>> M);

//int matvecmul (std::vector<std::vector<double>> M, std::vector<double> &Prod);

int matmatmul(std::vector<std::vector<double>> &Prod1, std::vector<std::vector<double>> &Prod2, int overwrite_matrix);

#endif
