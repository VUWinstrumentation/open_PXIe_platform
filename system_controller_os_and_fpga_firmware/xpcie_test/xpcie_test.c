#include <sys/wait.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <termios.h>
#include <fcntl.h>
#include <errno.h>
#include <time.h>

#define MAX_DEVS 10
#define MAX_TRANSFER_SIZE 8388607
#define MAX_BUF 0x100000
#define SET_DMA 1
#define SET_PIO 2
#define RESET_DMA 3
#define STREAMING_DMA 4
#define COHERENT_DMA 5
#define TRANS_TIME 6
#define TRANS_SPEED 7
#define DDR_START 0x00100000

char default_name[] = "/dev/xpcie_1";
char *read_buf;
char *write_buf;

int test_memory(int fd, int size, int iter);
int write_data(int fd, unsigned char *data, int pos, int size);
int read_data(int fd, unsigned char *data, int pos, int size);

int test_memory(int fd, int size, int iter)
{
	unsigned int read_data_buf[size];  
	unsigned int write_data_buf[size];

	int i, j, err_cnt, test_pass;

	test_pass = 0;

	for (j = 0; j < iter; j++) 
	{
		err_cnt = 0;
		for (i = 0; i < size; i++)
			write_data_buf[i]=rand();

		if (lseek(fd, 0x00000000, SEEK_SET) < 0){
		    	perror("Failed to seek");
    			exit(1);
  		}
		write(fd, (unsigned char *) write_data_buf, sizeof(int)*size);
		
		//write_data(fd, (unsigned char *)write_data, 0x00000000, sizeof(int)*size);

		if (lseek(fd, 0x00000000, SEEK_SET) < 0){
		    	perror("Failed to seek");
    			exit(1);
  		}
		read(fd, (unsigned char *) read_data_buf, sizeof(int)*size);

		//read_data(fd, (unsigned char *)read_data, 0x00000000, sizeof(int)*size);
		
		for (i = 0; i < size; i++){
			if (read_data_buf[i]!=write_data_buf[i]){
				printf("Error! At data location [%d] -> expected %x : found %x\n", i, write_data_buf[i], read_data_buf[i]);
				err_cnt++;
			}
		}
		printf("Iteration [%d] -> %d errors found\n", j, err_cnt);

		if (err_cnt == 0)
			test_pass++;
	}
	printf("%d tests run where %d transfered successfully\n", j, test_pass);
	return 0;
}

int write_data(int fd, unsigned char *data, int pos, int size)
{
	if (lseek(fd, pos, SEEK_SET) < 0){
		perror("Failed to seek");
		exit(1);
	}
	int ret = write(fd, data, size);
	return ret;
}

int read_data(int fd, unsigned char *data, int pos, int size)
{
	
	if (lseek(fd, pos, SEEK_SET) < 0){
		perror("Failed to seek");
		exit(1);
	}
	int ret = read(fd, data, size);
	return ret;
}

