# Build with: make build
# Validate with: make test
# Interactive benchmark: make bench
# Noninteractive benchmark: make bench N=10000000

CC ?= cc
PYTHON ?= python3
CFLAGS = -std=c11 -Wall -Wextra -Wpedantic

.PHONY: all build test bench clean help
all: build
build: findprimes_O0 findprimes_O2

findprimes_O0: findprimes.c
	$(CC) $(CFLAGS) -O0 -o $@ $<

findprimes_O2: findprimes.c
	$(CC) $(CFLAGS) -O2 -o $@ $<

test: build
	$(PYTHON) verify.py

# Each recipe line normally runs in a separate shell; use a single shell block.
bench: test
	@command -v hyperfine >/dev/null 2>&1 || { echo 'Hyperfine not found. On macOS: brew install hyperfine'; exit 1; }; \
	limit='$(N)'; \
	if [ -z "$$limit" ]; then \
		printf 'Upper limit for primes (e.g. 10000000): '; \
		IFS= read -r limit || exit 1; \
	fi; \
	case "$$limit" in ''|*[!0-9]*) echo 'Error: enter a nonnegative whole number.' >&2; exit 1;; esac; \
	printf '\nChecking matching output for limit %s...\n' "$$limit"; \
	a=$$(./findprimes_O0 "$$limit") || exit 1; \
	b=$$(./findprimes_O2 "$$limit") || exit 1; \
	c=$$($(PYTHON) findprimes.py "$$limit") || exit 1; \
	if [ "$$a" != "$$b" ] || [ "$$a" != "$$c" ]; then \
		echo 'Error: implementations disagree; benchmark cancelled.' >&2; \
		printf 'C -O0: %s\nC -O2: %s\nPython: %s\n' "$$a" "$$b" "$$c"; exit 1; \
	fi; \
	printf 'PASS: %s\n\n' "$$a"; \
	printf 'Benchmarking all three implementations...\n'; \
	hyperfine --warmup 3 --runs 30 \
		"./findprimes_O0 $$limit" \
		"./findprimes_O2 $$limit" \
		"$(PYTHON) findprimes.py $$limit"

clean:
	rm -f findprimes_O0 findprimes_O2

help:
	@printf 'make build        Compile both C executables\nmake test         Compile and check known results\nmake bench        Prompt for limit, verify outputs, run Hyperfine\nmake bench N=...  Run benchmark without prompting\nmake clean        Remove built executables and benchmark JSON\n'
