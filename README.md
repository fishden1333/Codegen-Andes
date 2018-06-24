# Codegen-Andes
For NTHU - Compiler Design (2018 Spring). This program is written with lex and yacc, and it can generate assembly code for Andes ISA.

### Usage:

Use your terminal / console and type the following:

- make: Compile 'scanner.l' with flex and 'parser.l' with byacc, and then compile them with gcc and output 'codegen'.
When parsing a c program, it will generate an assembly code 'assembly'.
- make clean: Delete 'codegen' and other files created when compiling.
