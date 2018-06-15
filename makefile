# Usage:
# make: Compile a lex file, scanner.l, with flex, output 'lex.yy.c'.
#       Compile a yacc file, parser.y, with byacc, output 'y.tab.c' and 'y.tab.h'.
#       Then compile them with gcc, and output an executable file, codegen.
# make clean: Remove lex.yy.c, y.tab.c, y.tab.h and codegen.

all:
	flex scanner.l
	byacc -d -v parser.y
	gcc -o codegen lex.yy.c y.tab.c sym_table.c

clean:
	rm -f lex.yy.c y.tab.c y.tab.h parser y.output
