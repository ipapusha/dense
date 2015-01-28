CC=gcc
TARGET=dense
OBJS=sample.o
CFLAGS=-Wall -pedantic -std=c99
#CFLAGS+=-O3 -DNDEBUG=1
CFLAGS+=-g
CFLAGS+=-I../include
LDFLAGS=-L../lib
LIBS=-lcxsparse

all: $(TARGET)

$(TARGET): $(OBJS)
	#$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $^ -o $@ $(LIBS)
	$(CC) $(LDFLAGS) $^ -o $@ $(LIBS)

.PHONY: clean
clean:
	$(RM) $(OBJS) 
	$(RM) $(TARGET)
	$(RM) lex.yy.c a.out
	$(RM) sample.mat
