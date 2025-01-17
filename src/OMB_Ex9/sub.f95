MODULE sub
    USE param

CONTAINS

!=======================
    SUBROUTINE init

        hmin = 0.05

! grid parameters
        dx = 10.0
        dy = 10.0
        dt = 0.2

        DO k = 1, nx
            x_eta(k) = dx/4.+REAL(k)*dx
        END DO

        DO j = 1, ny
            y_eta(j) = dy/4.+REAL(j)*dy
        END DO

! physical parameters
        g = 9.81

! Load bathymetry data

        OPEN (10, file='topo.dat', form='formatted')
        DO j = 0, ny + 1
            READ (10, '(203F12.6)') (hzero(j, k), k=0, nx + 1)
        END DO
        CLOSE (10)

        DO j = 0, ny + 1
        DO k = 0, nx + 1
            eta(j, k) = -MIN(0.0, hzero(j, k))
            etan(j, k) = eta(j, k)
        END DO
        END DO
!XXXXXXXXXXXXXXXXXXX

        DO j = 0, ny + 1
        DO k = 0, nx + 1
            h(j, k) = hzero(j, k) + eta(j, k)
! wet = 1 defines "wet" grid cells
! wet = 0 defines "dry" grid cells
            wet(j, k) = 1
            if (h(j, k) < hmin) wet(j, k) = 0
            u(j, k) = 0.
            un(j, k) = 0.
            v(j, k) = 0.
            vn(j, k) = 0.
        END DO
        END DO

    END SUBROUTINE init

!================
    SUBROUTINE dyn

! local parameters
        REAL :: du(0:ny + 1, 0:nx + 1), dv(0:ny + 1, 0:nx + 1)
        REAL :: uu, vv, duu, dvv
        REAL :: hue, huw, hwp, hwn, hen, hep
        REAL :: hvn, hvs, hsp, hsn, hnn, hnp

        DO j = 1, ny
        DO k = 1, nx
            du(j, k) = -dt*g*(eta(j, k + 1) - eta(j, k))/dx
            dv(j, k) = -dt*g*(eta(j + 1, k) - eta(j, k))/dy
        END DO
        END DO

        DO k = 1, nx
            dv(0, k) = -dt*g*(eta(1, k) - eta(0, k))/dy
        END DO

        DO j = 1, ny
        DO k = 1, nx

! prediction for u
            un(j, k) = 0.0
            uu = u(j, k)
            duu = du(j, k)
            IF (wet(j, k) == 1) THEN
                IF ((wet(j, k + 1) == 1) .or. (duu > 0.0)) un(j, k) = uu + duu
            ELSE
                IF ((wet(j, k + 1) == 1) .and. (duu < 0.0)) un(j, k) = uu + duu
            END IF

        END DO
        END DO

        DO j = 0, ny
        DO k = 1, nx

! prediction for v
            vv = v(j, k)
            dvv = dv(j, k)
            vn(j, k) = 0.0

            IF (wet(j, k) == 1) THEN
                IF ((wet(j + 1, k) == 1) .or. (dvv > 0.0)) vn(j, k) = vv + dvv
            ELSE
                IF ((wet(j + 1, k) == 1) .and. (dvv < 0.0)) vn(j, k) = vv + dvv
            END IF

        END DO
        END DO

! zero-gradient conditions for northern and southern coast

!DO k = 0,nx+1
!un(0,k) = un(1,k) !-un(2,k)
!vn(0,k) = vn(1,k) !-vn(2,k)
!un(ny+1,k) = un(ny,k) !-un(ny-1,k)
!vn(ny+1,k) = vn(ny,k) !-vn(ny-1,k)
!END DO

        DO j = 0, ny + 1
            un(j, 0) = un(j, 1)
            vn(j, 0) = vn(j, 1)
        END DO

! sea level predictor
        DO j = 1, ny
        DO k = 1, nx
            hep = 0.5*(un(j, k) + abs(un(j, k)))*h(j, k)
            hen = 0.5*(un(j, k) - abs(un(j, k)))*h(j, k + 1)
            hue = hep + hen
            hwp = 0.5*(un(j, k - 1) + abs(un(j, k - 1)))*h(j, k - 1)
            hwn = 0.5*(un(j, k - 1) - abs(un(j, k - 1)))*h(j, k)
            huw = hwp + hwn

            hnp = 0.5*(vn(j, k) + abs(vn(j, k)))*h(j, k)
            hnn = 0.5*(vn(j, k) - abs(vn(j, k)))*h(j + 1, k)
            hvn = hnp + hnn
            hsp = 0.5*(vn(j - 1, k) + abs(vn(j - 1, k)))*h(j - 1, k)
            hsn = 0.5*(vn(j - 1, k) - abs(vn(j - 1, k)))*h(j, k)
            hvs = hsp + hsn
            etan(j, k) = eta(j, k) - dt*(hue - huw)/dx - dt*(hvn - hvs)/dy
        END DO
        END DO

! zero-gradient conditions for northern and southern coast

        DO k = 0, nx + 1
            etan(0, k) = 2.*etan(1, k) - etan(2, k)
            etan(ny + 1, k) = 2.*etan(ny, k) - etan(ny - 1, k)
        END DO

        DO j = 0, ny + 1
            etan(j, 0) = etan(j, 1)
        END DO

    END SUBROUTINE dyn

!======================
    SUBROUTINE shapiro

!local parameters
        REAL :: term1, term2, term3

! 1-order Shapiro filter

        DO j = 1, ny
        DO k = 1, nx

            IF (wet(j, k) == 1) THEN
                term1 = (1.0 - 0.25*eps*(wet(j, k + 1) + wet(j, k - 1) + wet(j + 1, k) + wet(j - 1, k)))*etan(j, k)
                term2 = 0.25*eps*(wet(j, k + 1)*etan(j, k + 1) + wet(j, k - 1)*etan(j, k - 1))
                term3 = 0.25*eps*(wet(j + 1, k)*etan(j + 1, k) + wet(j - 1, k)*etan(j - 1, k))
                eta(j, k) = term1 + term2 + term3
            ELSE
                eta(j, k) = etan(j, k)
            END IF

        END DO
        END DO

        DO k = 0, nx + 1
            eta(0, k) = 2.*eta(1, k) - eta(2, k)
            eta(ny + 1, k) = 2.*eta(ny, k) - eta(ny - 1, k)
        END DO

    END SUBROUTINE shapiro

END MODULE sub
