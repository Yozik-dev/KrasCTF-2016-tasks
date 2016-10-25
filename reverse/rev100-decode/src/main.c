#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <errno.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>

typedef struct __attribute__((packed)) {
	uint32_t w0;
	uint32_t w1;
	uint32_t w2;
	uint32_t w3;
	uint32_t w4;
	uint32_t w5;
	uint32_t w6;
	uint16_t h0;
} password_t;

typedef struct {
	uint8_t *buffer;
	size_t   size;
} image_bitmap_t;

static int load_image_bitmap(image_bitmap_t *image, const char *path)
{
	struct stat image_stat;
	int file_fd = -1;

	if ((file_fd = open(path, O_RDONLY)) == -1) {
		perror("unable to load bitmap");
		return errno;
	}
	memset(&image_stat, 0, sizeof(image_stat));
	if (fstat(file_fd, &image_stat) == -1) {
		close(file_fd);
		return errno;
	}
	memset(image, 0, sizeof(*image));
	image->size   = image_stat.st_size;
	image->buffer = calloc(image->size, sizeof(uint8_t));
	if (image->buffer == NULL) {
		close(file_fd);
		return errno;
	}
	if (read(file_fd, image->buffer, image->size) == -1) {
		close(file_fd);
		free(image->buffer);
		return errno;
	}
	close(file_fd);
	return 0;
}

static int write_image_bitmap(const image_bitmap_t *image, const char *path)
{
	int file_fd = -1;
	int rv = 0;
	if ((file_fd = open(path, O_WRONLY | O_CREAT, S_IRUSR | S_IWUSR)) == -1)
		return errno;
	if (write(file_fd, image->buffer, image->size) == -1)
		rv = errno;
	close(file_fd);
	return rv;
}

static void free_image_bitmap(image_bitmap_t *image)
{
	free(image->buffer);
}

static int shuffle_image_bitmap(image_bitmap_t *image, const char *pass)
{
	size_t pass_len = strlen(pass);
	int i;

	for (i = 0; i < image->size; ++i) {
		image->buffer[i] ^= 
			image->buffer[(i + pass[i % pass_len]) % image->size];
		image->buffer[(i + pass[i % pass_len]) % image->size] ^=
			image->buffer[i];
		image->buffer[i] ^= 
			image->buffer[(i + pass[i % pass_len]) % image->size];
	}
	return 0;
}

#ifdef _DEVELOPMENT_VERSION
static int unshuffle_image_bitmap(image_bitmap_t *image, const char *pass)
{
	size_t pass_len = strlen(pass);
	int i;

	for (i = image->size - 1; i >= 0; --i) {
		image->buffer[i] ^= 
			image->buffer[(i + pass[i % pass_len]) % image->size];
		image->buffer[(i + pass[i % pass_len]) % image->size] ^=
			image->buffer[i];
		image->buffer[i] ^= 
			image->buffer[(i + pass[i % pass_len]) % image->size];
	}
	return 0;
}
#else
static int unshuffle_image_bitmap(image_bitmap_t *image, const char *pass)
{
	fprintf(stderr, "error: 'decode' is not supported\n");
	return ENOSYS;
}
#endif

static inline int usage(const char *prog)
{
	fprintf(stderr, "Usage: %s encode <input> <output> 'password'\n", prog);
	return EXIT_FAILURE;
}

static inline int verify_password(const char *pass)
{
	password_t *password = (password_t *) pass;
	if (strlen(pass) != 30)
		return EINVAL;
	if (((password->w0 ^ 0xDEADBEEF) != 0xF0E1F7BF) ||
	    ((password->w1 ^ 0x8BADF00D) != 0xECCC9D44) ||
	    ((password->w2 ^ 0xE011CFD0) != 0x857FE1B5) ||
	    ((password->w3 ^ 0xCAFED00D) != 0x86D9F87A) ||
	    ((password->w4 ^ 0xC00010FF) != 0xE8203CD8) ||
	    ((password->w5 ^ 0x0DEFACED) != 0x21DF9CDE) ||
	    ((password->w6 ^ 0xACCE5555) != 0x9CFE6675) ||
	    ((password->h0 ^ 0xC0DE    ) != 0xE9F7    ))
		return EINVAL;
	return 0;
}

static inline int verify_options(int argc, char **argv)
{
	if (argc != 5) {
		usage(argv[0]);
		return EINVAL;
	}
	if (strlen(argv[2]) == 0 || strlen(argv[3]) == 0 ||
	    strlen(argv[4]) == 0)
		return EINVAL;
	if (verify_password(argv[4]) != 0) {
		fprintf(stderr, "error: invalid password\n");
		return EINVAL;
	}
	return 0;
}

int main(int argc, char **argv)
{
	image_bitmap_t image;
	int exit_code = EXIT_SUCCESS;
	int (*modify_image_bitmap)(image_bitmap_t *image, const char *);

	if (verify_options(argc, argv) != 0)
		return EXIT_FAILURE;
	if (strcmp(argv[1], "encode") == 0)
		modify_image_bitmap = shuffle_image_bitmap;
	else if (strcmp(argv[1], "decode") == 0)
		modify_image_bitmap = unshuffle_image_bitmap;
	else
		return usage(argv[0]);

	if (load_image_bitmap(&image, argv[2]) != 0)
		return EXIT_FAILURE;
	modify_image_bitmap(&image, argv[4]);
	if (write_image_bitmap(&image, argv[3]) != 0)
		exit_code = EXIT_FAILURE;
	free_image_bitmap(&image);
	return exit_code;
}
