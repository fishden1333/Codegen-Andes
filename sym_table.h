// Sumbol table
#define MAX_TABLE_SIZE 5000
struct symbol_entry {
   char *name;
   double value;
   int scope;
   int offset;
} table[MAX_TABLE_SIZE];

extern int cur_scope;
extern int cur_counter;

void init_symbol_table();
char *install_symbol(char *s);
int look_up_symbol(char *s);
void pop_up_symbol(int scope);
void set_symbol(char *s, double val);
