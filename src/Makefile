CC=gcc
TARGET=dense
OBJS=parse_funcs.o parse.tab.o lexer.yy.o
CFLAGS=-Wall -pedantic -std=c1x
#CFLAGS+=-O3 -DNDEBUG=1
CFLAGS+=-g
CFLAGS+=-I../include
LDFLAGS=-L../lib
LIBS=-lcxsparse

default: $(OBJS)
all: $(TARGET)

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
	#flex --header-file=lexer.yy.h -o lexer.yy.c lexer.l
	flex -o lexer.yy.c lexer.l


#calc: calc.l calc.y calc.h calc_main.c
    #bison -d calc.y
    #flex -o calc.yy.c calc.l
    #cc -o calc calc.tab.c calc.yy.c calc_main.c -lm

.PHONY: clean
clean:
	$(RM) $(OBJS) 
	$(RM) $(TARGET)
	$(RM) parse.tab.c parse.tab.h
	$(RM) lexer.yy.c
