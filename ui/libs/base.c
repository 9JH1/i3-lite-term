#include <stdio.h>
#include <string.h>

#include "plib.h"

int main(const int argc, const char *argv[]){
	// set args 
	argument *gx = NULL,
					 *gy = NULL,
					 *wr = NULL,
					 *wc = NULL,
					 *fs = NULL,
					 *pc = NULL;

	set_argument(&gx,(set_argument_options){
			.FLAG_NAME = "-gx",
			.DESCRIPTION = "Geometry X (spawn pos x)",
			.takes_value = TAKE_INPUT,
			});

	set_argument(&gy,(set_argument_options){
			.FLAG_NAME = "-gy",
			.DESCRIPTION = "Geometry Y (spawn pos Y)",
			.takes_value = TAKE_INPUT,
			});

	set_argument(&wr,(set_argument_options){
			.FLAG_NAME = "-wr",
			.DESCRIPTION = "Rows (on window)",
			.takes_value = TAKE_INPUT,
			});

	set_argument(&wc,(set_argument_options){
			.FLAG_NAME = "-wc",
			.DESCRIPTION = "Columns (on window)",
			.takes_value = TAKE_INPUT,
			});

	set_argument(&fs, (set_argument_options){
			.FLAG_NAME = "-fs",
			.DESCRIPTION = "Font Size",
			.takes_value = TAKE_INPUT,
			});

	set_argument(&pc, (set_argument_options){
			.FLAG_NAME = "--",
			.DESCRIPTION = "Program Arguments",
			.takes_value = TAKE_INPUT,
			});

	// manage args 
	if(parse_arguments(argc,argv) == 0){
		if(is_all_triggered() == 0){
			// get values
			printf("%s %s %s %s %s \"%s\"",
					argument_value(gx),
					argument_value(gy),
					argument_value(wc),
					argument_value(wr),
					argument_value(fs),
					argument_value(pc));
		} else {
			phelp();
			printf("ALL arguments need to be triggered\n");
			return 1;
		}
	} else {
		phelp();
		return 1;
	}

	// exit program
	dinit_argument_list();
	return 0;
}
