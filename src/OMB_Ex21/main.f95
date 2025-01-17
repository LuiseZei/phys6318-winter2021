PROGRAM multi

!*****************************************!
!* 2d multi-layer shallow-Water model    *!
!*                                       *!
!* including:                            *!
!* - wind-stress forcing                 *!
!* - semi-implicit bottom friction       *!
!* - nonlinear terms                     *!
!* - horizontal pressure-gradient force  *!
!* - Coriolis force (beta plane)         *!
!* - Lateral momentum diffusion/friction *!
!* - flooding algorithm                  *!
!* - TDV advection scheme                  *!
!* - Eulerian tracer prediction          *!
!*                                       *!
!* Author: J. Kaempf, 2008               *!
!*****************************************!

    USE param
    USE sub
    USE random
    USE io

! local parameters
    REAL :: etN, etS
    INTEGER :: n, ntot, nout, noutra
    CHARACTER(len=50) :: outfile

!**********
    CALL INIT  ! initialisation
!**********

! runtime parameters
    ntot = INT(20.*24.*3600./dt)

! output parameter
    nout = INT(6.*3600./dt)

! initial tracer distribution
    DO i = 1, nz
    DO j = 0, ny + 1
    DO k = 0, nx + 1
        T(i, j, k) = 0.
        TN(i, j, k) = 0.
    END DO
    END DO
    END DO

    DO i = 1, nz
    DO j = 26, ny
    DO k = 0, nx + 1
        T(i, j, k) = 1.
        TN(i, j, k) = 1.
    END DO
    END DO
    END DO

! initial surface pressure field
    DO k = 0, nx + 1
        DO j = 26 - 5, 26 + 5
            eta(1, j, k) = -0.05*(SIN(REAL(j - 26)*0.5*PI/5.))
        END DO
        DO j = 0, 20
            eta(1, j, k) = +0.05
        END DO
        DO j = 32, ny + 1
            eta(1, j, k) = -0.05
        END DO
    END DO

! initial structure of density interface
    DO k = 0, nx + 1
    DO j = 0, ny + 1
        eta(2, j, k) = -eta(1, j, k)*rho(2)/(rho(2) - rho(1))
    END DO
    END DO

! initial layer configuration
    DO j = 0, ny + 1
    DO k = 0, nx + 1
    DO i = 1, nz
        h(i, j, k) = hzero(i, j, k) + eta(i, j, k) - eta(i + 1, j, k) - eta0(i, j, k) + eta0(i + 1, j, k)
        wet(i, j, k) = 1
        if (h(i, j, k) < hmin) wet(i, j, k) = 0
    END DO
    END DO
    END DO

! initial geostrophic flow field in upper layer
    DO j = 1, ny
    DO k = 1, nx
        etN = 0.5*(eta(1, j + 1, k) + eta(1, j + 1, k + 1))
        etS = 0.5*(eta(1, j - 1, k) + eta(1, j - 1, k + 1))
        u(1, j, k) = -0.5*g*(etN - etS)/dy/f(1)
    END DO
    END DO

    DO j = 1, ny
        u(1, j, 0) = u(1, j, 1)
        u(1, j, nx + 1) = u(1, j, nx)
    END DO

! add small random perturbations to surface pressure field
    ist = -1
    randm = ran3(ist)

    DO j = 0, ny + 1
    DO k = 0, nx + 1
        eta(1, j, k) = eta(1, j, k) + 0.005*ran3(ist)
    END DO
    END DO

    ! create output file
    outfile = "output.nc"
    CALL create_nc(outfile)

    ! write out initial conditions
    CALL write_nc(outfile, 0.)

! output parameter
    noutra = INT(1.*3600./dt)

!---------------------------
! simulation loop
!---------------------------

    DO n = 1, ntot

        time = REAL(n)*dt
        write (6, *) "time (hours)", time/(3600.)
        ad = 0.0 ! adjustment not used in this exercise

! call prognostic equations
        CALL dyn

! data output
        IF (MOD(n, nout) == 0) THEN
            CALL write_nc(outfile, time)

            WRITE (6, *) "Data output at time = ", time/(24.*3600.)
        END IF

    END DO ! end of iteration loop

END PROGRAM multi
