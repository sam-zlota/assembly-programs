.global main
.data
bad_input: .string "bad input"
printf_fmt: .string "%ld\n"
printf2_fmt: .string "%ld "
new_line: .string "\n"
scanf_fmt: .string "%ld"

.text

/*
void
swap(long* xs, long ii, long jj)
{
	if(ii != jj) {
		long tmp = xs[ii];
		xs[ii] = xs[jj]
		xs[jj] = tmp
	}
}


variable mappings:
	xs -> %r8
	ii -> %r9
	jj -> %r10
	xs[ii]/tmp  -> %r11
	xs[jj] -> %rdx

*/


swap:
	enter $0, $0

	//xs
	mov %rdi, %r8
	//ii
	mov %rsi, %r9
	//jj
	mov %rdx, %r10

	cmp %r9, %r10
	je swap_done

	//r11 holds xs[ii]  
	mov (%r8, %r9, 8), %r11

	//rdx holds xs[jj] 
	mov (%r8, %r10, 8), %rdx
	
	//set xs[ii] to xs[jj]
	mov %r11, (%r8, %r10, 8)

	//set xs[ii] to xs[jj]
	mov %rdx, (%r8, %r9, 8)	

swap_done:
	leave
	ret


/*
long 
partition(long* xs, long lo, long hi)
{
	long pivot = xs[hi - 1]

	long ii = lo;
	long jj = lo;

	for(; jj < (hi -1); ++jj) {
		if(xs[jj] < pivot) {
			swap(xs, ii, jj);
			++ii;
		}
	}
	swap(xs, ii, hi -1);

	return ii;
}


variable mappings:
	xs -> (%rsp)
	lo -> 8(%rsp)
	hi -> 16(%rsp)
	pivot -> 24(%rsp)
	ii -> 32(%rsp)
	jj -> 40(%rsp)


*/


partition:
	enter $48, $0

	//xs
	mov %rdi, (%rsp)
	//lo
	mov %rsi, 8(%rsp)
	//hi
	mov %rdx, 16(%rsp)
	//hi = hi - 1
	mov 16(%rsp), %r8
	dec %r8
	mov %r8, 16(%rsp)

	//long pivot = xs[hi - 1], pivot -> 24rsp
	mov (%rsp), %r8
	mov 16(%rsp), %r9
	mov (%r8, %r9, 8), %r11
	mov %r11, 24(%rsp)

	//long ii = lo
	mov 8(%rsp), %r8
	mov %r8, 32(%rsp)

	//long jj = lo
	mov 8(%rsp), %r8
	mov %r8, 40(%rsp)

partition_loop:

	//jj < hi - 1
	mov 16(%rsp), %r8
	cmp %r8, 40(%rsp)
	jge partition_loop_done
	
	//if xs[jj] < pivot

	//xs[jj] into %r11 
	mov (%rsp), %rcx
	mov 40(%rsp), %rdx
	mov (%rcx, %rdx, 8), %r11

	//xsjj < pivot
	cmp 24(%rsp), %r11
	jge was_false

	//swap(xs, ii, jj)
	mov (%rsp), %rdi
	mov 32(%rsp), %rsi
	mov 40(%rsp), %rdx
	call swap

	//++ii
	mov 32(%rsp), %r8
	inc %r8
	mov %r8, 32(%rsp)

was_false:
	//++jj
	mov 40(%rsp), %r8
	inc %r8
	mov %r8, 40(%rsp)
	jmp partition_loop

partition_loop_done:
	//swap(xs, ii, hi -1)
	mov (%rsp), %rdi
	mov 32(%rsp), %rsi
	mov 16(%rsp), %rdx
	call swap
	
	//return ii
	mov 32(%rsp), %rax

	leave
	ret


/*
void
quicksort(long* xs, long lo, long hi) 
{
	if(hi - lo < 1) { return;}

	long pp = partition(xs, lo, hi);
	quicksort(xs, lo, pp);
	quicksort(xs, pp + 1, hi);
}
	xs -> (rsp)
	lo -> 8(rsp)
	hi -> 16(rsp)
	pp -> 24(rsp)

*/


