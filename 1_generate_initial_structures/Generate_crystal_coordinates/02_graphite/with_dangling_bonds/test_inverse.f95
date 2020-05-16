program test_inv
   use graphite_mod
   implicit none

   real(kind=8), dimension(3,3) :: B, Binv

   B(1,1) = 212.4d0
   B(1,2) = 25.3d0
   B(1,3) = 41.3d0
   B(2,1) = 0.7d0
   B(2,2) = 8.2d0
   B(2,3) = 6.1d0
   B(3,1) = 5.0d0
   B(3,2) = 4.0d0
   B(3,3) = 3.0d0

   call inverse_3_3(B,Binv)

end program test_inv

