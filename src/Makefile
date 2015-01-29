CC=gcc
TARGET=dense
OBJS=sample.o
CFLAGS=-Wall -pedantic -std=c99
#CFLAGS+=-O3 -DNDEBUG=1
CFLAGS+=-g
CFLAGS+=-I../include
LDFLAGS=-L../lib
LIBS=-lcxsparse

default: parse.tab.h
all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) $^ -o $@ $(LIBS)


parse.tab.c: parse.y parse.h
	bison -d parse.y
parse.tab.h: parse.tab.c
	@

.PHONY: clean
clean:
	$(RM) $(OBJS) 
	$(RM) $(TARGET)
	$(RM) parse.tab.c parse.tab.h
