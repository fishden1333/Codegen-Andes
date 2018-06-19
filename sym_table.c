/* The code in this file is modified from Prof. Jenq Kuen Lee's original one,
   this is used for symbol table handling */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "sym_table.h"

extern FILE *f_asm;
  extern int numLines;

int cur_scope = 1; // Current global / local scope
int cur_counter = 0; // Current variable count

char *copys(char *s);

/* Initialize symbal table */
void init_symbol_table()
{
  bzero(&table[0], sizeof(struct symbol_entry) * MAX_TABLE_SIZE);
}

/* Install a symbol into the table */
void install_symbol(char *s, int type)
{
  if (cur_counter >= MAX_TABLE_SIZE)
  {
    fprintf(stderr, "Symbol Table is full\n");
  }
  else
  {
    int index = look_up_symbol(s);
    if (index >= 0)
    {
      fprintf(stderr, "Error at line %d: Variable %s can't be declared more than once\n", ++numLines, s);
      exit(1);
    }
    table[cur_counter].name = copys(s);
    table[cur_counter].type = type;
    table[cur_counter].scope = cur_scope;
    table[cur_counter].offset = cur_counter;
    cur_counter++;
  }
}

/* Return the symnol's index in the symbol table */
int look_up_symbol(char *s)
{
  int i;

  for (i = cur_counter - 1; i >= 0; i--)
  {
    if (!strcmp(s, table[i].name))
    {
      if (table[i].scope > cur_scope)
      {
        break;
      }
      return i;
    }
  }
  return -1;
 }

/* Pop up symbols of the given scope from the symbol table */
void pop_up_symbol(int scope)
{
  int i;

  if (cur_counter == 0)
  {
    return;
  }
  for (i = cur_counter - 1; i >= 0; --i)
  {
    if (table[i].scope != scope)
    {
      break;
    }
  }
  if (i < 0)
  {
    cur_counter = 0;
  }
  cur_counter = i + 1;
}

/* Set up a variable */
void set_symbol(char *s, double val)
{
  int index = look_up_symbol(s);
  if (index >= 0)
  {
    table[index].value = val;
  }
}

/* Makes a copy of a string with known length */
char *copyn(int n, char *s)
{
	char *p, *q;
	void *calloc();

	p = q = (char*)calloc(1, n);
	while (--n >= 0)
  {
    *q++ = *s++;
  }
	return (p);
}

/* Makes a copy of a string */
char *copys(char *s)
{
	return (copyn(strlen(s) + 1, s));
}
