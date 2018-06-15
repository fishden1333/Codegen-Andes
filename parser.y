/* After makefile, type the following line in terminal to execute the codegen: */
/* ./codegen << <input file name> >> <output file name> */

%{
  #include <stdio.h>
  #include <string.h>
  #include <stdlib.h>
  #include "sym_table.h"

  extern char *yytext; // The scanned token
  extern char line[1000];
  extern int numLines;

  FILE *f_asm; // File used for generating assembly code
%}

%start program /* Starting symbol */

/* All types */
%union {
         int intVal;
         double doubVal;
         char charVal;
         char *strVal;
       }

%token INT_CONSTANT DOUB_CONSTANT CHAR_CONSTANT BOOL_CONSTANT STR_CONSTANT
%token NONVOIDTYPE VOIDTYPE ID
%token RETURN CONST IF ELSE SWITCH CASE DEFAULT WHILE DO FOR BREAK CONTINUE
%token COMMENT_START COMMENT_SINGLE COMMENT_END PRAGMA

%type <strVal> ID

/* Precedence and associativity */
%left <charVal> ';'
%left NONVOIDTYPE VOIDTYPE
%left <charVal> ','
%right <charVal> '='
%left <charVal> OROR
%left <charVal> ANDAND
%right <charVal> '!'
%left <charVal> ARITHCOMPARE
%left <charVal> '+' '-'
%left <charVal> '*' '/' '%'
%left <charVal> PLUSPLUS MINUSMINUS

%%
/* A program at least has a function definition */
program:
    external func_definition
  | func_definition
  ;

external:
    external var_declaration
  | external func_declaration
  | external func_definition
  | var_declaration
  | func_declaration
  | func_definition
  ;

/* Global variable declaration */

var_declaration:
    scalar_declaration
  | array_declaration
  | const_declaration
  | COMMENT
  | PRAGMA
  ;

scalar_declaration:
    NONVOIDTYPE ID_declarations ';'
  ;

array_declaration:
    NONVOIDTYPE IDarr_declarations ';'
  ;

func_declaration:
    NONVOIDTYPE IDfunc_declarations ';'
  | VOIDTYPE IDfunc_declarations ';'
  ;

const_declaration:
    CONST NONVOIDTYPE IDconst_declarations ';'
  ;

ID_declarations:
    ID_declarations ',' ID_declaration
  | ID_declaration
  ;

ID_declaration:
    ID
  | ID '=' expression
  ;

IDarr_declarations:
    IDarr_declarations ',' IDarr_declaration
  | IDarr_declaration
  ;

IDarr_declaration:
    ID dcl_dimensions
  | ID dcl_dimensions '=' arr_content
  ;

dcl_dimensions:
    dcl_dimensions dcl_dimension
  | dcl_dimension
  ;

dcl_dimension:
    '[' INT_CONSTANT ']'
  ;

arr_content:
    '{' arr_expressions '}'
  | '{''}'
  ;

IDfunc_declarations:
    IDfunc_declarations ',' IDfunc_declaration
  | IDfunc_declaration
  ;

IDfunc_declaration:
    ID '(' parameters ')'
  | ID '('')'
  ;

parameters:
    parameters ',' parameter
  | parameter
  ;

parameter:
    NONVOIDTYPE ID
  | NONVOIDTYPE ID dcl_dimensions
  ;

IDconst_declarations:
    IDconst_declarations ',' IDconst_declaration
  | IDconst_declaration
  ;

IDconst_declaration:
    ID '=' CONSTANT
  ;

/* Constant */

CONSTANT:
    INT_CONSTANT
  | DOUB_CONSTANT
  | CHAR_CONSTANT
  | BOOL_CONSTANT
  | STR_CONSTANT
  ;

/* Function definition */

func_definition:
    NONVOIDTYPE ID '(' parameters ')' '{' func_contents '}'
  | NONVOIDTYPE ID '(' ')' '{' func_contents '}'
  | NONVOIDTYPE ID '(' parameters ')' '{' '}'
  | NONVOIDTYPE ID '(' ')' '{' '}'
  | VOIDTYPE ID '(' parameters ')' '{' func_contents '}'
  | VOIDTYPE ID '(' ')' '{' func_contents '}'
  | VOIDTYPE ID '(' parameters ')' '{' '}'
  | VOIDTYPE ID '(' ')' '{' '}'
  ;

func_contents:
    var_declarations func_statements
  | var_declarations
  | func_statements
  ;

var_declarations:
    var_declarations var_declaration
  | var_declaration
  ;

/* Valid statements in functions */

func_statements:
    func_statements func_statement
  | func_statement
  ;

