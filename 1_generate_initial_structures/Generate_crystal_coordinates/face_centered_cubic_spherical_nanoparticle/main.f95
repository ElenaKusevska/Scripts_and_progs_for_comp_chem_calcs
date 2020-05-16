program build_particle
   implicit none
   
   integer :: i, j, k, io, nlines
   character(len=1) :: read_char
   character(len=200) :: current_line
   real(kind=8) :: x, y, z, xh, yh, zh, lc

   open (unit=2, file='particle.in', status='new', action='write')

   !-------------------------------------------------
   ! Generate the coordinates and print a .in file:
   !-------------------------------------------------

   ! Core of 10 angstrom fcc gold atoms
   lc = 4.07 ! lattice constant of gold in angstrom
   do i = -3, 3
      do j = -3, 3
         do k = -3, 3
            x = dble(i)*lc
            y = dble(j)*lc
            z = dble(k)*lc 
            xh = (dble(i) + 0.5)*lc ! x and one half
            yh = (dble(j) + 0.5)*lc
            zh = (dble(k) + 0.5)*lc
            ! Face-centered cubic unit cell contains four
            ! unique atoms:
            if (sqrt(x*x + y*y + z*z) < 10.0d0) then
               write (2,*) 'Au    ', x, y, z
            end if
            if (sqrt(xh*xh + yh*yh + z*z) < 10.0d0) then
               write(2,*) 'Au    ', xh, yh, z
            end if
            if (sqrt(x*x + yh*yh + zh*zh) < 10.0d0) then
               write(2,*) 'Au    ', x, yh, zh
            end if
            if (sqrt(xh*xh + y*y + zh*zh) < 10.0d0) then
               write(2,*) 'Au    ', xh, y, zh
            end if
         end do
      end do
   end do

   ! Shell of 5 angstrom fcc platinum atoms
   lc = 3.91 ! lattice constant of platinum in angstrom
   do i = -6, 6
      do j = -6, 6
         do k = -6, 6
            x = dble(i)*lc
            y = dble(j)*lc
            z = dble(k)*lc
            xh = (dble(i) + 0.5)*lc
            yh = (dble(j) + 0.5)*lc
            zh = (dble(k) + 0.5)*lc
            if (sqrt(x*x + y*y + z*z) > 10.0d0) then
               if (sqrt(x*x + y*y + z*z) < 15.0d0) then
                  write (2,*) 'Pt    ', x, y, z
               end if
            end if
            if (sqrt(xh*xh + yh*yh + z*z) > 10.0d0) then
               if (sqrt(xh*xh + yh*yh + z*z) < 15.0d0) then
                  write(2,*) 'Pt    ', xh, yh, z
               end if
            end if
            if (sqrt(x*x + yh*yh + zh*zh) > 10.0d0) then
               if (sqrt(x*x + yh*yh + zh*zh) < 15.0d0) then
                  write(2,*) 'Pt    ', x, yh, zh
               end if
            end if
            if (sqrt(xh*xh + y*y + zh*zh) > 10.0d0) then
               if (sqrt(xh*xh + y*y + zh*zh) < 15.0d0) then
                  write(2,*) 'Pt    ', xh, y, zh
               end if
            end if
         end do
      end do
   end do

   close(2)

   !---------------------------
   ! Write a .xyz file:
   !---------------------------

   open (unit=3, file='particle.in', status='old', action='read')

   ! count the number of lines in particle.in:
	nlines = 0
	do
      read(3,*,iostat=io) read_char
      if (io/=0) exit
      write(*,*) read_char
      nlines = nlines + 1
   end do

   rewind(3)

   open (unit=4, file='particle.xyz', status='new', action='write')

   write(4,*) nlines
   write(4,*) 'kflklv'
   do i = 1, nlines
      read(3,'(A100)') current_line
      write(4,*) trim(current_line)
   end do

   close(3)
   close(4)

end program build_particle
