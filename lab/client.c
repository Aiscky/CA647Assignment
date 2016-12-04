
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <netdb.h>
#include <time.h>
#include <fcntl.h>

#define	PORTNUM	8001
#define	BLENGTH	256

static void
loop(int s)
{
  char buffer[BLENGTH];

  for (;;) {

    /* Receive prompt */


    /* Display prompt */
    //fputs(buffer, stdout);

    memset(buffer, '\0', BLENGTH);

    /* Read user response */
    fgets(buffer, BLENGTH, stdin); //read N-1 characters and nullterminate the string, \n are read unchanged


//    buffer[strlen(buffer) - 1] = '\0';
    //printf("%s", buffer);	

    /* Send user response */
    send(s, (void *)buffer, BLENGTH, 0); //String is null terminated and of maximum size BLENGTH.

    /*if (recv(s, (void *)buffer, BLENGTH, 0) != BLENGTH) {
      break;
    }*/

    sleep(1);

    recv(s, (void *)buffer, BLENGTH, 0);
    fputs(buffer, stdout);
  }
}

int
main(void)
{
  struct sockaddr_in server;
  struct hostent *host;
  int s;

  /* Create an Internet family, stream socket */
  s = socket(AF_INET, SOCK_STREAM, 0);
  if (s < 0) {
    perror("socket()");
    exit(EXIT_FAILURE);
  }

  /* Server listening on localhost interface */
  if ((host = gethostbyname("localhost")) == NULL) {
    perror("gethostbyname()");
    exit(EXIT_FAILURE);
  }

  /* Fill in socket address */
  memset((char *)&server, '\0', sizeof (server));
  server.sin_family = AF_INET;
  server.sin_port = htons(PORTNUM);
  memcpy((char *)&server.sin_addr, host->h_addr_list[0], host->h_length);

  /* Connect to server */
  if (connect(s, (struct sockaddr *)&server, sizeof (server)) < 0) {
    perror("connect()");
    exit(EXIT_FAILURE);
  }
  
  int flags = fcntl(s, F_GETFL, 0);
  fcntl(s, F_SETFL, flags | O_NONBLOCK);


  /* Talk to server */
  loop(s);

  /* Close the socket */
  close(s);

  return (0);
}
