MODULE param

    INTEGER, PARAMETER :: nx = 201
    INTEGER, PARAMETER :: ny = 51
    REAL, PARAMETER :: PI = 3.1415

    REAL :: hzero(0:ny + 1, 0:nx + 1), h(0:ny + 1, 0:nx + 1)
    REAL :: eta(0:ny + 1, 0:nx + 1), etan(0:ny + 1, 0:nx + 1)
    REAL :: u(0:ny + 1, 0:nx + 1), un(0:ny + 1, 0:nx + 1)
    REAL :: v(0:ny + 1, 0:nx + 1), vn(0:ny + 1, 0:nx + 1)
    REAL :: x_eta(nx), y_eta(ny)
    REAL :: dt, dx, dy, g
    REAL :: eps ! parameter for Shapiro filter

    INTEGER :: j, k, nxb

    INTEGER :: wet(0:ny + 1, 0:nx + 1)
    REAL :: hmin

END MODULE param
