program gen_graphite
   use graphite_mod

   !-------------------------------------------------------------
   ! Program to generate a graphite lattice with given
   ! lengths in the 1-, 2-, and 3- directions of the
   ! hexagonal coordinate system. The lattice is centerd
   ! at (0,0,0) in cartesian coordinates. The program outputs
   ! the generated coordinates in cartesian coordiantes.
   !-------------------------------------------------------------

   implicit none

   integer :: i, j, k, l, ipm, jpm, kpm, coordinate, atom, p, q
   integer :: n1, n2, n3 ! how many times to translate in 
                              ! each direction. Will translate that many
                              ! times in both the plus and minus
                              ! directions
   real(kind=8), parameter :: d1 = 11.0d0 ! length in 1-direction in angst.
   real(kind=8), parameter :: d2 = 11.0d0 ! length in 2-direction in angst.
   real(kind=8), parameter :: d3 = 9.0d0 ! length in 3-direction in angst.
   real(kind=8), dimension(2), parameter :: pm = (/ 1.0d0, -1.0d0 /) ! plus 
                                                                     ! or
                                                                     ! minus
   real(kind=8), dimension(3) :: center ! center of mass
   real(kind=8), dimension(3) :: e1, e2, e3 ! unit vectors of basis
   real(kind=8), dimension(3), parameter :: a = (/ 2.45d0, 2.45d0, 6.70d0 /)
                                            ! lattice constants of graphite
   real(kind=8), dimension(3) :: atom_coordinates
   real(kind=8), dimension(3,3) :: Pe ! transformation matrix for change of
                                      ! basis to cartesian coordinates
   real(kind=8), dimension(3,3) :: Peinv
   real(kind=8), dimension(4,3) :: unit_cell
   real(kind=8), dimension(3,4) :: transposed_unit_cell
   real(kind=8), allocatable, dimension(:,:) :: first_cell
   integer :: io, nlines
   character(len=12) :: read_char
   character(len=200) :: current_line

   ! Determine how many times you want to translate in each direction:
   ! (some large enough number of times)
   n1 = int( (d1/a(1))/2.0d0 + 3.0d0 )
   n2 = int( (d2/a(2))/2.0d0 + 3.0d0 )
   n3 = int( (d3/a(3))/2.0d0 + 3.0d0 )

   !------------------------------------------------------------
   ! Define the atoms of unit_cell, and redefine them so that
   ! the first cell is centered at (0,0,0) of the
   ! Cartesian coordinate system:
   !------------------------------------------------------------

   ! Independent (basis) points in graphite in hexagonal coordinates:
   unit_cell = transpose(reshape( (/ 0.0d0, 0.0d0, 0.0d0, 1.0d0/3.0d0, &
      1.0d0/3.0d0, 0.0d0, 0.0d0, 0.0d0, 0.5d0, 2.0d0/3.0d0, 2.0d0/3.0d0, &
      0.5d0 /), shape(transposed_unit_cell) ))

   ! Scale the basis points by the lattice constant:
   do i = 1, size(unit_cell,1)
      do j = 1, size(unit_cell,2)
         unit_cell(i,j) = unit_cell(i,j)*a(j)
      end do
   end do

   write(*,*) 'unit_cell:'
   do i = 1, size(unit_cell,1)
      write(*,*) (unit_cell(i,j), j = 1, size(unit_cell,2))
   end do
   write(*,*)

   ! Define hxagonal/cartesian transformations:
   e1 = (/ 1.0d0, 0.5d0, 0.0d0 /) ! x-axis
   e2 = (/ 0.0d0, sqrt(3.0d0)/2.0d0, 0.0d0 /) ! y-axis
   e3 = (/ 0.0d0, 0.0d0, 1.0d0 /) ! z-axis

   ! Hexagonal -> cartesian transformation matrix:
   do i = 1, 3
      Pe(i,1) = e1(i)
      Pe(i,2) = e2(i)
      Pe(i,3) = e3(i)
   end do

   ! Cartesian -> hexagonal transformation matrix:
   call inverse_3_3(Pe,Peinv)
   write(*,*)
   write(*,*) 'Peinv:'
   do i = 1, size(Peinv,1)
      write(*,*) (Peinv(i,j), j = 1, size(Peinv,2))
   end do
   write(*,*)

   ! Write the first cell in cartesian coordinates:
   ! so that it may be converted to cartesian coordinates,
   ! and centered at (0,0,0):
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
                  a(1)*pm(ipm)*dble(i)
               atom_coordinates(2) = unit_cell(atom,2) + &
                  a(2)*pm(jpm)*dble(j)
               atom_coordinates(3) = unit_cell(atom,3) + &
                  a(3)*pm(kpm)*dble(k)
               ! If the coordinates of this atom are 
               ! within the dimensions of the unit cell, 
               ! then write them to the first_cell output file:
               if (atom_coordinates(1) <= a(1)+0.1) then
                  if (atom_coordinates(2) <= a(2)+0.1) then
                     if (atom_coordinates(3) <= a(3)+0.1) then
                        atom_coordinates = matmul(atom_coordinates,Pe)
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
      !write(*,*) nlines
   end do
   
   rewind(8)
   allocate(first_cell(nlines,3))
   write(*,*) "first_cell: "
   do p = 1, nlines
      read(8,*) first_cell(p,1), first_cell(p,2), first_cell(p,3)
      write(*,*) (first_cell(p,q), q = 1,3)
   end do
   close(8)
   
   ! Find center of mass of unit cell:
   do i = 1,3
      center(i) = 0.0d0
      do j = 1, size(first_cell,1)
         center(i) = center(i) + first_cell(j,i)
      end do
      center(i) = center(i) / dble(size(first_cell,1))
   end do
   write(*,*)
   write(*,*) "center:", center
   write(*,*)

   ! move center of mass to (0,0,0)
   do i = 1, size(first_cell,1)
      do j = 1, 3
         first_cell(i,j) = first_cell(i,j) - center(j)
      end do
   end do

   ! Write first_cell.xyz for viewing with molden
   open (unit=9, file='first_cell_moved.xyz', status='new', action='write')
   write(9,*) size(first_cell,1) + 1
   write(9,*) 'The first cell'
   write(9,*) "O", 0.0d0, 0.0d0, 0.0d0
   do i = 1, size(first_cell,1)
      write(9,*) "C", (first_cell(i,j), j = 1,3)
   end do
   close(9)

   ! Redefine unit cell as first_cell in hexagonal coordinates:
   do i = 1, 4
      do j = 1, 3
         unit_cell(i,j) = first_cell(i,j)
      end do
   end do
   unit_cell = matmul(unit_cell, Peinv)
   deallocate(first_cell)

   write(*,*)
   write(*,*) "unit_cell:"
   do i = 1, size(unit_cell,1)
      write(*,*) (unit_cell(i,j), j = 1, size(unit_cell,2))
   end do

   ! Write the .in file:
   open (unit=2, file='graphite.in', status='new', action='write')

   write(2,*) "O", 0.0d0, 0.0d0, 0.0d0

   write(*,*)
   write(*,*) "final coordinates:"
   ! For the number of times the unit cell has to be repliicated
   ! in the 1-direction
   do i = 0,n1
      ! For the number of times the unit cell has to be repliicated
      ! in the 2-direction
      do j = 0, n2
         ! For the number of times the unit cell has to be repliicated
         ! in the 3-direction
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
                           a(1)*pm(ipm)*dble(i)
                        atom_coordinates(2) = unit_cell(atom,2) + &
                           a(2)*pm(jpm)*dble(j)
                        atom_coordinates(3) = unit_cell(atom,3) + &
                           a(3)*pm(kpm)*dble(k)
                        atom_coordinates = matmul(atom_coordinates,Pe)
                        ! If the coordinates of this atom are 
                        ! within the requested dimensions of the slab, 
                        ! then write them to the output file:
                        if (dabs(atom_coordinates(1)) <= d1/2.0d0) then
                           if (dabs(atom_coordinates(2)) <= d2/2.0d0) then
                              if (dabs(atom_coordinates(3)) <= d3/2.0d0) then
                                 if (atom <=2) then 
                                    write(2,'(A1,A4,3F15.9)') "N", "    ",&
                                       (atom_coordinates(coordinate), &
                                       coordinate = 1, 3)
                                 else if (atom > 2) then
                                    write(2,'(A1,A4,3F15.9)') "C", "    ",&
                                       (atom_coordinates(coordinate), &
                                       coordinate = 1, 3)
                                 end if
                                 write(*,*) i, j, k, (atom_coordinates(l), l = 1, 3)
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
   open (unit=3, file='graphite.in', status='old', action='read')

   ! count the number of lines in particle.in:
   nlines = 0
   do
      read(3,*,iostat=io) read_char
      if (io/=0) exit
      nlines = nlines + 1
   end do

   rewind(3)

   open (unit=4, file='graphite.xyz', status='new', action='write')

   write(4,*) nlines
   write(4,*) 'kflklv'
   do i = 1, nlines
      read(3,'(A100)') current_line
      write(4,*) trim(current_line)
   end do

   close(3)
   close(4)

end program gen_graphite
