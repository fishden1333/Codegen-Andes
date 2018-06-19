// Sumbol table
#define MAX_TABLE_SIZE 5000
#define FUNC_T 0
#define INT_T 1
#define DOUBLE_T 2
#define CHAR_T 3
#define BOOL_T 4
#define STR_T 5

struct symbol_entry {
   char *name;
   int type;
   double value;
   int scope;
   int offset;
} table[MAX_TABLE_SIZE];

extern int cur_scope;
extern int cur_counter;

void init_symbol_table();
void install_symbol(char *s, int type);
int look_up_symbol(char *s);
void pop_up_symbol(int scope);
void set_symbol(char *s, double val);
void check_undefined_func();
