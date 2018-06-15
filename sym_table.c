/* The code in this file is modified from Prof. Jenq Kuen Lee's original one,
   this is used for symbol table handling */

#include <stdio.h>
#include <string.h>
#include "sym_table.h"

extern FILE *f_asm;

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
    printf("Symbol Table full.\n");
  }
  else
  {
    table[cur_counter].name = copys(s);
    table[cur_counter].type = type;
    table[cur_counter].scope = cur_scope;
    table[cur_counter].offset = cur_counter;
    cur_counter++;
    printf("cur_counter = %d\n", cur_counter);
    printf("cur_scope = %d\n", cur_scope);
  }
}

/* Return the symnol's index in the symbol table */
int look_up_symbol(char *s)
{
  int i;
  printf("Find: %s\n", s);

  if (cur_counter == 0)
  {
    printf("No variables.\n");
    return(-1);
  }
  for (i = cur_counter - 1; i >= 0; i--)
  {
    if (!strcmp(s, table[i].name))
    {
      printf("Index: %d.\n", i);
      return(i);
    }
  }
  printf("Variable not found.\n");
  return(-1);
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
    printf("scope = %d\n", table[i].scope);
    if (table[i].scope != scope)
    {
      break;
    }
  }
  printf("pop == %d\n", scope);
  if (i < 0)
  {
    cur_counter = 0;
  }
  cur_counter = i + 1;
  printf("pop_cur_counter == %d\n", cur_counter);
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
