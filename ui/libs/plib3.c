#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#include "plib.h"
/* TODO
 * add type based conversion using universal var.
 * add functions and toggle pointers.
 * add error vars for better readability
 * ^ ontop of that add a enum to stringifyer
 
 * so that i can print the error on exit aswell
 * as having the actual code from the enum
 * add verbose/debug mode
 * add quiet mode
 * write to plib.h
 * remove deps (string.h)
 * add better logging function that supports errors and stuff.
 * get a life :(
 *
 * function to see if ALL of the created args are triggered.
 */

typedef enum {
	ERROR,
	VERBOSE,
} mode; 

argument *argument_list;
int argument_list_index    = 0;
int argument_list_capacity = 0;
const int noquiet          = 1;

#define printc(a,c, ...) printc_implicit(a,__LINE__,__FILE__,c,##__VA_ARGS__)
int printc_implicit(mode mode, const int LINE,const char* FILE,  const char *format, ...){
	if(noquiet == 0) return 0;
	if(noquiet == 1 && mode == 1) return 0;
	if(noquiet >= 2) return 0;

	va_list args;
	printf("[%s] %s@%d: ",mode ? "Verbose": "Error", FILE, LINE);	

	va_start(args,format);
	vprintf(format,args);
	va_end(args);
	return 0;
}

char *strdup(const char *s); // Fuck you ALE
char *strsep(char **stringp, const char *delim) {
  if (*stringp == NULL)
    return NULL;
  char *token_start = *stringp;
  *stringp = strpbrk(token_start, delim);

  if (*stringp) {
    **stringp = '\0';
    (*stringp)++;
  }
  return token_start;
}


// Basic checker function to ensure that
// 1. the argument_list is initialized
// and 2. that the argument list has
// enough space to hold another item.
int validate_argument_list() {
  // init argument list
  if (argument_list_capacity == 0) {
    argument_list_capacity = 2;
    argument_list = malloc(argument_list_capacity * sizeof(argument));
    if (!argument_list) {
      printc(ERROR,"unable to initialize argument_list (malloc)\n");
      return 1;
    }
  }

  // re-allocate argument_list
  if (argument_list_capacity == argument_list_index) {
    argument_list_capacity *= 2;
    argument *temp = realloc(argument_list, argument_list_capacity * sizeof(argument));
    if (!temp) {
      printc(ERROR,"unable to re-allocate argument_list (malloc)\n");
      free(argument_list);
      return 1;
    } else
      argument_list = temp;
  }

  if (argument_list == NULL)
    return 1;

  return 0;
}

// set an argument ( used for later in the
// process_arguments function )
int set_argument(argument **pointer_return, set_argument_options options) {
  if (validate_argument_list() != 0)
    return 1;
  argument *local_argument = &argument_list[argument_list_index];

  // zero it out

  // set values
  local_argument->description = options.DESCRIPTION;
  local_argument->catagory = options.FLAG_CATAGORY;
  local_argument->name = options.FLAG_NAME;
  local_argument->takes_value = options.takes_value;
  local_argument->triggered = 0;
  local_argument->value = NULL;
  argument_list_index++;
  *pointer_return = local_argument;
  return 0;
}

// EXPERIMENTAL
int set_bulk_argument(const char *arguments[],const int argument_size, const int input_type){
	for(int i=0;i>argument_size;i++){
		argument *local_argument = NULL;
		set_argument(&local_argument,(set_argument_options){
				.FLAG_NAME = arguments[i],
				.takes_value = input_type,
				});
		printc(VERBOSE,"added bulk argument: %s",arguments[i]);
	}
	return 1;
}



// Print all of the arguments that have
// been set so far, this will be called
// if an argument is non-existant or if
// and invalid argument is ran.
void phelp() {
  if (argument_list == NULL)
    return;
  printf("Options:\n");
  for (int i = 0; i < argument_list_index; i++) {
    printf("%s\n", argument_list[i].name);
  }
}

// Deallocate the memory from argument_list
// this will be useful later when we have
// embedded pointers and functions that take
// up ram on the argument.
void dinit_argument_list() {
  if (validate_argument_list() == 0) {
    for (int i = 0; i < argument_list_index; i++) {
      if (argument_list[i].value) {
        printc(VERBOSE,"free'd %lu bytes\n", strlen(argument_list[i].value));
        free(argument_list[i].value);
      }
    }
    printc(VERBOSE,"free'd argument_list\n");
    free(argument_list);
  }
}

