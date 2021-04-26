#include <stdio.h>
#include <stdlib.h>



int
main(int argc, char* argv[])
{	
	if(argc !=  4) {
		
		printf("Usage:  \n ./ccalc N op N\n ");
		return 1;
	}

	long val1 = atol(argv[1]);
	long val2 = atol(argv[3]);
	long result = 0;

	if(*argv[2]  == '+') {
		result = val1 + val2;
	}
	else if(*argv[2] == '-') {
		result = val1 - val2;
	}
	else if(*argv[2] == '*') {
		result = val1 * val2;
	}
	else if(*argv[2] == '/' && val2 != 0) {
		result = val1 / val2;
	}
	else {
        	printf("Usage:\n ./ccalc N op  N\n");
	       	return 1;
       	}
	
	
    
  	 printf("%ld %s %ld = %ld\n", val1, argv[2], val2, result);
	 return 0;
}
