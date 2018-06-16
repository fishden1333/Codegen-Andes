/* After makefile, type the following line in terminal to execute the codegen: */
/* ./codegen << <input file name> >> <output file name> */

%{
  #include <stdio.h>
  #include <string.h>
  #include <stdlib.h>
  #include "y.tab.h"

  int numLines = 0; // Count the number of lines of the input file.
  char line[1000] = ""; // Buffer for the texts of a line.

  // Type of tokens.
  typedef enum {key, id, op, punc, integer, doub, ch, sci, str, nl, noth, error} Type;
  typedef enum {false, true} bool; // Boolean algebra.

  void print(Type type); // Print out the output messages.

  bool inComment = false; // See if the current position is in a comment.
  bool mulComment = false; // See which type of comment.
  bool inError = false; // See if encounter error.
  bool sourceOn = true; // Control pragma source on or off.
  bool tokenOn = true; // Control pragma token on or off.
%}

DIGIT [0-9]
ID [_a-zA-Z][_a-zA-Z0-9]*
INTEGER 0|[1-9]{DIGIT}*
DOUBLE {DIGIT}*\.{DIGIT}+|{DIGIT}+\.{DIGIT}*
SCI {DIGIT}+[eE][+-]?{DIGIT}+|{DOUBLE}[eE][+-]?{DIGIT}+
WHITESPACE [ \t\r]+

%%

"#pragma source on" {sourceOn = true;
                     print(noth);
                     return PRAGMA;}
"#pragma source off" {sourceOn = false;
                      print(noth);
                      return PRAGMA;}
"#pragma token on" {tokenOn = true;
                    print(noth);
                    return PRAGMA;}
"#pragma token off" {tokenOn = false;
                     print(noth);
                     return PRAGMA;}
"#pragma". {print(error);}

"include <arduino.h>" {print(noth);}

"/*" {inComment = true;
      mulComment = true;
      print(noth);
      return COMMENT_START;}
"//".* {inComment = true;
        mulComment = false;
        print(noth);
        return COMMENT_SINGLE;}
"*/" {inComment = false;
      mulComment = false;
      print(noth);
      return COMMENT_END;}

"OUTPUT" {print(noth);
          yylval.intVal = 1;
          return INT_CONSTANT;}
"HIGH" {print(noth);
        yylval.intVal = 1;
        return INT_CONSTANT;}
"LOW" {print(noth);
       yylval.intVal = 0;
       return INT_CONSTANT;}
"digitalWrite" {print(id);
                return DIGITALWRITE;}
"delay" {print(id);
         return DELAY;}

"void" {print(key);
        return VOIDTYPE;}
"int" {print(key);
       return INTTYPE;}
"double" {print(key);
          return DOUBLETYPE;}
"bool" {print(key);
        return BOOLTYPE;}
"char" {print(key);
        return CHARTYPE;}

"null" {print(key);
        yylval.intVal = 0;
        return INT_CONSTANT;}

"for" {print(key);
      return FOR;}
"while" {print(key);
         return WHILE;}
"do" {print(key);
      return DO;}

"if" {print(key);
      return IF;}
"else" {print(key);
        return ELSE;}

"switch" {print(key);
          return SWITCH;}
"case" {print(key);
        return CASE;}
"default" {print(key);
           return DEFAULT;}

"return" {print(key);
          return RETURN;}

"break" {print(key);
         return BREAK;}
"continue" {print(key);
            return CONTINUE;}

"const" {print(key);
         return CONST;}

"true" {print(key);
        yylval.intVal = 1;
        return BOOL_CONSTANT;}
"false" {print(key);
         yylval.intVal = 0;
         return BOOL_CONSTANT;}

"struct" {print(key);
          return ID;}

"fclose" {print(key);
          return ID;}
"clearerr" {print(key);
            return ID;}
"feof" {print(key);
        return ID;}
"ferror" {print(key);
          return ID;}
"fflush" {print(key);
          return ID;}
"fgetpos" {print(key);
           return ID;}
"fopen" {print(key);
         return ID;}
"fread" {print(key);
         return ID;}
"freopen" {print(key);
           return ID;}
"fseek" {print(key);
         return ID;}
"fsetpos" {print(key);
           return ID;}
"ftell" {print(key);
         return ID;}
"fwrite" {print(key);
          return ID;}
"remove" {print(key);
          return ID;}
"rename" {print(key);
          return ID;}
"rewind" {print(key);
          return ID;}
"setbuf" {print(key);
          return ID;}
"setvbuf" {print(key);
           return ID;}
"tmpfile" {print(key);
           return ID;}
"tmpnam" {print(key);
          return ID;}
"fprintf" {print(key);
           return ID;}
"printf" {print(key);
          return ID;}
"sprintf" {print(key);
           return ID;}
"vfprintf" {print(key);
            return ID;}
"vprintf" {print(key);
           return ID;}
"vsprintf" {print(key);
            return ID;}
"fscanf" {print(key);
          return ID;}
"scanf" {print(key);
         return ID;}
"sscanf" {print(key);
          return ID;}
"fgetc" {print(key);
         return ID;}
"fgets" {print(key);
         return ID;}
"fputc" {print(key);
         return ID;}
"fputs" {print(key);
         return ID;}
"getc" {print(key);
        return ID;}
