#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <sys/ptrace.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stddef.h>
#include <sys/wait.h>
#include <stdbool.h>
#include <stdint.h>

#include "bin_layout.h"
#include "md5.h"

#define __init(x) __attribute__((constructor(x)))

#define INIT_HANDLERS_COUNT	3
#define SIGNAL_HANDLERS_COUNT	4
#define BASE_INIT_INDX		102
#define IO_HANDLER_ID		0
#define USR1_HANDLER_ID		1
#define USR2_HANDLER_ID		2
#define FAKE_IO_HANDLER_ID	3

#define FLAG_BUFFER_SIZE	128

typedef int (*init_handler_t)(void);
typedef void (*signal_handler_t)(int);

typedef struct call_table {
	unsigned char data_0[0x07];
	init_handler_t init_functions[INIT_HANDLERS_COUNT];
	unsigned char data_1[0x10];
	signal_handler_t signal_handlers[SIGNAL_HANDLERS_COUNT];
	unsigned char data_2[0x06];
} call_table_t;

static int set_usr1_handler();
static int set_usr2_handler();
static int set_io_handler();

static void io_signal_handler();
static void fake_io_signal_handler();
static void usr1_signal_handler();
static void usr2_signal_handler();

__to_section(LAYOUT_DATA_SECTION) 
static const call_table_t GLOBAL_CALL_TABLE = {
	.data_0 = {0x1E, 0x30, 0xF7, 0x08, 0x5D, 0x00, 0xFC},
	.init_functions = {
		set_io_handler,
		set_usr1_handler,
		set_usr2_handler
	},
	.data_1 = {
		0x67, 0x04, 0xFE, 0x08, 0xAF, 0x25, 0xD5, 0x08,
		0xE6, 0x11, 0x01, 0xBF, 0x08, 0x04, 0xD1, 0xF0
	},
	.signal_handlers = {
		io_signal_handler,
		usr1_signal_handler,
		usr2_signal_handler,
		fake_io_signal_handler
	},
	.data_2 = { 0x2A, 0x22, 0xA7, 0x08, 0x73, 0x9F }
};

__always_inline static init_handler_t init_handler_pointer(int indx)
{
	unsigned char *call_table  = (unsigned char *) &GLOBAL_CALL_TABLE;
	unsigned int init_fn_off   = offsetof(struct call_table, init_functions);
	init_handler_t *init_fns   = (init_handler_t *) (call_table + init_fn_off);
	return init_fns[indx];
}

__always_inline static signal_handler_t signal_handler_pointer(int indx)
{
	unsigned char *call_table  = (unsigned char *) &GLOBAL_CALL_TABLE;
	unsigned int sig_fn_off    = offsetof(struct call_table, signal_handlers);
	signal_handler_t *sig_fns  = (signal_handler_t *) (call_table + sig_fn_off);
	return sig_fns[indx];
}

__always_inline 
static bool match_file_content(const char *file_path, const char *pattern)
{
	char file_buf[1024] = {0};
	int file_fd  = open(file_path, O_RDONLY);
	if (file_fd == -1)
		return false;
	if (read(file_fd, file_buf, sizeof(file_buf) - 1) == -1)
		return false;
	close(file_fd);
	return strstr(file_buf, pattern) != NULL;
}

__always_inline static void xor_decode(uint8_t *buf, size_t len, uint8_t key)
{
	for (int i = 0; i < len; ++i)
		buf[i] ^= key;
}

__always_inline static bool is_debugger_present()
{
	uint64_t file_path[3] = {
		0x1B0D511D110C0E51, 0x0B0A1F0A0D511812, 0x000000000000000D
	};
	uint64_t pattern[2] = {	0x033A180F090B183E, 0x000000005A63500E };

	xor_decode((uint8_t *) file_path, 0x11, 0x7E);
	xor_decode((uint8_t *) pattern, 0x0C, 0x6A);
	return !match_file_content((char *) file_path, (char *) pattern);
}

__to_section(LAYOUT_CODE_SECTION)
static void md5sum(const uint8_t *buffer, size_t size, uint8_t *digest)
{
	MD5_CTX md5_ctx;
	MD5Init(&md5_ctx);
	MD5Update(&md5_ctx, buffer, size);
	MD5Final(digest, &md5_ctx);
}

__to_section(LAYOUT_CODE_SECTION)
static int verify_password_hash(const char *password, size_t len, uint8_t *hash)
{
	uint8_t digest[MD5_DIGEST_LENGTH] = {0};
	md5sum((uint8_t *) password, len, digest);
	return memcmp(hash, digest, MD5_DIGEST_LENGTH);
}

