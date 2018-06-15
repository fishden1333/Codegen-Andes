# Usage:
# make: Compile a lex file, scanner.l, with flex, output 'lex.yy.c'.
#       Compile a yacc file, parser.y, with byacc, output 'y.tab.c' and 'y.tab.h'.
#       Then compile them with gcc, and output an executable file, codegen.
#       If run the program, it will output an assembly code 'assembly'.
# make clean: Remove lex.yy.c, y.tab.c, y.tab.h, codegen and assembly.

all:
	flex scanner.l
	byacc -d -v parser.y
	gcc -o codegen lex.yy.c y.tab.c sym_table.c

clean:
	rm -f lex.yy.c y.tab.c y.tab.h codegen y.output assembly
