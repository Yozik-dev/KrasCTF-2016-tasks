.PHONY: all clean

CC      = gcc
CFLAGS  = -Wall -pedantic
LDFLAGS =

SRC_FOLDER = src
OUT_FOLDER = bin

SRC = $(wildcard $(SRC_FOLDER)/*.c)
OBJ = $(SRC:.c=.o)
OUT = $(OUT_FOLDER)/rev100-decode

all: $(OBJ)
	@mkdir -pv $(OUT_FOLDER)
	$(CC) $(OBJ) -o $(OUT) $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	@rm -vf $(OBJ)
	@rm -vf $(OUT)
