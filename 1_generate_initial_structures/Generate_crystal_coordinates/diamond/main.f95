program gen_diamond

   !-------------------------------------------------------------
   ! Program to generate a diamond lattice with given
   ! lengths in the x-, y-, and z- directions.
   ! The lattice is centerd at (0,0,0)
   !-------------------------------------------------------------

   implicit none

   integer :: i, j, k, ipm, jpm, kpm, coordinate, atom, p, q
   integer :: n1, n2, n3 ! how many times to translate in 
                              ! each direction. Will translate that many
                              ! times in both the plus and minus
                              ! directions
   real(kind=8), parameter :: d1 = 8.0d0 ! length in x-direction in angst.
   real(kind=8), parameter :: d2 = 8.0d0 ! length in y-direction in angst.
   real(kind=8), parameter :: d3 = 8.0d0 ! length in z-direction in angst.
   real(kind=8), parameter :: a = 3.57d0 !lattice constant of diamond (ang.)
   real(kind=8), dimension(2), parameter :: pm = (/ 1.0d0, -1.0d0 /) ! plus 
                                                                     ! or
                                                                     ! minus
   real(kind=8), dimension(3) :: center ! center of mass
   real(kind=8), dimension(3) :: atom_coordinates
   real(kind=8), dimension(8,3) :: unit_cell
   real(kind=8), dimension(3,8) :: transposed_unit_cell
   real(kind=8), allocatable, dimension(:,:) :: first_cell
   integer :: io, nlines
   character(len=12) :: read_char
   character(len=200) :: current_line

   ! Determine how many times you want to translate in each direction:
   ! (some large enough number of times)
   n1 = int( (d1/a)/2.0d0 + 3.0d0 )
   n2 = int( (d2/a)/2.0d0 + 3.0d0 )
   n3 = int( (d3/a)/2.0d0 + 3.0d0 )

   ! Independent (basis) points in graphite:
   unit_cell = transpose(reshape( (/ 0.0d0, 0.0d0, 0.0d0, &
      0.5d0, 0.5d0, 0.0d0, 0.5d0, 0.0d0, 0.5d0, 0.0d0, &
      0.5d0, 0.5d0, 3.0d0/4.0d0, 3.0d0/4.0d0, 3.0d0/4.0d0, &
      3.0d0/4.0d0, 1.0d0/4.0d0, 1.0d0/4.0d0, 1.0d0/4.0d0, &
      3.0d0/4.0d0, 1.0d0/4.0d0, 1.0d0/4.0d0, 1.0d0/4.0d0, &
      3.0d0/4.0d0 /), shape(transposed_unit_cell) ))

   ! Scale the basis points by the lattice constant:
   do i = 1, size(unit_cell,1)
      do j = 1, size(unit_cell,2)
         unit_cell(i,j) = unit_cell(i,j)*a
      end do
   end do

   ! Write the first cell
   open (unit=7, file='first_cell', status='new', action='write')
   do i = 0,1
      do j = 0,1
         do k = 0,1
            ! for the plus directio:
            ipm = 1
            jpm = 1
            kpm = 1
            ! For each atom in the unit cell:
            do atom = 1, size(unit_cell,1)
               ! For each coordinate of that atom
               atom_coordinates(1) = unit_cell(atom,1) + &
                  a*pm(ipm)*dble(i)
               atom_coordinates(2) = unit_cell(atom,2) + &
                  a*pm(jpm)*dble(j)
               atom_coordinates(3) = unit_cell(atom,3) + &
                  a*pm(kpm)*dble(k)
               ! If the coordinates of this atom are 
               ! within the requested dimensions of the slab, 
               ! then write them to the output file:
               if (atom_coordinates(1) <= a+0.1) then
                  if (atom_coordinates(2) <= a+0.1) then
                     if (atom_coordinates(3) <= a+0.1) then
                        write(7,*) (atom_coordinates(coordinate), &
                        coordinate = 1, 3)
                     end if
                  end if
               end if
            end do
         end do
      end do
   end do
   close(7)

   ! Read the first cell:
   open (unit=8, file='first_cell', status='old', action='read')
   ! count the number of lines in first_cell:
   nlines = 0
   do
      read(8,*,iostat=io) read_char
      if (io/=0) exit
      nlines = nlines + 1
      write(*,*) nlines
   end do
   
   rewind(8)
   allocate(first_cell(nlines,3))
   do p = 1, nlines
      read(8,*) first_cell(p,1), first_cell(p,2), first_cell(p,3)
      write(*,*) (first_cell(p,q), q = 1,3)
   end do
   close(8)
   
   ! Find center of mass of unit cell (first_cell is the
   ! actual unit cell):
   do i = 1,3
      center(i) = 0.0d0
      do j = 1, size(first_cell,1)
         center(i) = center(i) + first_cell(j,i)
      end do
      center(i) = center(i) / dble(size(first_cell,1))
   end do
   write(*,*) "center:", center
   deallocate(first_cell)

   ! move center of mass to 0,0,0
   do i = 1, 3
      do j = 1, size(unit_cell,1)
         unit_cell(j,i) = unit_cell(j,i) - center(i)
      end do
   end do

   ! Write the .in file with the geometry of the
   ! generated diamond lattice:
   open (unit=2, file='diamond.in', status='new', action='write')

   write(2,*) "O", 0.0d0, 0.0d0, 0.0d0
   write(2,*) "N", center(1), center(2), center(3)

   ! For the number of times the unit cell has to be repliicated
   ! in the x-direction
   do i = 0,n1
      ! For the number of times the unit cell has to be repliicated
      ! in the y-direction
      do j = 0, n2
         ! For the number of times the unit cell has to be repliicated
         ! in the z-direction
         do k = 0, n3
            ! for the plus and minus of x:
            do ipm = 1, 2
               ! for the plus and minus of y:
               do jpm = 1, 2
                  ! for the plus and minus of z:
                  do kpm = 1,2
                     if ( i == 0 ) then
                        if ( ipm == 2 ) then
                           cycle ! Do not repeat twice for +0 and -0
                        end if
                     end if
                     if ( j == 0 ) then
                        if ( jpm == 2 ) then
                           cycle
                        end if
                     end if
                     if ( k == 0 ) then
                        if ( kpm == 2 ) then
                           cycle
                        end if
                     end if
                     ! For each atom in the unit cell:
                     do atom = 1, size(unit_cell,1)
                        ! For each coordinate of that atom
                        atom_coordinates(1) = unit_cell(atom,1) + &
                           a*pm(ipm)*dble(i)
                        atom_coordinates(2) = unit_cell(atom,2) + &
                           a*pm(jpm)*dble(j)
                        atom_coordinates(3) = unit_cell(atom,3) + &
                           a*pm(kpm)*dble(k)
                        ! If the coordinates of this atom are 
                        ! within the requested dimensions of the slab, 
                        ! then write them to the output file:
                        if (dabs(atom_coordinates(1)) <= d1/2.0d0) then
                           if (dabs(atom_coordinates(2)) <= d2/2.0d0) then
                              if (dabs(atom_coordinates(3)) <= d3/2.0d0) then
                                 write(2,'(A1,A4,3F15.9)') "C", "    ",&
                                    (atom_coordinates(coordinate), &
                                    coordinate = 1, 3)
                              end if
                           end if
                        end if
                     end do
                  end do
               end do
            end do
         end do
      end do
   end do

   close(2)

   ! Write a .xyz file:
   open (unit=3, file='diamond.in', status='old', action='read')

   ! count the number of lines in particle.in:
   nlines = 0
   do
      read(3,*,iostat=io) read_char
      if (io/=0) exit
      nlines = nlines + 1
   end do

   rewind(3)

   open (unit=4, file='diamond.xyz', status='new', action='write')

   write(4,*) nlines
   write(4,*) 'kflklv'
   do i = 1, nlines
      read(3,'(A100)') current_line
      write(4,*) trim(current_line)
   end do

   close(3)
   close(4)

end program gen_diamond
