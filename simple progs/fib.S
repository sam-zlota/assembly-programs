.global main
.text

	
/*
long fib( long n) {
	long a = 0;
	long b = 1;
	long c;
	long i = 1;
	while(i < n) {
		c = b;
		b = a + b;
		a = c; 
		i++;
	}
	return b;
}

variable mappings:
	- n is %rdi and then mov to %rbx
	- a is %r12
	- b is %r13
	- c is %r14
	- i is %r15
*/


fib:
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %r15
	pushq %rbx
	enter $8, $0

	//a = 0
	mov $0, %r12

	//b = 1
	mov $1, %r13

	//c = 0
	mov $0, %r14

	//i = 1
	mov $1, %r15

	//saving n to safe register
	mov %rdi, %rbx
	

loop_cond:
	//i < n
	cmp %rbx, %r15
	jge loop_done
	
	//c = b
	mov %r13, %r14

	//b = a+b
	add %r12, %r13

	//a = c
	mov %r14, %r12

	//i++
	inc %r15
	
	jmp loop_cond

loop_done:
	//return b
	mov %r13, %rax

	leave
	popq %rbx
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	ret




/*
pseudocode
int
main (int argc, char* argv[]) {
	
	if(argc != 2)
		//print error
		return 1;
	
	long n = atol(argv[1])

	if(n < 0)
		//print error
		return 1
	if(n == 0)
		printf(0)
		return 0

	printf(fib(n));
	return 0;

}

variable mapping:
	n -> %r12

*/

main:
	pushq %r12
	enter $8, $0

	//if argc !=2
	cmp $2, %rdi
	jne error

	//getting argv[1]
	mov 8(%rsi), %rdi
	call atol

	//storing n in r12 so it can be used in ouput later
	mov %rax, %r12

	//if n <=0
	cmp $0, %r12
	jle leq_zero_case

	
	//call fib(n)
	mov %r12, %rdi
	call fib
	
	mov $strfmt, %rdi
	mov %r12, %rsi
	mov %rax, %rdx
	mov $0, %al
	call printf

	mov $0, %rax

	leave
	popq %r12
	ret
leq_zero_case:

	//if n < 0
	cmp $0, %r12
	jne error

	mov $strfmt, %rdi
	mov $0, %rsi
	mov $0, %rdx
	mov $0, %al
	call printf
	
	mov $0, %rax
	leave
	popq %r12
	ret
	
	
error:
	mov $err_string, %rdi
	mov $0, %al
	call printf
	
	mov $1, %rax
	leave
	popq %r12
	ret
	
.data

strfmt: .string "fib(%d) = %d\n"
err_string: .string "Usage: ./fib N, where N >= 0\n"
	

