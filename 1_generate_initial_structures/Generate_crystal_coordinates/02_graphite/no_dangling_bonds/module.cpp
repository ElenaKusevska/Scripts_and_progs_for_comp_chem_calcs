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

int inverse_3_3(std::vector<std::vector<double>> A, std::vector<std::vector<double>> &Ainv) {
   double detA;
   int i;

   // Test that both A and Ainv are 3x3 matrices
   if (A.size() != 3) {
      std::cout << "A has: " << A.size() << " rows." << std::endl;
      return(1);
   }
   for (i=1; i<A.size(); i=i+1) {
      if (A[i].size() != 3) {
         std::cout << "row " << i << " has: " << A.size() 
                   << " columns." << std::endl;
         return(1);
      }
   }
   if (Ainv.size() != 3) {
      std::cout << "Ainv has: " << Ainv.size() << " rows." << std::endl;
      return(1);
   }     
   for (i=1; i<Ainv.size(); i=i+1) {
      if (Ainv[i].size() != 3) {
         std::cout << "row " << i << " has: " << Ainv[i].size()
                   << " columns." << std::endl;
         return(1);
      }     
   }

   // Determine the determinant:
   detA = A[0][0]*A[1][1]*A[2][2] - A[0][0]*A[1][2]*A[2][1] -
      A[0][1]*A[1][0]*A[2][2] + A[0][1]*A[1][2]*A[2][0] +
      A[0][2]*A[1][0]*A[2][1] - A[0][2]*A[1][1]*A[2][0];
   std::cout << detA << std::endl;
   
   if (std::abs(detA) <= 0.000000001) {
      std::cout << "matrix is sinuglar (detA ~ 0)" << std::endl;
      return(1);
   }

   // Determine the inverse:
   Ainv[0][0] = 1/detA * (A[1][1]*A[2][2] - A[2][1]*A[1][2]);
   Ainv[0][1] = 1/detA * (A[0][2]*A[2][0] - A[2][2]*A[0][1]);
   Ainv[0][2] = 1/detA * (A[0][1]*A[1][2] - A[1][1]*A[0][2]);
   Ainv[1][0] = 1/detA * (A[1][2]*A[2][0] - A[2][2]*A[1][0]);
   Ainv[1][1] = 1/detA * (A[0][0]*A[2][2] - A[2][0]*A[0][2]);
   Ainv[1][2] = 1/detA * (A[0][2]*A[1][0] - A[1][2]*A[0][0]);
   Ainv[2][0] = 1/detA * (A[1][0]*A[2][1] - A[2][0]*A[1][1]);
   Ainv[2][1] = 1/detA * (A[0][1]*A[2][0] - A[2][1]*A[0][0]);
   Ainv[2][2] = 1/detA * (A[0][0]*A[1][1] - A[1][0]*A[0][1]);
   
   return(0);
}

int vecmatmul (std::vector<double> &Prod, std::vector<std::vector<double>> M) {
   int i, k;
   std::vector<double> V = Prod;

   if (V.size() != M.size()) { // Dimension test
      std::cout << "ERROR: vecmatmul: dimensions don't match" << std::endl;
      return(1);
   }

   for (i=1; i<M.size(); i=i+1) { // All rows have the same size
      if (M[i].size() != M[0].size()) {
         std::cout << "ERROR: vecmatmul: not all rows in M" 
                   << " have the same size" << std::endl;
         return(1);
      }
   }

   for (k=0; k<M[0].size(); k=k+1) {
      Prod[k] = 0.0;
      for(i=0; i<V.size(); i=i+1) {
         Prod[k] = Prod[k] + V[i]*M[i][k]; // V*comlumns in M
      }
   }

   return(0);
}

//int matvecmul (std::vector<std::vector<double>> M, std::vector<double> &Prod) {
//
//   int i, k;
//   std::vector<double> V = Prod;
//   
//   for (i=0; i<M.size(); i=i+1) { // Dimension test
//      if (M[i].size() != V.size()) {
//         std::cout << "ERROR: matvecmul: dimensions"
//                   << " don't match" << std::endl;
//         return(1);
//      }
//   }
//   
//   for (i=1; i<M.size(); i=i+1) { // All rows have the same size
//      if (M[i].size() != M[0].size()) {
//         std::cout << "ERROR: matvecmul: not all rows in M"
//                   << " have the same size" << std::endl;
//         return(1);
//      }
//   }
//   
//   for (i=0; i<M.size(); i=i+1) { // rows in M1
//   Prod[i] = 0.0;
//   for(k=0; k<V.size(); k=k+1) {
//         Prod[i] = Prod[i] + M[i][k]*V[k];
//      }
//   }
//
//   return(0);
//}


int matmatmul(std::vector<std::vector<double>> &Prod1, std::vector<std::vector<double>> &Prod2, int overwrite_matrix) {
   int i, j, k;
   std::vector<std::vector<double>> M1 = Prod1;
   std::vector<std::vector<double>> M2 = Prod2;


   for (i=0; i<M1.size(); i=i+1) { // Dimension test
      if (M1[i].size() != M2.size()) {
         std::cout << "ERROR: matmatmul: dimensions" 
                   << " don't match" << std::endl;
         return(1);
      }
   }

   for (i=1; i<M1.size(); i=i+1) { // All rows have the same size
      if (M1[i].size() != M1[0].size()) {
         std::cout << "ERROR: matmatmul: not all rows in M1" 
                   << " have the same size" << std::endl;
         return(1);
      }
   }

   for (i=1; i<M2.size(); i=i+1) { // All rows have the same size
      if (M2[i].size() != M2[0].size()) {
         std::cout << "ERROR: matmatmul: not all rows in M2"
                   << " have the same size" << std::endl;
         return(1);
      }
   }

   for (i=0; i<M1.size(); i=i+1) { // rows in M1
      for (j=0; j<M1[i].size(); j=j+1) { // columns in M2
         if (overwrite_matrix == 1) { //Overwrite Prod1
            Prod1[i][j] = 0.0;
            for(k=0; k<M1[i].size(); k=k+1) {
               Prod1[i][j] = Prod1[i][j] + M1[i][k]*M2[k][j];
               
            }
         }
         else if (overwrite_matrix == 2) { // Overwrite Prod2
            Prod2[i][j] = 0.0;
            for(k=0; k<M1[i].size(); k=k+1) {
               Prod2[i][j] = Prod2[i][j] + M1[i][k]*M2[k][j];
            }
         }
      }
   }

   return(0);
}