func_statement:
    simple_statement
  | func_invocation
  | if_statement else_statement
  | if_statement
  | switch_statement
  | while_statement
  | do_while_statement
  | for_statement
  | return_statement
  | break_statement
  | continue_statement
  | func_statement COMMENT
  | func_statement PRAGMA
  ;

simple_statement:
    ID '=' expression ';'
  | ID stm_dimensions '=' expression ';'
  ;

stm_dimensions:
    stm_dimensions stm_dimension
  | stm_dimension
  ;

stm_dimension:
    '[' expression ']'
  ;

func_invocation:
    ID '(' expressions ')' ';'
  | ID '(' ')' ';'

if_statement:
    IF '(' expression ')' '{' func_contents '}'
  | IF '(' expression ')' '{' '}'
  ;

else_statement:
    ELSE '{' func_contents '}'
  | ELSE '(' expression ')' '{' '}'
  ;

switch_statement:
    SWITCH '(' ID ')' '{' case_statements default_statement '}'
  | SWITCH '(' ID ')' '{' case_statements '}'
  ;

case_statements:
    case_statements case_statement
  | case_statement
  ;

case_statement:
    CASE INT_CONSTANT ':' func_statements
  | CASE INT_CONSTANT ':'
  | CASE CHAR_CONSTANT ':' func_statements
  | CASE CHAR_CONSTANT ':'
  ;

default_statement:
    DEFAULT ':' func_statements
  | DEFAULT ':'
  ;

while_statement:
    WHILE '(' expression ')' '{' func_contents '}'
  | WHILE '(' expression ')' '{' '}'
  ;

do_while_statement:
    DO '{' func_contents '}' WHILE '(' expression ')' ';'
  | DO '{' '}' WHILE '(' expression ')' ';'
  ;

for_statement:
    FOR '(' expression ';' expression ';' expression ')' '{' func_contents '}'
  | FOR '(' expression ';' expression ';' expression ')' '{' '}'
  | FOR '(' ';' expression ';' expression ')' '{' func_contents '}'
  | FOR '(' ';' expression ';' expression ')' '{' '}'
  | FOR '(' expression ';' ';' expression ')' '{' func_contents '}'
  | FOR '(' expression ';' ';' expression ')' '{' '}'
  | FOR '(' expression ';' expression ';' ')' '{' func_contents '}'
  | FOR '(' expression ';' expression ';' ')' '{' '}'
  ;

return_statement:
    RETURN expression ';'
  | RETURN ';'
  ;

break_statement:
    BREAK ';'
  ;

continue_statement:
    CONTINUE ';'
  ;

/* Expressions */

expressions:
    expressions ',' expression
  | expression
  ;

expression:
    CONSTANT
  | '-' CONSTANT
  | ID
  | '-' ID
  | ID stm_dimensions
  | ID '(' expressions ')'
  | ID '(' ')'
  | expression '=' expression
  | expression '+' expression
  | expression '-' expression
  | expression '*' expression
  | expression '/' expression
  | expression '%' expression
  | expression ARITHCOMPARE expression
  | '!' expression
  | expression ANDAND expression
  | expression OROR expression
  | expression PLUSPLUS
  | expression MINUSMINUS
  | '(' expression ')'
  ;

/* Expression without function invocation */

arr_expressions:
    arr_expressions ',' arr_expression
  | arr_expression
  ;

arr_expression:
    CONSTANT
  | '-' CONSTANT
  | ID
  | '-' ID
  | ID stm_dimensions
  | arr_expression '=' arr_expression
  | arr_expression '+' arr_expression
  | arr_expression '-' arr_expression
  | arr_expression '*' arr_expression
  | arr_expression '/' arr_expression
  | arr_expression '%' arr_expression
  | arr_expression ARITHCOMPARE arr_expression
  | '!' arr_expression
  | arr_expression ANDAND arr_expression
  | arr_expression OROR arr_expression
  | arr_expression PLUSPLUS
  | arr_expression MINUSMINUS
  | '(' arr_expression ')'
  ;

/* Comments */

COMMENT:
    COMMENT_START comment_contents COMMENT_END
  | COMMENT_SINGLE
  ;

comment_contents:
    comment_contents comment_content
  | comment_content
  ;

comment_content:
    CONSTANT
  | ID
  | ','
  | '.'
  | ';'
  | '('
  | ')'
  | '['
  | ']'
  | '{'
  | '}'
  | ':'
  | '+'
  | '-'
  | '*'
  | '/'
  | '%'
  | '='
  | ARITHCOMPARE
  | '!'
  | '?'
  ;

%%

int main()
{
  init_symbol_table();
  yyparse();
  printf("No syntax error!\n");
  return 0;
}

int yyerror(char *s)
{
  fprintf(stderr, "Error at line %d: %s\n", ++numLines, s);
  exit(1);
}
