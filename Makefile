DMD=dmd
DMDFLAGS=-w -debug -gc -unittest 
LNFLAGS=-L-lreadline
INCS=-Isrc/

SRC=$(wildcard src/ruse/*.d)
OBJ=$(SRC:.d=.o)
EXE=ruse

.SUFFIXES: .d .o

all: $(OBJ)
	@echo "Linking"
	@$(DMD) $(OBJ) $(INCS) $(LNFLAGS) $(DMDFLAGS) -of$(EXE)

src/ruse/bindings.o: src/ruse/bindings.d src/ruse/types.o
src/ruse/globals.o: src/ruse/globals.d src/ruse/bindings.o src/ruse/types.o
src/ruse/main.o: src/ruse/main.d src/ruse/types.o src/ruse/reader.o \
src/ruse/readline.d
src/ruse/reader.o: src/ruse/reader.d src/ruse/types.o
src/ruse/readline.o: src/ruse/readline.d
src/ruse/types.o: src/ruse/types.d

.d.o:
	@echo "   dmd $<"
	@$(DMD) -c $(INCS) $< -of$@

#####

todo:
	@grep -rInso "TODO: \([^*]\+\)" src/

clean:
	rm -f $(EXE) $(OBJ) 

rebuild: clean all

loc:
	@find src -type f -name "*.d" | xargs wc -l
		
.PHONY=clean loc rebuild todo
