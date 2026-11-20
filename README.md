# Performance-Benchmarking-C-vs-Python
An exploration of benchmarking programs to measure and compare their performance in C vs Python.

## Motivation
It is commonly held that interpreted languages increase development speed and codebase maintainability at the cost of performance. This repo explores benchmarking as an investigative means of comparing execution time and memory management between Python and C. 


## Introduction to Benchmarking
- What is Benchmarking?  
  - Benchmarking is the process of measuring and comparing the performance of programs, algorithms, or systems under controlled conditions
- What can be measured with Benchmarking?
  - Execution Time: The length of time it takes for an operation or program to complete
  - Throughput: The amount of work a program can complete per unit of time
  - Memory Usage: The amount of RAM a program consumes during its execution
  - CPU Utilization: The amount of processing capacity a program uses
- Pillars of fair Benchmarking
   - Equivalent algorithms or implementations across languages
   - Same inputs across tests
   - Run multiple trials and use the median results for comparison
   - Avoid unnecessary tasks or work that could impact measured results
   - Ensure the correctness of each program's output

## Tests
This repo uses the Sieve of Eratosthenes algorithm to test the performance of C vs Python programs. It also includes matrix multiplication tests to demonstrate the impact of Python libraries and inequivalent implementations on benchmarks. 

## Interesting Findings
 - Compiler optimization significantly impacts the execution speed of the tested C programs. Using -O2 in place of -O0 led to a 2.7x decrease in execution time
 - Compiler optimization can invalidate benchmarks by replacing loops with constants or by introducing vectorization
 - C executed the Sieve of Eratosthenes algorithm 24.9x (-O2) faster than Python
 - Differing implementations, as seen in the matrix multiplication tests, and the use of NumPy allowed Python to execute 9x faster than C (-O0) in testing

## Using the Repo

The following tools are required:

| Tool | Purpose | Installation |
|------|---------|--------------|
| [Python 3](https://www.python.org/downloads/) | Runs Python programs | `brew install python` |
| [NumPy](https://numpy.org/install/) | Optimized matrix multiplication | `python3 -m pip install numpy` |
| [Hyperfine](https://github.com/sharkdp/hyperfine) | Measures execution times | `brew install hyperfine` |
| GCC / Clang | Compiles C programs | `xcode-select --install` |

**Note:** The installation commands above are intended for macOS. Other operating systems may require different installation methods.

### 2. Download the Repository

Clone this repository using Git:

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git](https://github.com/Attaway7/Performance-Benchmarking-C-vs-Python.git
cd Performance-Benchmarking-C-vs-Python
```

### 3. Set Up Python

Create a virtual environment:

```bash
python3 -m venv .venv
```

Activate it:

```bash
source .venv/bin/activate
```

Install NumPy:

```bash
python3 -m pip install numpy
```

### 6. Run Benchmark Experiments

The Makefile automatically builds the required executables, checks correctness, and runs Hyperfine.

#### Experiment 1: Prime Finding

Run:

```bash
make bench
```

When prompted, enter the maximum number to search for primes:

```text
Upper limit for primes (e.g. 10000000): 10000000
```

#### Experiment 2: Matrix Multiplication

Run:

```bash
make matrixbench
```

When prompted, enter the matrix dimension:

```text
Matrix size (e.g. 512): 512
```

This multiplies two 512 × 512 matrices.

### 7. Understanding the Results

Each benchmark compares three implementations:

| Implementation | Description |
|----------------|-------------|
| C (`-O0`) | Compiled without optimization |
| C (`-O2`) | Compiled with optimization enabled |
| Python | Standard Python for prime finding; NumPy for matrix multiplication |

Hyperfine performs:
- **3 warmup runs** before recording measurements.
- **30 timed runs** for each implementation.
- Statistical analysis of execution times, including the mean, standard deviation, and relative performance.

Lower execution times indicate better performance.

### 8. Clean Up

Remove all compiled C executables:

```bash
make clean
```

### Benchmarking Considerations

For reliable results:

- Run all benchmarks on the same machine
- Close unnecessary background applications
- Use consistent input sizes when comparing implementations
- Avoid running multiple benchmarks simultaneously

- ## Useful Materials
- Slideshow Containing Presentation: https://docs.google.com/presentation/d/1P4UdjYQM0EMHtSODnv2Yj1kHiS1K1PLhLBnQtf7vzFc/edit?usp=sharing
- [Hyperfine](https://github.com/sharkdp/hyperfine): Command-line benchmarking tool used to measure and compare execution times across C and Python implementations. Hyperfine was used to perform repeated measurements, warmup runs, and statistical comparisons.
- [NumPy](https://numpy.org/): Python library for numerical computing. Used for matrix multiplication to explore how optimized native libraries can outperform straightforward C implementations.
