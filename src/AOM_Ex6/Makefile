FC=gfortran
FFLAGS=-g -O3 

run: main.o sub.o param.o io.o random.o
	$(FC) $(FFLAGS) -o run main.o sub.o param.o io.o random.o -L$(CONDA_PREFIX)/lib -lnetcdff

main.o: main.f95 param.o sub.o io.o random.o
	$(FC) $(FFLAGS) -c main.f95

sub.o: sub.f95 random.o
	$(FC) $(FFLAGS) -c sub.f95

random.o: random.f95
	$(FC) $(FFLAGS) -c random.f95

param.o: param.f95
	$(FC) $(FFLAGS) -c param.f95

io.o: io.f95 param.o
	$(FC) $(FFLAGS) -c io.f95 -I $(CONDA_PREFIX)/include

BathCreator: BathCreator.f95
	$(FC) $(FFLAGS) -o BathCreator BathCreator.f95

.PHONY: clean
clean:
	rm *.o
	rm *.mod
