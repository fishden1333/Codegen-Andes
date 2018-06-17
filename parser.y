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

  typedef enum {false, true} bool; // Boolean algebra.

  FILE *f_asm; // File used for generating assembly code

  int varType; // Variable type
  bool isFunc; // See if the variable is a function name
  char *delimiter = " +-*/=,;()"; // Used for strtok
  int maxRegNum = -1; // The max register number, -1: no register used
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
%token INTTYPE DOUBLETYPE CHARTYPE BOOLTYPE VOIDTYPE ID
%token RETURN CONST IF ELSE SWITCH CASE DEFAULT WHILE DO FOR BREAK CONTINUE
%token COMMENT_START COMMENT_SINGLE COMMENT_END PRAGMA

/* For Andes */
%token DIGITALWRITE DELAY

%type <intVal> INT_CONSTANT BOOL_CONSTANT
%type <doubVal> DOUB_CONSTANT expression CONSTANT
%type <charVal> CHAR_CONSTANT
%type <strVal> ID STR_CONSTANT

/* Precedence and associativity */
%left <charVal> ';'
%left INTTYPE DOUBLETYPE CHARTYPE BOOLTYPE VOIDTYPE
%left <charVal> ','
%right <charVal> '='
%left <strVal> OROR
%left <strVal> ANDAND
%right <charVal> '!'
%left <strVal> LESSEQUAL MOREEQUAL EQUALEQUAL NOTEQUAL '<' '>'
%left <charVal> '+' '-'
%left <charVal> '*' '/' '%'
%left <strVal> PLUSPLUS MINUSMINUS

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
    {
      char *id;
      int index;

      id = strtok($1, delimiter);
      install_symbol(id, varType);
      set_symbol(id, 0);
      index = look_up_symbol(id);
      // fprintf(f_asm, "  movi $r%d, 0\n", ++maxRegNum);
      fprintf(f_asm, "  swi $r%d, [$sp + (%d)]\n", maxRegNum, table[index].offset * 4);
      maxRegNum--;
    }
  | ID '=' expression
    {
      int expr = $3;
      char *id;
      int index;

      id = strtok($1, delimiter);
      install_symbol(id, varType);
      set_symbol(id, expr);
      index = look_up_symbol(id);
      // fprintf(f_asm, "  movi $r%d, %d\n", ++maxRegNum, expr);
      fprintf(f_asm, "  swi $r%d, [$sp + (%d)]\n", maxRegNum, table[index].offset * 4);
      maxRegNum--;
    }
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
    {
      install_symbol($2, varType);
    }
  | NONVOIDTYPE ID dcl_dimensions
  ;

IDconst_declarations:
    IDconst_declarations ',' IDconst_declaration
  | IDconst_declaration
  ;

IDconst_declaration:
    ID '=' CONSTANT
    {
      install_symbol($1, varType);
      set_symbol($1, $3);
    }
  ;

/* Type */
NONVOIDTYPE:
    INTTYPE
    {
      varType = INT_T;
    }
  | DOUBLETYPE
    {
      varType = DOUBLE_T;
    }
  | CHARTYPE
    {
      varType = CHAR_T;
    }
  | BOOLTYPE
    {
      varType = BOOL_T;
    }
  ;

/* Constant */

CONSTANT:
    INT_CONSTANT
    {
      $$ = $1;
    }
  | DOUB_CONSTANT
    {
      $$ = $1;
    }
  | CHAR_CONSTANT
    {
      $$ = $1;
    }
  | BOOL_CONSTANT
    {
      $$ = $1;
    }
  | STR_CONSTANT
    {
      $$ = 0;
    }
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
  | if_statement
    {
      fprintf(f_asm, "out:\n");
    }
    else_statement
    {
      fprintf(f_asm, "out2:\n");
    }
  | if_statement
    {
      fprintf(f_asm, "out:\n");
      fprintf(f_asm, "out2:\n");
    }
  | switch_statement
  | {
      fprintf(f_asm, "loop:\n");
    }
    while_statement
    {
      fprintf(f_asm, "out:\n");
    }
  | do_while_statement
  | for_statement
  | return_statement
  | break_statement
  | continue_statement
  | digitalWrite_statement
  | delay_statement
  | func_statement COMMENT
  | func_statement PRAGMA
  ;

