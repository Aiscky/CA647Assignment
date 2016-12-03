#include <stdio.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <string.h>


int main(int ac, char **av) {
	/*char buffer[256];	
	sprintf(buffer, "%.*d\n", 20, 0);

	printf("%s", buffer);*/

	printf("%d\n", sizeof(char));
	printf("%d\n", sizeof(int));	
	printf("%d\n", sizeof(long));
	printf("%d\n", sizeof(long long));

	return (0);
}
