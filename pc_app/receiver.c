#include <termios.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>

#define TERM_FILE "/dev/ttyUSB1"
int main()
{
	struct termios term;
	int uart_fd = open(TERM_FILE, O_RDWR);
	if(tcgetattr(uart_fd, &term) != 0)
	{
		printf("Error %i from tcgetattr: %s\n", errno, strerror(errno));
	}

	term.c_cflag &= ~PARENB;
	term.c_cflag |= PARENB;

	term.c_cflag &= ~CSTOPB;
	term.c_cflag &= ~CSTOPB;

	term.c_cflag &= ~CSIZE;
	term.c_cflag |= CS8;

	term.c_cflag &= ~CRTSCTS;
	
	term.c_lflag &= ~ICANON;

	term.c_lflag &= ~ECHO;
	term.c_lflag &= ~ECHOE;
	term.c_lflag &= ~ECHONL;

	term.c_lflag &= ~ISIG;

	term.c_iflag &= ~(IXON | IXOFF | IXANY);

	term.c_iflag &= ~(IGNBRK|BRKINT|PARMRK|ISTRIP|INLCR|IGNCR|ICRNL);

	term.c_oflag &= ~OPOST;
	term.c_oflag &= ~ONLCR;

	term.c_cc[VTIME] = 0;
	term.c_cc[VMIN] = 8;

	cfsetispeed(&term, B115200);
	cfsetospeed(&term, B115200);

	if(tcsetattr(uart_fd, TCSANOW, &term) != 0)
	{
		printf("Error %i from tcsetattr:  %s\n", errno, strerror(errno));
	}
	unsigned char readbuff[8] = {0};

	unsigned timestamp = 0;
	int data_rcv = 0;
	while(1)
	{
		read(uart_fd, &readbuff, 8);
		
		printf("buffer: %s, readbuff");
		timestamp = *(unsigned*)readbuff;
		data_rcv = *(int*)(&readbuff[4]);

		printf("timestamp: %u, data: %d", timestamp, data_rcv);
	}
	return 0;

}
