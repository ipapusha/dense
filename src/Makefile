CC=gcc
TARGET=dense
OBJS=parse_funcs.o parse.tab.o lexer.yy.o astutils.o main.o
CFLAGS=-Wall -Wextra -pedantic -std=c11 -D_XOPEN_SOURCE=700
#CFLAGS+=-O3 -DNDEBUG=1
CFLAGS+=-g
CFLAGS+=-I../include
LDFLAGS=-L../lib
LIBS=-lcxsparse

all: $(TARGET)
obj: $(OBJS)

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) $^ -o $@ $(LIBS)

# bison parser and grammar
parse.tab.o: parse.tab.c parse.tab.h
parse.tab.c: parse.y parse.h
	bison -d parse.y
parse.tab.h: parse.tab.c
	@

# lexer
lexer.yy.c: lexer.l parse.h parse.tab.h
	flex --header-file=lexer.yy.h -o lexer.yy.c lexer.l

astutils.o: astutils.c astutils.h parse.h

.PHONY: clean
clean:
	$(RM) $(OBJS) 
	$(RM) $(TARGET)
	$(RM) parse.tab.c parse.tab.h
	$(RM) lexer.yy.c lexer.yy.h