"getchar" {print(key);
           return ID;}
"gets" {print(key);
        return ID;}
"putc" {print(key);
        return ID;}
"putchar" {print(key);
           return ID;}
"puts" {print(key);
        return ID;}
"ungetc" {print(key);
          return ID;}
"perror" {print(key);
          return ID;}

":" {print(punc);
     return ':';}
";" {print(punc);
     return ';';}
"," {print(punc);
     return ',';}
"." {print(punc);
     return '.';}
"[" {print(punc);
     return '[';}
"]" {print(punc);
     return ']';}
"(" {print(punc);
     return '(';}
")" {print(punc);
     return ')';}
"{" {print(punc);
     return '{';}
"}" {print(punc);
     return '}';}

"++" {print(op);
      return PLUSPLUS;}
"--" {print(op);
      return MINUSMINUS;}
"<=" {print(op);
      return LESSEQUAL;}
">=" {print(op);
      return MOREEQUAL;}
"==" {print(op);
      return EQUALEQUAL;}
"!=" {print(op);
      return NOTEQUAL;}
"&&" {print(op);
      return ANDAND;}
"||" {print(op);
      return OROR;}
"+" {print(op);
     return '+';}
"-" {print(op);
     return '-';}
"*" {print(op);
     return '*';}
"/" {print(op);
     return '/';}
"%" {print(op);
     return '%';}
"<" {print(op);
     return '<';}
">" {print(op);
     return '>';}
"=" {print(op);
     return '=';}
"!" {print(op);
     return '!';}
"&" {print(op);
     return '&';}

{DOUBLE}{DOUBLE}+ {print(error);}

{INTEGER} {print(integer);
           yylval.intVal = atoi(yytext);
           return INT_CONSTANT;}

{DOUBLE} {print(doub);
          yylval.doubVal = atof(yytext);
          return DOUB_CONSTANT;}

{SCI} {print(sci);
       yylval.doubVal = atof(yytext);
       return DOUB_CONSTANT;}

{ID} {print(id);
      yylval.strVal = yytext;
      return ID;}

'([^'])?' {print(ch);
           yylval.charVal = yytext[0];
           return CHAR_CONSTANT;}

\"([^"])*\"|\"\" {print(str);
                  yylval.strVal = yytext;
                  return STR_CONSTANT;}

{DIGIT}[a-zA-Z0-9]+ {print(error);}
{DIGIT}+[eE][+-]?[a-zA-Z]+|{DOUBLE}[eE][+-]?[a-zA-Z]+ {print(error);}
{ID}@+ {print(error);}

\n {inComment = (mulComment == true) ? true : false;
    mulComment = (inComment == 1) ? true : false;
    print(nl);
    strcpy(line, "");}

{WHITESPACE} {print(noth);}
'\" {print(noth);}
. {print(error);}

%%

int yywrap()
{
  return 1; // EOF
}

void print(Type type)
{
  switch(type)
  {
    case key:
      if (inComment == false && inError == false && tokenOn == true)
      {
        printf("#key:%s\n", yytext);
      }
      strcat(line, yytext);
      break;

    case id:
      if (inComment == false && inError == false && tokenOn == true)
      {
        printf("#id:%s\n", yytext);
      }
      strcat(line, yytext);
      break;

    case op:
      if (inComment == false && inError == false && tokenOn == true)
      {
        printf("#op:%s\n", yytext);
      }
      strcat(line, yytext);
      break;

    case punc:
      if (inComment == false && inError == false && tokenOn == true)
      {
        printf("#punc:%s\n", yytext);
      }
      strcat(line, yytext);
      break;

    case integer:
      if (inComment == false && inError == false && tokenOn == true)
      {
        printf("#integer:%s\n", yytext);
      }
      strcat(line, yytext);
      break;

    case doub:
      if (inComment == false && inError == false && tokenOn == true)
      {
        printf("#double:%s\n", yytext);
      }
      strcat(line, yytext);
      break;

    case ch:
      if (inComment == false && inError == false && tokenOn == true)
      {
        printf("#char:%s\n", yytext);
      }
      strcat(line, yytext);
      break;

    case sci:
      if (inComment == false && inError == false && tokenOn == true)
      {
        printf("#sci:%s\n", yytext);
      }
      strcat(line, yytext);
      break;

    case str:
      if (inComment == false && inError == false && tokenOn == true)
      {
        char printStr[1000];
        strncpy(printStr, yytext + 1, yyleng - 2);
        printStr[yyleng - 2] = '\0';
        printf("#string:%s\n", printStr);
      }
      strcat(line, yytext);
      break;

    case nl:
      if (inError == false && sourceOn == true)
      {
        printf("%d:%s\n", ++numLines, line);
        break;
      }
      else if (inError == false && sourceOn == false)
      {
        ++numLines;
        break;
      }
      else if (inError == true)
      {
        fprintf(stderr, "Error at line %d: %s\n", ++numLines, line);
        exit(1);
      }
      else
      {
        break;
      }

    case noth:
      strcat(line, yytext);
      break;

    case error:
      if (inComment == true)
      {
        break;
      }
      else
      {
        if (inError == false)
        {
          inError = true;
          printf("Error: %s\n", yytext);
          strcpy(line, yytext);
        }
        else
        {
          strcat(line, yytext);
        }
      }
  }
}
