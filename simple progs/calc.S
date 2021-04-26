.global main
.text

/*
int
main(int argc, char* argv[])
{	
	if(argc !=  4) {
		printf("Usage:  \n ./ccalc N p N\n ");
		return 1;
	}

	long val1 = atol(argv[1]);
	char op = argv[2];
	long val2 = atol(argv[3]);
	long result = 0;

	if(op  == '+') {
		result = val1 + val2;
	}
	else if(op == '-') {
		result = val1 - val2;
	}
	else if(op == '*') {
		result = val1 * val2;
	}
	else if(op == '/' && val2 != 0) {
		result = val1 / val2;
	}
	else {
        	printf("Usage:\n ./ccalc N op  N\n");
	       	return 1;
       	}
    printf("%ld %s %ld = %ld \n", val1, argv[2], val2, result);
    return 0;
}


variable mappings:
	argc -> %rdi
	val1 -> %r12
	val2 -> %r13
	op -> %r14
	result -> %r15
	

*/


main:
	pushq %r12
	pushq %r13
	pushq %r14
	pushq %rbx

	enter $0, $0
	mov %rsi, %rbx

	//if argc != 4
	cmp $4, %rdi
	jne error
	
	//val1
	mov 8(%rbx), %r12

	//op
	mov 16(%rbx), %r14

	//val2
	mov 24(%rbx), %r13

	mov %r12, %rdi
	call atol
	mov %rax, %r12


	mov %r13, %rdi
	call atol
	mov %rax, %r13
	


	//if op == "+"	
	mov $plus_sign, %rdi
	mov 16(%rbx), %rsi
	call strcmp
	cmp $0, %rax
	je plus
	
	//if op == "-"
	mov $minus_sign, %rdi
	mov 16(%rbx), %rsi
	call strcmp
	cmp $0, %rax
	je subt

	//if op == "*"
	mov $mult_sign, %rdi
	mov 16(%rbx), %rsi
	call strcmp
	cmp $0, %rax
	je mult

	//if op == "/"	
	mov $div_sign, %rdi
	mov 16(%rbx), %rsi
	call strcmp
	cmp $0, %rax
	je divn

	jmp error

plus:
	mov %r13, %rcx
	add %r12, %r13
	mov %r13, %rax
	mov %rcx, %r13
	jmp done

subt:
	mov %r13, %rcx
	sub %r12, %r13
	mov %r13, %rax
	imul $-1, %rax
	mov %rcx, %r13
	jmp done

mult:
	mov %r13, %rcx
	imul %r12, %r13
	mov %r13, %rax
	mov %rcx, %r13
	jmp done

divn:	
	cmp $0, %r13
	je error
	mov %r12, %rax
	idiv %r13
	jmp done

error:
	mov $err_msg, %rdi
	mov $0, %al
	call printf
	
	mov $1, %rax

	leave
	popq %rbx
	popq %r14
	popq %r13
	popq %r12

	ret

done:

	mov $output_msg, %rdi
	mov %r12, %rsi
	mov %r14, %rdx
	mov %r13, %rcx
	mov %rax, %r8
	mov $0, %al
	call printf

	leave 

	popq %rbx
	popq %r14
	popq %r13
	popq %r12
	ret


.data
output_msg: .string "%ld %s %ld = %ld\n"
err_msg: .string "Usage: \n .acalc N op N\n"
err_msgA: .string "errorA\n"
plus_sign: .string "+"
minus_sign: .string "-"
mult_sign: .string "*"
div_sign: .string "/"

