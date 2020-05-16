program generate_indices
implicit none

real(kind=8) :: a, b, c, d, a1, b1, c1, a2, b2, c2, interv1, interv2, interv3
integer:: ia, ib, ic

!a program to generate indices for ./top_grid

write(*,*) 'origin?'
read(*,*) a1, b1, c1
write(*,*) 'axes?'
read(*,*) a2, b2, c2

a = a2 - a1
b = b2 - b1
c = c2 - c1

write(*,*) 'd          a              b              c'

d = 10.1
do while (d .gt. 0)
 d = d - 0.1
  interv1 = a*d
    ia = nint(interv1)
  interv2 = b*d
    ib = nint(interv2)
  interv3 = c*d
    ic = nint(interv3)
  write(*,*) d, ia, ib, ic
end do

end program generate_indices
