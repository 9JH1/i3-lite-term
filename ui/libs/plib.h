#ifndef PLIB3_H
#define PLIB3_H

// Data types
typedef struct argument {
  const char *name;
  const char *description;
  const char *catagory;
  char *value;
  int takes_value;
  int triggered;
} argument;

typedef struct set_argument_options {
  const char *FLAG_NAME;
  const char *DESCRIPTION;
  const char *FLAG_CATAGORY;
  const int takes_value;
} set_argument_options;

typedef enum {
  NO_INPUT,
  TAKE_INPUT,
} set_argument_enum_values;

// Functions
int set_argument(argument **pointer_return, set_argument_options options);
void phelp(void);
void dinit_argument_list(void);
int argument_exists(const char *name);
int parse_arguments(const int argc, const char *argv[]);
int argument_run(const argument *local);
char* argument_value(const argument *local);
int set_bulk_argument(const char *arguments[],const int argument_size, const int input_type);
int is_all_triggered(void);

// Global vars
extern argument *argument_list;
extern int argument_list_index;
extern int argument_list_capacity;


#endif // PLIB3_H 
