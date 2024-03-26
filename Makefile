I2C_MODE = LINUX
I2C_LIBS = 
SRC_DIR = 
BUILD_DIR = 
LIB_DIR = $(SRC_DIR)../mlx90640-library/

examples = sdlmerge
examples_objects = $(addsuffix .o,$(addprefix $(SRC_DIR), $(examples)))
examples_output = $(addprefix $(BUILD_DIR), $(examples))

#debugging enabled by default
CXXFLAGS+=-DDEBUG -g

#PREFIX is environment variable, but if it is not set, then set default value
ifeq ($(PREFIX),)
	PREFIX = /usr/local
endif

ifeq ($(I2C_MODE), LINUX)
	I2C_LIBS =
endif

ifeq ($(I2C_MODE), RPI)
	I2C_LIBS = -lbcm2835
endif

all: examples

examples: $(examples_output)


# -Wno-deprecated-declarations fixes deprecation warnings affecting LibAV v4.0+ in video.cpp
# -Wno-format-extra-args ignores the ANSI colour formatting in test.cpp
$(examples_objects) : CXXFLAGS+=-std=c++11 -Wall -Werror -Wno-format-extra-args -Wno-deprecated-declarations

$(examples_output) : CXXFLAGS+=-I. -std=c++11

examples/src/lib/interpolate.o : CC=$(CXX) -std=c++11

examples/src/sdlscale.o : CXXFLAGS+=`sdl2-config --cflags --libs`

examples/src/sdlmerge.o : CXXFLAGS+=`sdl2-config --cflags --libs`

$(BUILD_DIR)sdlscale: $(SRC_DIR)sdlscale.o libMLX90640_API.a
	$(CXX) -L/home/pi/mlx90640-library $^ -o $@ $(I2C_LIBS) `sdl2-config --libs` -lSDL2_image

$(BUILD_DIR)sdlmerge: $(SRC_DIR)sdlmerge.o $(LIB_DIR)libMLX90640_API.a
	$(CXX) -L/home/pi/mlx90640-library $^ -o $@ $(I2C_LIBS) `sdl2-config --libs` -lSDL2_image

clean:
	rm -f $(examples_output)
	rm -f $(SRC_DIR)*.o
	rm -f $(LIB_DIR)*.o
	rm -f functions/*.o
	rm -f *.o
	rm -f *.so
	rm -f *.a

install: libMLX90640_API.a libMLX90640_API.so
	install -d $(DESTDIR)$(PREFIX)/lib/
	install -m 644 libMLX90640_API.a $(DESTDIR)$(PREFIX)/lib/
	install -m 644 libMLX90640_API.so $(DESTDIR)$(PREFIX)/lib/
	install -d $(DESTDIR)$(PREFIX)/include/MLX90640/
	install -m 644 headers/*.h $(DESTDIR)$(PREFIX)/include/MLX90640/
	ldconfig
