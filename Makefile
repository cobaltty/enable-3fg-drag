CC      ?= cc
CFLAGS  ?= -O2 -Wall -Wextra -fPIC
LDFLAGS ?= -shared

TARGET  := libenable-3fg-drag.so
SRC     := enable-3fg-drag.c

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $< -ldl

clean:
	rm -f $(TARGET)

.PHONY: clean
