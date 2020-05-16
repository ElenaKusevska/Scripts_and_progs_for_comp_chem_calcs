program test_program
   implicit none
  
   integer :: i, j
   integer, dimension(5,3) :: M
   integer, dimension(3,3) :: A, B

   do i = 1, 5
      do j = 1, 3
         M(i,j) = i+j
      end do
   end do
   write(*,*) "nrows", size(M,1)
   write(*,*) "ncols", size(M,2)
   do i = 1, size(M,1)
      write(*,*) (M(i,j), j = 1, size(M,2))
   end do
   write(*,*)

   A = (reshape((/ 1, 2, 3, 4, 5, 6, 7, 8, 9 /), shape(A)))
   do i = 1,size(A,1)
      write(*,*) (A(i,j), j = 1, size(A,2))
   end do
   write(*,*)

   B = transpose(reshape((/ 1, 2, 3, 4, 5, 6, 7, 8, 9 /), shape(B)))
   do i = 1, size(B,1)
      write(*,*) (B(i,j), j = 1, size(B,2))
   end do
end program test_program
