program main
implicit none

integer :: i
real(kind=8) :: radius
real(kind=8), dimension(3) :: point_A, point_B, midpoint, dist

open (unit=3, file='input', status='old', action='read')


read(3,*) point_A(1), point_A(2), point_A(3)
read(3,*) point_B(1), point_B(2), point_B(3)

! coordinates of midpoint:
do i = 1, 3
  midpoint(i) = (point_A(i) + point_B(i))/2.0
end do

write(*,*) 'midpoint:', midpoint

! distance from midpoint per coordinate
do i = 1, 3
  dist(i) = dabs(midpoint(i) - point_A(i))
end do

! largest distance from midpoint (x, y, or z)
radius = MAXVAL(dist)

write(*,*) 'box size:', radius

end program main
