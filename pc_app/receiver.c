#include <termios.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <arpa/inet.h>

#include "receiver.h"

#define TERM_DIR "/dev/"
#define DEF_DEVICE "ttyUSB1"
#define CSV_FILE  "csv_output.csv"
//#define ADJUST_TIMEZONE(val) do{if(val>3*3600) val -= 3*3600;}while(0);

uint32_t reorder_bytes(void *word)
{
	return ntohl(*(uint32_t*)word);
}

int fill_config_for_uart(int uart_fd, struct termios *term)
{
	if(tcgetattr(uart_fd, term) != 0)
	{
		printf("Error %i from tcgetattr: %s\n", errno, strerror(errno));
	}

	term->c_cflag &= ~PARENB;
	term->c_cflag |= PARENB;

	term->c_cflag &= ~CSTOPB;

	term->c_cflag &= ~CSIZE;
	term->c_cflag |= CS8;

	term->c_cflag &= ~CRTSCTS;

	term->c_cflag |= CREAD;
	term->c_cflag |= PARENB;
	term->c_cflag |= PARODD;
	
	term->c_lflag &= ~ICANON;

	term->c_lflag &= ~ECHO;
	term->c_lflag &= ~ECHOE;
	term->c_lflag &= ~ECHONL;

	term->c_lflag &= ~ISIG;
	term->c_iflag &= ~(IXON | IXOFF | IXANY);

	term->c_iflag &= ~(IGNBRK|BRKINT|PARMRK|ISTRIP|INLCR|IGNCR|ICRNL);
	term->c_iflag |= BRKINT;

	term->c_oflag &= ~OPOST;
	term->c_oflag &= ~ONLCR;

	term->c_cc[VTIME] = 0;
	term->c_cc[VMIN] = 8;

	cfsetspeed(term, B115200);
	return 0;
}

// Socket for file in comm_struct needs to be open as append.
int add_reading_to_csv(comm_struct *comm, reading_struct *reading)
{
	char time_to_string[24];
	char reading_to_string[16];
	time_t read_time = (time_t)reading->time_of_reading;
	//ADJUST_TIMEZONE(read_time);
	struct tm ts = *localtime(&read_time);
	strftime(time_to_string, sizeof(time_to_string), "%Y/%m/%d/%H:%M:%S", &ts);
	// snprintf(time_to_string, sizeof(time_to_string), "%u",strftime);
	snprintf(reading_to_string, sizeof(reading_to_string), "%i.%i", reading->reading/1000, abs(reading->reading%1000));	
	if(comm->csv_file_fd == -1)
	{
		return -1;
	}
	if(1 != write(comm->csv_file_fd, (void*)"\n", sizeof(char)))
	{
		return -1;
	}

	if(strlen(time_to_string) != write(comm->csv_file_fd, time_to_string, strlen(time_to_string)))
	{
		return -1;
	}

	if(1 != write(comm->csv_file_fd, (void*)",", sizeof(char)))
	{
		return -1;
	}

	if(strlen(reading_to_string) != write(comm->csv_file_fd, reading_to_string, strlen(reading_to_string)))
	{
		return -1;
	}
	return 0;
}

int init_comm_struct(comm_struct *comm)
{
	char file_loc[64] = {0};
	snprintf(file_loc, sizeof(file_loc), "%s%s", TERM_DIR, comm->dev_name[0] == '\0'?DEF_DEVICE:comm->dev_name); 
	comm->uart_dev_fd = open(file_loc, O_RDWR);
	if(comm->uart_dev_fd == -1)
	{
		printf("Failed to open file %s\n", file_loc);
		return -1;
	}

	fill_config_for_uart(comm->uart_dev_fd, &comm->term);

	if(tcsetattr(comm->uart_dev_fd, TCSANOW, &comm->term) != 0)
	{
		printf("Error %i from tcsetattr:  %s\n", errno, strerror(errno));
		return -1;
	}
	comm->csv_file_fd = open(CSV_FILE, O_WRONLY|O_CREAT|O_APPEND, 0666);
	if(comm->csv_file_fd == -1)
		return -1;	
	return 0;
}

int destroy_comm_struct(comm_struct *comm)
{
	close(comm->csv_file_fd);
	close(comm->uart_dev_fd);
}

int receive_data(comm_struct *comm)
{
	unsigned char readbuff[8] = {0};

	reading_struct read_st;
	time_t reading_time;
	int read_B = 0;
	while(1)
	{
		read_B = read(comm->uart_dev_fd, &readbuff, 8);
		if(0 == read_B)
		{
			printf("Read 0 bytes\n");
			break;
		}
		printf("Read %d bytes\n", read_B);
		if(read_B != 8)
		{
			printf("Not enough bytes\n");
			continue;
		}
		
		read_st.time_of_reading = reorder_bytes((void*)readbuff);
		read_st.reading = (int32_t)reorder_bytes((void*)(&readbuff[4]));
		reading_time = (time_t)read_st.time_of_reading;
		//ADJUST_TIMEZONE(reading_time);

		add_reading_to_csv(comm, &read_st);

		printf("timestamp: %s, data: %d.%03d\n", ctime(&reading_time), read_st.reading/1000, read_st.reading%1000);
		read_B = 0;
	}
	return 0;
}

int main(int argc, char *argv[])
{
		
	comm_struct comm = {0};
	comm.csv_file_fd = comm.uart_dev_fd = -1;
	if(argc == 1)
		comm.dev_name[0] = '\0';
	else if(argc == 2)
	{
		snprintf(comm.dev_name, 10, "%s", argv[1]);
	}
	else
	{
		printf("Invalid arguments passed.\n");
		return -1;
	}
	
	if(0 != init_comm_struct(&comm))
		return -1;

	receive_data(&comm);
	
	destroy_comm_struct(&comm);
	return 0;

}
