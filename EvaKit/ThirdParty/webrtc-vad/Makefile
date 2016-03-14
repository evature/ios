TARGET = test
LIBS = -lm -lpthread
CC = gcc
CXX = g++
CFLAGS = -g -O0 -Wall -DWEBRTC_POSIX

.PHONY: default all clean

default: $(TARGET)
all: default

CSOURCES = $(shell find . -type f -name '*.c' | grep -v _mips) 
HEADERS = $(shell find ../src -type f -name '*.h')
OBJECTS = $(patsubst %.c, %.o, $(CSOURCES))

%.o: %.c $(HEADERS)
	$(CC) -I. -Iwebrtc $(CFLAGS) -c $< -o $@

.PRECIOUS: $(TARGET) $(OBJECTS)
    
$(TARGET): $(OBJECTS)
	$(CXX) $(OBJECTS) -Wall $(LIBS) -o $@
        
clean:
	-rm -f $(OBJECTS)
	-rm -f $(TARGET)