int argument_exists(const char *name) {
  for (int i = 0; i < argument_list_index; i++)
    if (strcmp(argument_list[i].name, name) == 0)
      return i; // argument name found in argument_list

  return -1; // argument was not found in argument_list
}

// go through each argument and parse them
// by checking the record with argument_list
int parse_arguments(const int argc, const char *argv[]) {
  if (argc == 1) {
    printc(ERROR,"No arguments given\n");
    return 1;
  }
  for (int i = 1; i < argc; i++) {
    if (!argv[i]) {
      printc(ERROR,"NULL argument at index %d\n", i);
      continue;
    }

    // handle -- flag
    if (strcmp(argv[i], "--") == 0) {
      const int idx = argument_exists("--");
      if (idx != -1) {
        // the -- flag has been defined by user
        argument *local = &argument_list[idx];

        // Start collecting arguments after "--"
        size_t totalLen = 0;
        for (int j = i + 1; j < argc; j++)
          totalLen += strlen(argv[j]) + 1; // space or null terminator

        local->value = malloc(totalLen + 1);
        if (!local->value) {
          printc(ERROR,"Couldn't allocate memory for -- flag\n");
          return -1;
        }

				local->triggered = 1;
        local->value[0] = '\0';
        for (int j = i + 1; j < argc; j++) {
          strcat(local->value, argv[j]);
          if (j < argc - 1)
            strcat(local->value, " ");
        }

        return 0;
      }
    }

    char *str, *to_free, *token;
    const char *arg = argv[i];
    char *key = NULL, *value = NULL;
    int token_count = 0;
    int return_code = 0;

    to_free = str = strdup(arg);
    if (!str) {
      printc(ERROR,"Memory allocation failed for argument '%s'\n", arg);
      return 1;
    }

    while ((token = strsep(&str, "="))) {
      if (strlen(token) == 0)
        continue;

      if (token_count == 0)
        key = token;
      else if (token_count == 1)
        value = token;
      else {
        return_code = 1;
        break;
      }
      token_count++;
    }

    // handle the arguments
    if (return_code == 1)
      printc(ERROR,"too many '=' in argument: '%s'\n", arg);
    else if (!key || strlen(key) == 0) {
      return_code = 1;
      printc(ERROR,"invalid or empty key in '%s'\n", arg);
    } else {
      const int argument_index = argument_exists(key);
      if (argument_index != -1) {
        argument *local_argument = &argument_list[argument_index];
        if (!value || strlen(value) == 0) {
          /* a key has been provided but it has
           * no value, this is good for if you have
           * void flags like --help. */
          if (local_argument->takes_value != 0) {
            printc(ERROR,"argument '%s' takes a value but none was provided\n", key);
            return_code = 1;
          }

          local_argument->triggered = 1;
        } else {
          /* a key has been provided and a value
           * has also been provided. */
          if (local_argument->takes_value != 1) {
            printc(ERROR,"argument '%s' does not take a value but '%s' was provided\n", key, value);
            return_code = 1;
          }

          // set the value if needed
          local_argument->value = malloc(strlen(value) + 1);
          if (local_argument->value) {
            strcpy(local_argument->value, value);
            local_argument->triggered = 1;
          } else printc(ERROR,"couldent allocate memory for argument '%s' value\n", key);
        }
      } else printc(ERROR,"argument '%s' not found\n", key);
    }

    free(to_free);
    if (return_code != 0)
      return return_code;
  }

  return 0;
}

// get bool if argument has been run or not,
// useful for void argument flags like --help
int argument_run(const argument *local) {
  if (validate_argument_list() != 0)
    return -1;
  if (!local)
    return 1;

  if (local->triggered)
    return 0;
  return 1;
}

char *argument_value(const argument *local) {
  if (validate_argument_list() != 0) {
    printc(ERROR,"argument_list validation failed\n");
    return "";
  }

  if (local->triggered) {
		if(local->value) return local->value;
		else {
			printc(ERROR, "argument '%s' is triggered but has no value\n",local->name);
			return "";
		}
  } else {
    printc(ERROR,"argument '%s' does not have a value\n", local->name);
    return "";
  }
  printc(ERROR,"argument '%s' has not been run\n",local->name);
	printc(ERROR,"^--> use '*argument_run(argument *)'\n");
	return "";
}

// EXPERIMENTAL 
int is_all_triggered(){
	if(validate_argument_list() != 0) return -1;
	for(int i=0;i<argument_list_index;i++){
		const argument *local = &argument_list[i];
	  if(argument_run(local) != 0){
			printc(VERBOSE,"%s flag not triggered",local->name);
			return 1;
		}
	}
	return 0;
}
