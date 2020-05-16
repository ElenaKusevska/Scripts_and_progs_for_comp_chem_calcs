#include <vector>
#include <iostream>
#include <cmath>

int print_vector_double(std::vector<double> A) {
   int i;
   for (i=0; i<A.size(); i=i+1) {
      std::cout << A[i] <<  " " ;
   }
   std::cout << " " << std::endl;
//   std::cout << " " << std::endl;
   return(0);
}

