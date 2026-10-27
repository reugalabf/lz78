CC      = gcc
CFLAGS  ?= -O2 -Wall -Wextra -std=c99
LDFLAGS ?=

TARGET  := lz78
SRC     := lz78.c
OBJ     := $(SRC:.c=.o)

.PHONY: all clean test debug

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(LDFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

debug: CFLAGS := -O0 -g -Wall -Wextra -std=c99 -fsanitize=address,undefined
debug: LDFLAGS := -fsanitize=address,undefined
debug: clean $(TARGET)

# Round-trip test: compress, decompress, compare.
test: $(TARGET)
	@printf 'abababcabcabcd' > test_small.txt
	@yes "hello world" | head -c 100000 > test_big.txt
	@for f in test_small.txt test_big.txt; do \
		./$(TARGET) c $$f $$f.lz && \
		./$(TARGET) d $$f.lz $$f.out && \
		cmp -s $$f $$f.out && \
		echo "PASS $$f ($$(wc -c < $$f) -> $$(wc -c < $$f.lz) bytes)" || \
		{ echo "FAIL $$f"; exit 1; }; \
	done
	@rm -f test_small.txt* test_big.txt*

clean:
	rm -f $(TARGET) $(OBJ) test_*.txt*