quicksort:
	enter $32, $0

	//xs
	mov %rdi, (%rsp)
	//lo
	mov %rsi, 8(%rsp)
	//hi
	mov %rdx, 16(%rsp)

	//hi - lo < 1
	mov 16(%rsp), %r8
	sub 8(%rsp), %r8

	cmp $1, %r8
	jl quicksort_done
	
	mov (%rsp), %rdi
	mov 8(%rsp), %rsi
	mov 16(%rsp), %rdx
	call partition

	//long pp = partition(xs, lo, hi)
	mov %rax, 24(%rsp)
	
	//quicksort(xs, lo, pp)
	mov (%rsp), %rdi
	mov 8(%rsp), %rsi
	mov 24(%rsp), %rdx
	call quicksort

	//quicksort(xs, pp+1, hi)
	mov (%rsp), %rdi

	mov 24(%rsp), %r8
	inc %r8
	mov %r8, 24(%rsp)

	mov 24(%rsp), %rsi
	mov 16(%rsp), %rdx
	call quicksort

quicksort_done:
	leave
	ret

/*
void
read_int(long* ptr)
{
	if (scanf("%ld", ptr) != 1) {
		puts("bad input");
		exit(1);
	}
}
*/


read_int:
	enter $0, $0

	//if scanf("%ld", ptr) != 1
	mov %rdi, %rsi
	mov $scanf_fmt, %rdi
	mov $0, %al
	call scanf

	cmp $1, %rax
	je done
	
	mov $bad_input, %rdi
	call puts
	mov $1, %rdi
	call exit

done:	
	leave
	ret



/*
int
main(int argc, char* argv[]) 
{

	long nn;
	read_int(&nn);
	
	long* xs = malloc(nn * sizeof(long));

	for (long ii = 0; ii < nn; ++ii) {
		read_int(&(xs[ii]));
	}
	
	quicksort(xs, 0, nn);

	printf("%ld\n", nn)
	for(long ii = 0; ii < nn; ++ii) {
		printf("%ld", xs[ii]);
	}
	printf("\n);

	free(xs);
	return 0;
}

	variable mappings:
		nn -> %r12
		xs -> %r13
		ii -> %rbx

*/
main:
	push %r12
	push %r13
	push %rbx
	
	enter $8, $0

	//read_int(&nn)
	lea 0(%rsp), %rdi
	call read_int
	mov 0(%rsp), %r12
	

	//nn * sizeof(long)
	mov %r12, %r8
	imul $8, %r8

	//long* xs = malloc(nn * 8)
	mov %r8, %rdi
	call malloc
	mov %rax, %r13

	//align stack
	mov $15, %rcx
	not %rcx
	and %rcx, %rsp
	
	//ii = 0
	mov $0, %rbx

loop_cond:
	//ii < nn
	cmp %r12, %rbx
	jge loop_done
	
	//read_int(&(xs[ii]))
	lea (%r13, %rbx, 8), %rdi
	call read_int

	//++ii
	inc %rbx
	jmp loop_cond

loop_done:
	//quicksort(xs, 0, nn)
	mov %r13, %rdi
	mov $0, %rsi
	mov %r12, %rdx
	call quicksort

	//printf("%ld\n", nn)
	mov $printf_fmt, %rdi
	mov %r12, %rsi
	mov $0, %al
	call printf

	//reset ii to 0
	mov $0, %rbx

second_loop_cond:
	//ii < nn	
	cmp %r12, %rbx
	jge second_loop_done
	
	//printf("%ld ", xs[ii])
	mov $printf2_fmt, %rdi
	mov (%r13, %rbx, 8), %rsi
	mov $0, %al
	call printf

	//++ii
	inc %rbx
	jmp second_loop_cond

second_loop_done:
	//printf("\n")
	mov $new_line, %rdi
	mov $0, %al
	call printf
	
	//free(xs)
	mov %r13, %rdi
	call free
	mov $0, %rax

	leave

	pop %rbx
	pop %r13
	pop %r12
	
	ret