simple_statement:
    ID '=' expression ';'
    {
      char *id;
      int index;
      int expr = $3;

      id = strtok($1, delimiter);
      set_symbol($1, expr);
      index = look_up_symbol(id);
      // fprintf(f_asm, "  movi $r%d, %d\n", ++maxRegNum, expr);
      fprintf(f_asm, "  swi $r%d, [$sp + (%d)]\n", maxRegNum, table[index].offset * 4);
      maxRegNum--;
    }
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
    IF '(' expression ')' '{'
    {
      maxRegNum--;
    }
    func_contents
    {
      fprintf(f_asm, "  j out2\n");
    }
    '}'
  | IF '(' expression ')' '{'
    {
      maxRegNum--;
      fprintf(f_asm, "  j out2\n");
    }
    '}'
  ;

else_statement:
    ELSE '{' func_contents '}'
  | ELSE '{' '}'
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
    WHILE '(' expression ')' '{'
    {
      maxRegNum--;
    }
    func_contents '}'
    {
      fprintf(f_asm, "  j loop\n");
    }
  | WHILE '(' expression ')' '{'
    {
      maxRegNum--;
    }
    '}'
    {
      fprintf(f_asm, "  j loop\n");
    }
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

digitalWrite_statement:
    DIGITALWRITE '(' expression ',' expression ')' ';'
    {
      fprintf(f_asm, "  bal	digitalWrite\n");
      maxRegNum = maxRegNum - 2;
    }
  ;

delay_statement:
    DELAY '(' expression ')' ';'
    {
      fprintf(f_asm, "  bal	delay\n");
      maxRegNum--;
    }
  ;

/* Expressions */

expressions:
    expressions ',' expression
  | expression
  ;

