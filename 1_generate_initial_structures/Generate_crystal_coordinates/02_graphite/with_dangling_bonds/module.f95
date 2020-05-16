module graphite_mod
   implicit none
   contains

   subroutine inverse_3_3 (A,Ainv)

      real(kind=8), dimension(3,3), intent(in) :: A
      real(kind=8), dimension(3,3), intent(out) :: Ainv
      real(kind=8) :: detA
      integer :: i, j

      if (size(A,1) .ne. 3) then
         write(*,*) "matrix is not 3x3"
         stop
      end if

      if (size(A,2) .ne. 3) then
         write(*,*) "matrix is not 3x3"
         stop
      end if

      ! Determine the determinant
      detA = A(1,1)*A(2,2)*A(3,3) - A(1,1)*A(2,3)*A(3,2) - &
         A(1,2)*A(2,1)*A(3,3) + A(1,2)*A(2,3)*A(3,1) + &
         A(1,3)*A(2,1)*A(3,2) - A(1,3)*A(2,2)*A(3,1)
      write(*,*) "detA:", detA

      if (dabs(detA) .le. 0.0000000001) then
         write(*,*) "matrix is sinuglar (detA ~ 0)"
         stop
      end if

      ! Determine the inverse:
      Ainv(1,1) = 1/detA * (A(2,2)*A(3,3) - A(3,2)*A(2,3))
      Ainv(1,2) = 1/detA * (A(1,3)*A(3,2) - A(3,3)*A(1,2))
      Ainv(1,3) = 1/detA * (A(1,2)*A(2,3) - A(2,2)*A(1,3))
      Ainv(2,1) = 1/detA * (A(2,3)*A(3,1) - A(3,3)*A(2,1))
      Ainv(2,2) = 1/detA * (A(1,1)*A(3,3) - A(3,1)*A(1,3))
      Ainv(2,3) = 1/detA * (A(1,3)*A(2,1) - A(2,3)*A(1,1))
      Ainv(3,1) = 1/detA * (A(2,1)*A(3,2) - A(3,1)*A(2,2))
      Ainv(3,2) = 1/detA * (A(1,2)*A(3,1) - A(3,2)*A(1,1))
      Ainv(3,3) = 1/detA * (A(1,1)*A(2,2) - A(2,1)*A(1,2))
      do i = 1, 3
         write(*,*) (Ainv(i,j), j = 1, 3)
      end do

   end subroutine inverse_3_3

end module graphite_mod