int main()
{
	char *dev_name = NULL;
	int fd, size, iter, err_cnt, tran_time, tran_speed;
	unsigned int address;
	unsigned int r_dw, w_dw;
	unsigned int *r_data, *w_data;
	char *line = NULL;
	size_t len = 0;
	ssize_t read;
	char *p;
	char c;
	int i;
	int base = 16;

	r_data = (unsigned int *)malloc(MAX_BUF);
	w_data = (unsigned int *)malloc(MAX_BUF);

	fd = -1;

	while (fd < 0) {
		printf("Enter name of device node: ");
		read = getline(&dev_name, &len, stdin);
		size = strlen(dev_name);
    	dev_name[size-1] = 0;
		fd = open(dev_name, O_RDWR);
		if (fd < 0)
			perror("Failed to open dev file. Try another device name");
	}


  	srand (time(NULL));

  	printf("Application to test aspects of xpcie device and device driver\n"
  			"Enter a character to perform a task\n"
  			"Enter 'h' for information on possible tasks\n");

	while(1){
		printf(	"Enter a character to perform a task\n"
  				"Enter 'h' for information on possible tasks\n");
		read = getline(&line, &len, stdin);
		c = *line;
		switch (c){
		case 'h':
			printf(	"Enter 'b' to set the radix of user input data\n"
			"Enter 'i' to initialise write data buffer with random data for manual memory transfer test\n"
			"Enter 'm' to perform memory endpoint test\n"
			"Enter 'd' to run a demo memory test\n"
			"Enter 'w' to write DW to a particular endpoint memory location\n"
			"Enter 'r' to read DW from a particular endpoint memory location\n"
			"Enter 'f' to perform manual memory transfer test of user write data buffer to endpoint\n"
			"Enter 'e' to perform manual memory transfer test of endpoint data to user read buffer\n"
			"Enter 't' for time taken for previous transfer\n"
			"Enter 'a' for previous transfer speed\n"
			"Enter 'v' to print contents of write buffer and read buffer\n"
			"Enter 'g' to reset CDMA unit\n"
			"Enter 'o' to open a different device node\n"
			"Enter 'p' to print out currently open device node\n"
			"Enter 's' to set transfer mode to streaming DMA, coherent DMA or PIO\n"
			"Enter 'c' to compare user write data to user read data\n"
			"Enter 'q' to quit the application\n"
			"----------------------------------------\r\n");
			break;
		case 'b':
			printf("Radix of user data? Enter 'd' for decimel and 'h' for hex: ");
			read = getline(&line, &len, stdin);
			c = *line;
			switch(c){
			case 'd':
				base = 10;
				break;
			case 'h':
				base = 16;
				break;
			default:
				printf("Invalid argument!\n");
				break;
			}
			break;
		case 'i':
			printf("Set number of random integers to initialise: ");
			read = getline(&line, &len, stdin);
			size = strtol(line, &p, base);
			printf("Set index of write data buffer to start from: ");
			read = getline(&line, &len, stdin);
			address = strtol(line, &p, base);
			for(i = address; i < size; i++)
				w_data[i] = rand();
			break;
		case 's':
			printf("Mode of operation? Enter 's' for streaming DMA, 'c' for coherent DMA or 'p' for PIO: ");
			read = getline(&line, &len, stdin);
			c = *line;
			switch(c){
			case 'c':
				ioctl(fd, SET_DMA, 0);
				ioctl(fd, COHERENT_DMA, 0);
				break;
			case 's':
				ioctl(fd, SET_DMA, 0);
				ioctl(fd, STREAMING_DMA, 0);
				break;
			case 'p':
				ioctl(fd, SET_PIO, 0);
				break;
			default:
				printf("Invalid argument!\n");
				break;
			}
			break;
		case 'm':
			printf("Set number of random integers to read/write: ");
			read = getline(&line, &len, stdin);
			size = strtol(line, &p, 10);
			printf("Set number of cycles to test: ");
			read = getline(&line, &len, stdin);
			iter = strtol(line, &p, 10);
			test_memory(fd, size, iter);
			break;
		case 'w':
			printf("Enter data to write: ");
			read = getline(&line, &len, stdin);
			w_dw = strtol(line, &p, base);
			printf("Enter address to write to: ");
			read = getline(&line, &len, stdin);
			address = strtol(line, &p, base);
			write_data(fd, (unsigned char *)&w_dw, address, 4);
			printf("Write to address 0x%x: 0x%x\n", address, w_dw);
			break;
		case 'r':
			printf("Enter address to read: ");
			read = getline(&line, &len, stdin);
			address = strtol(line, &p, base);
			read_data(fd, (unsigned char *)&r_dw, address, 4);
			printf("Read from address 0x%x: 0x%x\n", address, r_dw);
			break;
		case 'f':
			printf("Enter address to write to: ");
			read = getline(&line, &len, stdin);
			address = strtol(line, &p, base);
			printf("Enter length of data to write: ");
			read = getline(&line, &len, stdin);
			size = strtol(line, &p, base);
			write_data(fd, (unsigned char *)w_data, address, size);
			break;
		case 'e':
			printf("Enter address to read: ");
			read = getline(&line, &len, stdin);
			address = strtol(line, &p, base);
			printf("Enter length of data to read: ");
			read = getline(&line, &len, stdin);
			size = strtol(line, &p, base);
			read_data(fd, (unsigned char *)r_data, address, size);
			break;
		case 't':
			tran_time = ioctl(fd, TRANS_TIME, 0);
			printf("Last transfer took %d ns\n", tran_time);
			break;
		case 'a':
			tran_speed = ioctl(fd, TRANS_SPEED, 0);
			printf("Last transfer ran at %d MB/s\n", tran_speed);
			break;
		case 'v':
			printf("Number of items print: ");
			read = getline(&line, &len, stdin);
			size = strtol(line, &p, base);
			for(i = 0; i < size; i++)
				printf("Write data: %x Read data: %x\n", w_data[i], r_data[i]);
			break;
		case 'c':
			err_cnt = 0;
			for (i = 0; i < size; i++) {
				if (r_data[i]!=w_data[i]){
					printf("Error! At data location [%d] -> expected %x : found %x\n", i, w_data[i], r_data[i]);
					err_cnt++;
				}
			}
			printf("Total of [%d] errors found\n", err_cnt);
			break;
		case 'g':
			ioctl(fd, RESET_DMA, 0);
			break;
		case 'o':
			printf("Enter name of device node: ");
			read = getline(&dev_name, &len, stdin);
			size = strlen(dev_name);
    		dev_name[size-1] = 0;
			close(fd);
			fd = open(dev_name, O_RDWR);
			if (fd < 0)  {
				perror("Failed to open dev file. Reopening default dev file");
				dev_name = default_name;
				fd = open(dev_name, O_RDWR);
				if (fd < 0) {
    					perror("Failed to open devfile");
    					exit(1);
  				}
			}
			break;
		case 'p':
			printf("Currently using %s\n", dev_name);
			break;
		case 'd':
			printf("Running memory test of 64 DWs for 64 iterations");
			test_memory(fd, 64, 64);
			break;
		case 'q':
			close(fd);
			free(r_data);
			free(w_data);
			return 0;
		default:
			printf("Invalid option!\n");
			break;
		}
	}
	return 0;
}
