# $@ is the filename representing the target.
# $< is the filename of the first prerequisite.
# $^ the filenames of all the prerequisites.
# $(@D) is the file path of the target file. 
# D can be added to all of the above.

CXX = g++
CXX_FLAGS= -std=c++11 -O3

UNAME := $(shell uname)

ifeq ($(UNAME), Linux)
LIBS = -L ~/SLlibs/petsc/arch-linux-c-opt/lib -l openblas -l petsc -L ~/SLlibs/slepc/arch-linux-c-opt/lib -l slepc
INCL = -I ~/SLlibs/petsc/include/petsc/mpiuni -I ~/SLlibs/petsc/arch-linux-c-opt/externalpackages/git.openblas -I ~/SLlibs/petsc/include/ -I ~/SLlibs/petsc/arch-linux-c-opt/include/ -I ~/SLlibs/slepc/include -I ~/SLlibs/slepc/arch-linux-c-opt/include
endif
ifeq ($(UNAME), Darwin)
LIBS = -L ~/SLlibs/petsc/arch-darwin-c-opt/lib -l openblas -l petsc -L ~/SLlibs/slepc/arch-darwin-c-opt/lib -l slepc
INCL = -I ~/SLlibs/petsc/include/petsc/mpiuni -I ~/SLlibs/petsc/arch-darwin-c-opt/externalpackages/git.openblas -I ~/SLlibs/petsc/include/ -I ~/SLlibs/petsc/arch-darwin-c-opt/include/ -I ~/SLlibs/slepc/include -I ~/SLlibs/slepc/arch-darwin-c-opt/include
endif


# List of all libraries to use:
#LIBS= -L /home/halbux/openblas/lib -l openblas -L /home/halbux/petsc/arch-linux-c-debug/lib -l petsc -l mpi -l mpifort -l fftw3 -lm  -fopenmp #############" -lm useless?
# List of all directories containing the headers:
INCLUDES= -I ./ -I src -I src/field -I src/expression -I src/expression/operation -I src/shapefunction -I src/formulation -I src/shapefunction/hierarchical -I src/shapefunction/hierarchical/h1 -I src/shapefunction/hierarchical/hcurl -I src/shapefunction/hierarchical/meca -I src/gausspoint -I src/shapefunction/lagrange -I src/mesh -I src/mesh/gmsh     -I /home/halbux/petsc/include/ -I /home/halbux/petsc/arch-linux-c-debug/include/
# List of all .cpp source files:
CPPS= $(wildcard *.cpp) $(wildcard src/*.cpp) $(wildcard src/field/*.cpp) $(wildcard src/expression/*.cpp) $(wildcard src/expression/operation/*.cpp) $(wildcard src/shapefunction/*.cpp) $(wildcard src/formulation/*.cpp) $(wildcard src/shapefunction/hierarchical/*.cpp) $(wildcard src/shapefunction/hierarchical/h1/*.cpp) $(wildcard src/shapefunction/hierarchical/meca/*.cpp) $(wildcard src/shapefunction/hierarchical/hcurl/*.cpp) $(wildcard src/gausspoint/*.cpp) $(wildcard src/shapefunction/lagrange/*.cpp) $(wildcard src/mesh/*.cpp) $(wildcard src/mesh/gmsh/*.cpp)
# Final binary name:
BIN = sparselizard
# Put all generated stuff to this build directory:
BUILD_DIR = ./build


# Same list as CPP but with the .o object extension:
OBJECTS=$(CPPS:%.cpp=$(BUILD_DIR)/%.o)
# Gcc/Clang will create these .d files containing dependencies.
DEP = $(OBJECTS:%.o=%.d)

all: $(BIN)

$(BIN): $(OBJECTS)
	# Linking objects:
	$(CXX) $(OBJECTS) $(LIBS) -o $@
	
# Include all .d files
-include $(DEP)

$(BUILD_DIR)/%.o: %.cpp
	# Create the folder of the current target in the build directory:
	mkdir -p $(@D)
	# Compile .cpp file. MMD creates the dependencies.
	$(CXX) $(CXX_FLAGS) $(LIBS) $(INCLUDES) $(INCL) -MMD -c $< -o $@
	

clean :
    # Removes all files created.
	rm -rf $(BUILD_DIR)
	rm -f $(BIN)
