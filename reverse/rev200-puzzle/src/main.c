#include <stdio.h>
#include <pthread.h>
#include <errno.h>
#include <sys/wait.h>
#include <sys/mman.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <string.h>
#include <stdbool.h>

#define PASSWORD_LENGTH		0x10
#define WORKER_PROCESS_COUNT	0x07

typedef struct {
	pid_t pid;
	pthread_barrier_t barrier;
} worker_process_t;

typedef enum {
	WORKER_CHECK_TRANSFORMED = 0x0,
	WORKER_INIT_SHUFFLE_ONE  = 0x1,
	WORKER_INIT_SHUFFLE_TWO  = 0x2,
	WORKER_INIT_XOR_ONE      = 0x3,
	WORKER_INIT_XOR_TWO      = 0x4,
	WORKER_DO_SHUFFLE        = 0x5,
	WORKER_DO_XOR            = 0x6
} worker_process_id_t;

typedef struct {
	worker_process_t workers[WORKER_PROCESS_COUNT];
	uint8_t password[PASSWORD_LENGTH];
	uint8_t shuffle_table[PASSWORD_LENGTH];
	uint8_t xor_table[PASSWORD_LENGTH];
	worker_process_id_t hidden_process_id;
} pshared_state_t;

typedef int (*worker_fn)(pshared_state_t *, size_t);


static int init_worker_process(pshared_state_t *state, size_t id, worker_fn fn)
{
	pthread_barrierattr_t attr;
	if (id >= WORKER_PROCESS_COUNT)
		return EINVAL;
	pthread_barrierattr_init(&attr);
	pthread_barrierattr_setpshared(&attr, PTHREAD_PROCESS_SHARED);
	pthread_barrier_init(&state->workers[id].barrier, &attr, 2);
	pthread_barrierattr_destroy(&attr);
	if ((state->workers[id].pid = fork()) == 0)
		exit(fn(state, id));
	return 0;
}

static worker_process_t *find_worker_process(pshared_state_t *state, size_t id)
{
	if (id >= WORKER_PROCESS_COUNT)
		return NULL;
	return &state->workers[id];
}

static int consume_worker_process(pshared_state_t *state, size_t id)
{
	worker_process_t *worker = find_worker_process(state, id);
	pthread_barrier_wait(&worker->barrier);
	waitpid(worker->pid, NULL, 0);
	pthread_barrier_destroy(&worker->barrier);
	return 0;
}

static int worker_init_xor_one(pshared_state_t *state, size_t id)
{
	worker_process_t *self = find_worker_process(state, id);
	pthread_barrier_wait(&self->barrier);
	state->xor_table[0x0] = 0xFE;
	state->xor_table[0x1] = 0x51;
	state->xor_table[0x2] = 0x07;
	state->xor_table[0x3] = 0x3D;
	state->xor_table[0x4] = 0x5D;
	state->xor_table[0x5] = 0x85;
	state->xor_table[0x6] = 0xEB;
	state->xor_table[0x7] = 0x60;
	state->xor_table[0x8] = 0x7A;
	state->xor_table[0x9] = 0xC1;
	state->xor_table[0xA] = 0x4B;
	state->xor_table[0xB] = 0x54;
	state->xor_table[0xC] = 0x7A;
	state->xor_table[0xD] = 0xA0;
	state->xor_table[0xE] = 0xDD;
	state->xor_table[0xF] = 0x99;
	return EXIT_SUCCESS;
}

static int worker_init_shuffle_two(pshared_state_t *state, size_t id)
{
	worker_process_t *self = find_worker_process(state, id);
	pthread_barrier_wait(&self->barrier);
	state->shuffle_table[0x0] = 0x7;
	state->shuffle_table[0x1] = 0x5;
	state->shuffle_table[0x2] = 0xF;
	state->shuffle_table[0x3] = 0x8;
	state->shuffle_table[0x4] = 0x6;
	state->shuffle_table[0x5] = 0xE;
	state->shuffle_table[0x6] = 0x0;
	state->shuffle_table[0x7] = 0x1;
	state->shuffle_table[0x8] = 0xC;
	state->shuffle_table[0x9] = 0xA;
	state->shuffle_table[0xA] = 0x9;
	state->shuffle_table[0xB] = 0xD;
	state->shuffle_table[0xC] = 0x4;
	state->shuffle_table[0xD] = 0x3;
	state->shuffle_table[0xE] = 0xB;
	state->shuffle_table[0xF] = 0x2;
	init_worker_process(state, WORKER_INIT_XOR_ONE, worker_init_xor_one);
	state->hidden_process_id = WORKER_INIT_XOR_ONE;
	return EXIT_SUCCESS;
}

static int worker_init_xor_two(pshared_state_t *state, size_t id)
{
	worker_process_t *self = find_worker_process(state, id);
	pthread_barrier_wait(&self->barrier);
	state->xor_table[0x0] = 0x49;
	state->xor_table[0x1] = 0xC8;
	state->xor_table[0x2] = 0x05;
	state->xor_table[0x3] = 0x10;
	state->xor_table[0x4] = 0x0F;
	state->xor_table[0x5] = 0x1A;
	state->xor_table[0x6] = 0xD4;
	state->xor_table[0x7] = 0x0F;
	state->xor_table[0x8] = 0xEA;
	state->xor_table[0x9] = 0x1E;
	state->xor_table[0xA] = 0x0A;
	state->xor_table[0xB] = 0x7C;
	state->xor_table[0xC] = 0xD9;
	state->xor_table[0xD] = 0x06;
	state->xor_table[0xE] = 0xFC;
	state->xor_table[0xF] = 0x14;
	init_worker_process(state, WORKER_INIT_SHUFFLE_TWO, 
			    worker_init_shuffle_two);
	state->hidden_process_id = WORKER_INIT_SHUFFLE_TWO;
	return EXIT_SUCCESS;
}

