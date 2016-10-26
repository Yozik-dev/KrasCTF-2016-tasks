.PHONY: all clean

ASM      = pasmo
ASMFLAGS = --alocal --tapbas

SRC      = src/main.asm
OUT      = bin/target.tap

all: $(SRC)
	@mkdir -pv bin
	$(ASM) $(ASMFLAGS) $(SRC) $(OUT)

clean:
	@rm -vf $(OUT)
