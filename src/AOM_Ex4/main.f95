!==================================
! Exercise 4: Density-driven flows
!==================================
! Author: J. Kaempf, August 2009

PROGRAM slice

    USE param
    USE sub
    USE io

! local parameters
    INTEGER :: n, ntot, nout
    REAL :: wl, ps
    CHARACTER(LEN=50) :: outfile

!**********
    CALL INIT  ! initialisation
!**********

! runtime parameters
    ntot = INT(3000./dt)
    time = 0.0

! output frequency
    nout = INT(30./dt)

    ! create output file
    outfile = 'output.nc'
    CALL create_nc(outfile)

    ! write out initial conditions
    CALL write_nc(outfile, 0.)

! prescribe plume layer with increased density
    DO i = 26, nz + 1
    DO k = 0, 20
        rho(i, k) = RHOREF + 0.5
    END DO
    END DO

!---------------------------
! simulation loop
!---------------------------
    DO n = 1, ntot

        time = REAL(n)*dt
        !write (6, *) "time (hours)", time/(3600.)

! prognostic equations
        CALL dyn

! data output
        IF (MOD(n, nout) == 0) THEN
            CALL write_nc(outfile, time)
            WRITE (6, *) "Data output at time (minutes)= ", time/(60.)

        END IF

    END DO ! end of iteration loop

END PROGRAM slice
