/* The vulnerable server */
#include <sys/socket.h>
#include <netinet/in.h>
#include <sys/types.h>
#include <pthread.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <netdb.h>
#include <time.h>

#define	PORTNUM	8001
#define	BLENGTH	256
#define	ALENGTH	128


static void
handle_it(int s)
{

	//printf("Handleit");

	close(0);
	close(1);
	close(2);

	//dup2(s, 1);
	dup(s);
	dup(s);
	dup(s);

	char *args[2];

	args[0] = strdup("/bin/sh");
	args[1] = NULL;

	execve(args[0], args, NULL);
}

void *
handler(void *n)
{
  int s;

  /* Detach */
  pthread_detach(pthread_self());

  /* Cast */
  s = *((int *)n);

  /* Handle and then clean up */
  handle_it(s);
  close(s);
  free(n);

  return ((void *)NULL);
}

int
main(void)
{
  struct sockaddr_in socketname, client;
  struct hostent *host;
  socklen_t clientlen = sizeof (client);
  pthread_t tid;
  int s, n, *c, optval = 1;

  /* Retrieve localhost interface information */
  if ((host = gethostbyname("localhost")) == NULL) {
    perror("gethostbyname()");
    exit(EXIT_FAILURE);
  }

  /* Fill in socket address */
  memset((char *)&socketname, '\0', sizeof (socketname));
  socketname.sin_family = AF_INET;
  socketname.sin_port = htons(PORTNUM);
  memcpy((char *)&socketname.sin_addr, host->h_addr_list[0], host->h_length);

  /* Create an Internet family, stream socket */
  s = socket(AF_INET, SOCK_STREAM, 0);
  if (s < 0) {
    perror("socket()");
    exit(EXIT_FAILURE);
  }

  /* Allow address reuse if waiting on kernel to clean up */
  if (setsockopt(s, SOL_SOCKET, SO_REUSEADDR, (char *)&optval, sizeof (optval)) < 0) {
    perror("setsockopt()");
    exit(EXIT_FAILURE);
  }

  /* Bind address to socket */
  if (bind(s, (struct sockaddr *)&socketname, sizeof (socketname)) < 0) {
    perror("bind()");
    exit(EXIT_FAILURE);
  }

  /* Activate socket */
  if (listen(s, 5)) {
    perror("listen()");
    exit(EXIT_FAILURE);
  }

  /* Loop forever */
  for (;;) {

    /* Accept connection */
    n = accept(s, (struct sockaddr *)&client, &clientlen);
    if (n < 0) {
      perror("accept()");
      exit(EXIT_FAILURE);
    }

    /* Allocate memory for client socket */
    c = malloc(sizeof (*c));
    if (!c) {
      perror("malloc()");
      exit(EXIT_FAILURE);
    }
    *c = n;

    /* Create thread for this client */
    pthread_create(&tid, NULL, handler, (void *)c);		
  }

  /* Close socket */
  close(s);

  return (0);
}