expression:
    CONSTANT
    {
      int num = $1;

      $$ = num;
      fprintf(f_asm, "  movi $r%d, %d\n", ++maxRegNum, num);
    }
  | '-' CONSTANT
    {
      int num = -1 * $2;

      $$ = num;
      fprintf(f_asm, "  movi $r%d, %d\n", ++maxRegNum, num);
    }
  | ID
    {
      int index;
      char *id;

      id = strtok($1, delimiter);
      index = look_up_symbol(id);
      if (index >= 0)
      {
        $$ = table[index].value;
        fprintf(f_asm, "  lwi $r%d, [$sp + (%d)]\n", ++maxRegNum, table[index].offset * 4);
      }
    }
  | '-' ID
    {
      int index;
      char *id;

      id = strtok($2, delimiter);
      index = look_up_symbol(id);
      if (index >= 0)
      {
        $$ = -1 * table[index].value;
        fprintf(f_asm, "  lwi $r%d, [$sp + (%d)]\n", ++maxRegNum, table[index].offset * 4);
        fprintf(f_asm, "  movi $r%d, -1\n", maxRegNum + 1);
        fprintf(f_asm, "  muli $r%d, $r%d, $r%d\n", maxRegNum, maxRegNum, maxRegNum + 1);
      }
    }
  | ID stm_dimensions
    {
      $$ = 0;
    }
  | ID '(' expressions ')'
    {
      $$ = 0;
    }
  | ID '(' ')'
    {
      $$ = 0;
    }
  | expression '=' expression
    {
      $1 = $3;
      $$ = $1;
    }
  | expression '+' expression
    {
      $$ = $1 + $3;
      fprintf(f_asm, "  add $r%d, $r%d, $r%d\n", maxRegNum - 1, maxRegNum - 1, maxRegNum);
      maxRegNum--;
    }
  | expression '-' expression
    {
      $$ = $1 - $3;
      fprintf(f_asm, "  sub $r%d, $r%d, $r%d\n", maxRegNum - 1, maxRegNum - 1, maxRegNum);
      maxRegNum--;
    }
  | expression '*' expression
    {
      $$ = $1 * $3;
      fprintf(f_asm, "  mul $r%d, $r%d, $r%d\n", maxRegNum - 1, maxRegNum - 1, maxRegNum);
      maxRegNum--;
    }
  | expression '/' expression
    {
      $$ = $1 / $3;
      fprintf(f_asm, "  divsr $r%d, $r%d, $r%d, $r%d\n", maxRegNum - 1, maxRegNum, maxRegNum - 1, maxRegNum);
      maxRegNum--;
    }
  | expression '%' expression
  | expression LESSEQUAL expression
    {
      if ($1 <= $3)
      {
        $$ = 1;
      }
      else
      {
        $$ = 0;
      }
      fprintf(f_asm, "  slt $r%d, $r%d, $r%d\n", maxRegNum - 1, maxRegNum, maxRegNum - 1);
      maxRegNum--;
      fprintf(f_asm, "  bnez $r%d, out\n", maxRegNum);
    }
  | expression MOREEQUAL expression
    {
      if ($1 >= $3)
      {
        $$ = 1;
      }
      else
      {
        $$ = 0;
      }
      fprintf(f_asm, "  slt $r%d, $r%d, $r%d\n", maxRegNum - 1, maxRegNum - 1, maxRegNum);
      maxRegNum--;
      fprintf(f_asm, "  bnez $r%d, out\n", maxRegNum);
    }
  | expression EQUALEQUAL expression
    {
      if ($1 == $3)
      {
        $$ = 1;
      }
      else
      {
        $$ = 0;
      }
      fprintf(f_asm, "  bne $r%d, $r%d, out\n", maxRegNum - 1, maxRegNum);
      maxRegNum--;
    }
  | expression NOTEQUAL expression
    {
      if ($1 != $3)
      {
        $$ = 1;
      }
      else
      {
        $$ = 0;
      }
      fprintf(f_asm, "  beq $r%d, $r%d, out\n", maxRegNum - 1, maxRegNum);
      maxRegNum--;
    }
  | expression '<' expression
    {
      if ($1 < $3)
      {
        $$ = 1;
      }
      else
      {
        $$ = 0;
      }
      fprintf(f_asm, "  slt $r%d, $r%d, $r%d\n", maxRegNum - 1, maxRegNum - 1, maxRegNum);
      maxRegNum--;
      fprintf(f_asm, "  beqz $r%d, out\n", maxRegNum);
    }
  | expression '>' expression
    {
      if ($1 > $3)
      {
        $$ = 1;
      }
      else
      {
        $$ = 0;
      }
      fprintf(f_asm, "  slt $r%d, $r%d, $r%d\n", maxRegNum - 1, maxRegNum, maxRegNum - 1);
      maxRegNum--;
      fprintf(f_asm, "  beqz $r%d, out\n", maxRegNum);
    }
  | '!' expression
    {
      if ($2 != 0)
      {
        $$ = 0;
      }
      else
      {
        $$ = 1;
      }
      fprintf(f_asm, "  bnez $r%d, out\n", maxRegNum);
    }
  | expression ANDAND expression
  | expression OROR expression
  | expression PLUSPLUS
  | expression MINUSMINUS
  | '(' expression ')'
    {
      $$ = $2;
    }
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
  | arr_expression LESSEQUAL arr_expression
  | arr_expression MOREEQUAL arr_expression
  | arr_expression EQUALEQUAL arr_expression
  | arr_expression NOTEQUAL arr_expression
  | arr_expression '<' arr_expression
  | arr_expression '>' arr_expression
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
  | LESSEQUAL
  | MOREEQUAL
  | EQUALEQUAL
  | NOTEQUAL
  | '<'
  | '>'
  | '!'
  | '?'
  ;

%%

int main()
{
  init_symbol_table();

  f_asm = fopen("assembly", "w");
  if (f_asm == NULL)
  {
    fprintf(stderr, "Can not open the file %s for writing.\n", "assembly");
  }

  fprintf(f_asm, "\n");
  yyparse();
  printf("No syntax error!\n");

  return 0;
}

int yyerror(char *s)
{
  fprintf(stderr, "*** Error at line %d: %s\n", ++numLines, line);
  fprintf(stderr, "\n");
  fprintf(stderr, "Unmatched token: %s\n", yytext);
  fprintf(stderr, "*** %s\n", s);
  exit(1);
}
