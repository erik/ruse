DMD=dmd
DMDFLAGS=-w -debug -gc -unittest 
LNFLAGS=
INCS=-Isrc/

SRC=$(wildcard src/ruse/*.d)
OBJ=$(SRC:.d=.o)
EXE=ruse

.SUFFIXES: .d .o

all: $(OBJ)
	@echo "Linking"
	@$(DMD) $(OBJ) $(INCS) $(LNFLAGS) $(DMDFLAGS) -of$(EXE)

src/ruse/bindings.o: src/ruse/bindings.d src/ruse/types.o
src/ruse/main.o: src/ruse/main.d src/ruse/types.o
src/ruse/reader.o: src/ruse/reader.d
# Circular dependency to bindings.o
src/ruse/types.o: src/ruse/types.d

.d.o:
	@echo "   dmd $<"
	@$(DMD) -c $(INCS) $< -of$@

#####

clean:
	rm -f $(EXE) $(OBJ) 

rebuild: clean all

loc:
	@find src -type f -name "*.d" | xargs wc -l
		
.PHONY=clean loc rebuild