__to_section(LAYOUT_CODE_SECTION) 
static bool is_password_correct(const char *password)
{
	uint8_t md5_rivest[MD5_DIGEST_LENGTH] = {
		0x6f, 0xbf, 0x6c, 0x78, 0xd5, 0x43, 0xdb, 0xbb,
		0x91, 0x1d, 0xa0, 0x12, 0x4f, 0x2b, 0x0a, 0xf5
	};
	uint8_t md5_shamir[MD5_DIGEST_LENGTH] = {
		0x29, 0x35, 0x31, 0x33, 0x91, 0x25, 0x2c, 0x1b,
		0x41, 0x04, 0x07, 0x49, 0x5c, 0xd0, 0x96, 0xfe
	};
	uint8_t md5_adleman[MD5_DIGEST_LENGTH] = {
		0x7b, 0x59, 0x3c, 0x8b, 0x95, 0x5e, 0x45, 0x79,
		0x9c, 0x6c, 0xe2, 0x95, 0x0b, 0xec, 0xa6, 0x86
	};

	if (strlen(password) != 0x14)
		return false;
	if (verify_password_hash(password, 6, md5_rivest) != 0)
		return false;
	if (verify_password_hash(password + 6, 6, md5_shamir) != 0)
		return false;
	if (verify_password_hash(password + 12, 7, md5_adleman) != 0)
		return false;
	return true;
}

__to_section(LAYOUT_CODE_SECTION) static void io_signal_handler(int sig)
{
	char buf[FLAG_BUFFER_SIZE] = {0};
	if (sig != SIGIO)
		return;
	if (read(STDIN_FILENO, buf, sizeof(buf) - 1) == -1)
		return;
	if (is_password_correct(buf))
		raise(SIGUSR1);
	else
		raise(SIGUSR2);
}

__to_section(LAYOUT_CODE_SECTION) static void print_error_message()
{
	uint64_t error_msg = 0x00249E1ECB27;
	error_msg += 0x0A22B0308730;
	write(STDERR_FILENO, &error_msg, 6);
}

__to_section(LAYOUT_CODE_SECTION) static void print_success_message()
{
	uint64_t success_msg = 0x000A22B0308730F3;
	success_msg += 0x0A4A209521CB1E50;
	write(STDERR_FILENO, &success_msg, 8);
}

__to_section(LAYOUT_CODE_SECTION) static void fake_io_signal_handler(int sig)
{
	char buf[FLAG_BUFFER_SIZE] = {0};
	read(STDIN_FILENO, buf, sizeof(buf));
	print_error_message();
	_exit(EXIT_SUCCESS);
}

__to_section(LAYOUT_CODE_SECTION) static void usr1_signal_handler(int sig)
{
	print_success_message();
	_exit(EXIT_SUCCESS);
}

__to_section(LAYOUT_CODE_SECTION) static void usr2_signal_handler(int sig)
{
	print_error_message();
	_exit(EXIT_SUCCESS);
}

__to_section(LAYOUT_CODE_SECTION) static int set_io_handler()
{
	struct sigaction sig_act;
	int fd_flags = 0;

	sigemptyset(&sig_act.sa_mask);
	sig_act.sa_flags = SA_RESTART;
	if (is_debugger_present())
		sig_act.sa_handler = signal_handler_pointer(FAKE_IO_HANDLER_ID);
	else
		sig_act.sa_handler = signal_handler_pointer(IO_HANDLER_ID);
	if (sigaction(SIGIO, &sig_act, NULL) == -1)
		return -1;
	fcntl(STDIN_FILENO, F_SETOWN, getpid());
	fd_flags = fcntl(STDIN_FILENO, F_GETFL);
	fcntl(STDIN_FILENO, F_SETFL, fd_flags | O_ASYNC | O_NONBLOCK);
	return 0;
}

__to_section(LAYOUT_CODE_SECTION) static int set_usr1_handler()
{
	struct sigaction sig_act;
	sigemptyset(&sig_act.sa_mask);
	sig_act.sa_flags = SA_RESTART;
	sig_act.sa_handler = signal_handler_pointer(USR1_HANDLER_ID);
	return sigaction(SIGUSR1, &sig_act, NULL);
}

__to_section(LAYOUT_CODE_SECTION) static int set_usr2_handler()
{
	struct sigaction sig_act;
	sigemptyset(&sig_act.sa_mask);
	sig_act.sa_flags = SA_RESTART;
	sig_act.sa_handler = signal_handler_pointer(USR2_HANDLER_ID);
	return sigaction(SIGUSR2, &sig_act, NULL);
}

__to_section(LAYOUT_CODE_SECTION)
__init(BASE_INIT_INDX + IO_HANDLER_ID) static void init_io_handlers()
{
	init_handler_pointer(IO_HANDLER_ID)();
}

__to_section(LAYOUT_CODE_SECTION)
__init(BASE_INIT_INDX + USR1_HANDLER_ID) static void init_usr1_handler()
{
	if (!is_debugger_present())
		init_handler_pointer(USR1_HANDLER_ID)();
}

__to_section(LAYOUT_CODE_SECTION)
__init(BASE_INIT_INDX + USR2_HANDLER_ID) static void init_usr2_handler()
{
	if (!is_debugger_present())
		init_handler_pointer(USR2_HANDLER_ID)();
}

static int wait_term_signal()
{
	sigset_t wait_set;
	int sig;
	sigemptyset(&wait_set);
	sigaddset(&wait_set, SIGQUIT);
	return sigwait(&wait_set, &sig);
}

int main(int argc, char **argv)
{
	write(STDERR_FILENO, "FLAG: ", 6);
	return wait_term_signal();
}
