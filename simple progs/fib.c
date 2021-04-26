
#include <stdio.h>
#include <stdlib.h>

long
fib(long x) 
{
	if(x == 0) {
		return 0;
	}
	else if(x == 1) {
		return 1;
	}
	else {
		return fib(x - 1) + fib (x - 2);
	}


}



int
main(int argc, char* argv[])
{
	if(argc != 2) {
		printf("Usage: ./fib N, where N >= 0\n");
		return 1;
	}

	long input = atol(argv[1]);

       	if (input < 0 ) {
       		 printf("Usage: ./fib N, where N >= 0\n");
       		 return 1;
       	}


    	long result = fib(input);

   	 printf("fib(%ld) = %ld\n", input , result);
   	 return 0;
}
