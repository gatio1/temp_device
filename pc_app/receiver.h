#ifndef RECEIVER_H
#define RECEIVER_H
#include <time.h>
#include <stdint.h>

typedef struct{
	uint32_t reading;
	int32_t time_of_reading;
}reading_struct; 

typedef struct{
	int csv_file_fd;
	char dev_name[10];
	struct termios term; //Terminal configuration
	int uart_dev_fd;
}comm_struct;

int fill_config_for_uart(int uart_fd, struct termios *term);

uint32_t reorder_bytes(void *word);

int add_reading_to_csv(comm_struct *comm, reading_struct *reading);

int receive_data(comm_struct *comm);

int init_comm_struct(comm_struct *comm);

#endif //RECEIVER_H
