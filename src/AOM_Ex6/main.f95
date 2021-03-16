!==========================================
! Exercise 6: Kelvin-Helmholtz instability
!==========================================
! Author: J. Kaempf, August 2009

PROGRAM slice

    USE param
    USE sub
    USE io

! local parameters
    INTEGER :: ntot, nout
    REAL :: wl, ps
    CHARACTER(LEN=50) :: outfile

!**********
    CALL INIT  ! initialisation
!**********

! runtime parameters
    ntot = INT(100.*60./dt)
    time = 0.0

! output frequency
    nout = INT(30./dt)

    ! create output file
    outfile = 'output.nc'
    CALL create_nc(outfile)

    ! write out initial conditions
    CALL write_nc(outfile, 0.)
!---------------------------
! simulation loop
!---------------------------
    DO n = 1, ntot

        time = REAL(n)*dt
!write(6,*)"time (hours)", time/(3600.)

! prognostic equations
        CALL dyn

! data output (start after 20 minutes)
        IF (n > ntot/5) then
        IF (MOD(n, nout) == 0) THEN
            CALL write_nc(outfile, time)

            WRITE (6, *) "Data output at time (minutes) = ", time/(60.)
        END IF
        END IF

    END DO ! end of iteration loop

END PROGRAM slice