static int worker_init_shuffle_one(pshared_state_t *state, size_t id)
{
	worker_process_t *self = find_worker_process(state, id);
	pthread_barrier_wait(&self->barrier);
	state->shuffle_table[0x0] = 0x0;
	state->shuffle_table[0x1] = 0xC;
	state->shuffle_table[0x2] = 0xA;
	state->shuffle_table[0x3] = 0xF;
	state->shuffle_table[0x4] = 0x4;
	state->shuffle_table[0x5] = 0x5;
	state->shuffle_table[0x6] = 0x3;
	state->shuffle_table[0x7] = 0x7;
	state->shuffle_table[0x8] = 0xD;
	state->shuffle_table[0x9] = 0x1;
	state->shuffle_table[0xA] = 0x9;
	state->shuffle_table[0xB] = 0x6;
	state->shuffle_table[0xC] = 0xE;
	state->shuffle_table[0xD] = 0x2;
	state->shuffle_table[0xE] = 0xB;
	state->shuffle_table[0xF] = 0x8;
	init_worker_process(state, WORKER_INIT_XOR_TWO, worker_init_xor_two);
	state->hidden_process_id = WORKER_INIT_XOR_TWO;
	return EXIT_SUCCESS;
}

static int worker_do_shuffle(pshared_state_t *state, size_t id)
{
	worker_process_t *self = find_worker_process(state, id);
	pthread_barrier_wait(&self->barrier);
	for (size_t i = 0; i < PASSWORD_LENGTH; ++i) {
		uint8_t temp = state->password[i];
		state->password[i] = state->password[state->shuffle_table[i]];
		state->password[state->shuffle_table[i]] = temp;
	}
	consume_worker_process(state, state->hidden_process_id);
	return EXIT_SUCCESS;
}

static int worker_do_xor(pshared_state_t *state, size_t id)
{
	worker_process_t *self = find_worker_process(state, id);
	pthread_barrier_wait(&self->barrier);
	for (size_t i = 0; i < PASSWORD_LENGTH; ++i)
		state->password[i] ^= state->xor_table[i];
	return EXIT_SUCCESS;
}

static int worker_check_transformed(pshared_state_t *state, size_t id)
{
	worker_process_t *self = find_worker_process(state, id);
	pthread_barrier_wait(&self->barrier);

	init_worker_process(state, WORKER_INIT_SHUFFLE_ONE,
			    worker_init_shuffle_one);
	init_worker_process(state, WORKER_INIT_XOR_ONE, worker_init_xor_one);
	consume_worker_process(state, WORKER_INIT_XOR_ONE);
	consume_worker_process(state, WORKER_INIT_SHUFFLE_ONE);

	init_worker_process(state, WORKER_DO_XOR, worker_do_xor);
	init_worker_process(state, WORKER_DO_SHUFFLE, worker_do_shuffle);
	consume_worker_process(state, WORKER_DO_XOR);
	consume_worker_process(state, WORKER_DO_SHUFFLE);

	init_worker_process(state, WORKER_DO_XOR, worker_do_xor);
	consume_worker_process(state, WORKER_DO_XOR);
	/* consume INIT_SHUFFLE_TWO */
	consume_worker_process(state, state->hidden_process_id);
	init_worker_process(state, WORKER_DO_SHUFFLE, worker_do_shuffle);
	consume_worker_process(state, WORKER_DO_SHUFFLE);
	return EXIT_SUCCESS;
}

static bool is_password_correct(pshared_state_t *state)
{
	uint8_t enc_passwd[PASSWORD_LENGTH] = {
		0x3C, 0x8E, 0x4F, 0x47, 0x96, 0x5E, 0x18, 0xDE,
		0x75, 0x28, 0x5D, 0x3A, 0xC6, 0xE6, 0x01, 0x85
	};
	return memcmp(enc_passwd, state->password, PASSWORD_LENGTH) == 0;
}

int main(int argc, char **argv)
{
	static pshared_state_t *state = NULL;
	if (argc != 2 || strlen(argv[1]) != PASSWORD_LENGTH)
		return EXIT_FAILURE;
	state = mmap(NULL, sizeof(pshared_state_t), PROT_READ | PROT_WRITE,
		     MAP_SHARED | MAP_ANONYMOUS, -1, 0);
	if (state == MAP_FAILED)
		return EXIT_FAILURE;
	strncpy((char *) state->password, argv[1], PASSWORD_LENGTH);
	init_worker_process(state, WORKER_CHECK_TRANSFORMED,
			    worker_check_transformed);
	consume_worker_process(state, WORKER_CHECK_TRANSFORMED);
	if (is_password_correct(state))
		write(STDOUT_FILENO, "OK\n", 3);
	munmap(state, sizeof(pshared_state_t));
	return EXIT_SUCCESS;
}
