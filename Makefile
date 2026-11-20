# Build everything: make build
# Verify all programs: make test
# Prime benchmark: make bench                
# Matrix benchmark: make matrixbench     

CC ?= cc
PYTHON ?= python3
CFLAGS = -std=c11 -Wall -Wextra -Wpedantic

.PHONY: all build test bench matrixbench clean help test-primes test-matrix
all: build
build: findprimes_O0 findprimes_O2 findmatrix_O0 findmatrix_O2

findprimes_O0: findprimes.c
	$(CC) $(CFLAGS) -O0 -o $@ $<

findprimes_O2: findprimes.c
	$(CC) $(CFLAGS) -O2 -o $@ $<

findmatrix_O0: findmatrix.c
	$(CC) $(CFLAGS) -O0 -o $@ $<

findmatrix_O2: findmatrix.c
	$(CC) $(CFLAGS) -O2 -o $@ $<

test: test-primes test-matrix

test-primes: findprimes_O0 findprimes_O2
	$(PYTHON) verify.py

test-matrix: findmatrix_O0 findmatrix_O2
	@$(PYTHON) -c 'import numpy' || { echo 'NumPy not found. Install with: $(PYTHON) -m pip install numpy'; exit 1; }
	@set -e; \
	for n in 1 8 32 64; do \
		a=$$(./findmatrix_O0 "$$n"); \
		b=$$(./findmatrix_O2 "$$n"); \
		c=$$($(PYTHON) findmatrix.py "$$n"); \
		if [ "$$a" != "$$b" ] || [ "$$a" != "$$c" ]; then \
			printf 'FAIL: matrix size %s\nC -O0: %s\nC -O2: %s\nPython: %s\n' "$$n" "$$a" "$$b" "$$c" >&2; exit 1; \
		fi; \
	done; \
	echo 'PASS: matrix outputs agree at sizes 1, 8, 32, 64'

# Each recipe uses one shell block, so its prompted input stays available.
bench: test-primes
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
	printf 'Benchmarking all three prime implementations...\n'; \
	hyperfine --warmup 3 --runs 30 \
		"./findprimes_O0 $$limit" \
		"./findprimes_O2 $$limit" \
		"$(PYTHON) findprimes.py $$limit"

matrixbench: test-matrix
	@command -v hyperfine >/dev/null 2>&1 || { echo 'Hyperfine not found. On macOS: brew install hyperfine'; exit 1; }; \
	n='$(N)'; \
	if [ -z "$$n" ]; then \
		printf 'Matrix size (e.g. 512): '; \
		IFS= read -r n || exit 1; \
	fi; \
	case "$$n" in ''|*[!0-9]*|0) echo 'Error: enter a positive whole number.' >&2; exit 1;; esac; \
	printf '\nChecking matching output for matrix size %s...\n' "$$n"; \
	a=$$(./findmatrix_O0 "$$n") || exit 1; \
	b=$$(./findmatrix_O2 "$$n") || exit 1; \
	c=$$($(PYTHON) findmatrix.py "$$n") || exit 1; \
	if [ "$$a" != "$$b" ] || [ "$$a" != "$$c" ]; then \
		echo 'Error: implementations disagree; benchmark cancelled.' >&2; \
		printf 'C -O0: %s\nC -O2: %s\nPython: %s\n' "$$a" "$$b" "$$c"; exit 1; \
	fi; \
	printf 'PASS: %s\n\n' "$$a"; \
	printf 'Benchmarking all three matrix implementations...\n'; \
	hyperfine --warmup 3 --runs 30 \
		"./findmatrix_O0 $$n" \
		"./findmatrix_O2 $$n" \
		"$(PYTHON) findmatrix.py $$n"

clean:
	rm -f findprimes_O0 findprimes_O2 findmatrix_O0 findmatrix_O2

help:
	@printf 'make build              Compile both C variants for both experiments\nmake test               Validate prime and matrix outputs\nmake bench              Prompt for prime limit, verify, then benchmark\nmake bench N=10000000   Run prime benchmark without prompting\nmake matrixbench        Prompt for matrix size, verify, then benchmark\nmake matrixbench N=512  Run matrix benchmark without prompting\nmake clean              Remove all four compiled C executables\n'