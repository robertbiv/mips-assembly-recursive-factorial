# MIPS Assembly - Object Oriented Programming

This repository contains MIPS assembly implementations of object-oriented programming concepts, including set operations, savings account management, and file I/O operations. These programs were developed as part of a computer organization course to demonstrate low-level implementation of OOP principles.

## Project Overview

The repository includes three main MIPS assembly programs that demonstrate object-oriented programming concepts at the assembly level:

### 1. Integer Set Operations (`set.asm`)
An implementation of an `IntegerSet` class that can hold integers from 0 to 100. The set is represented internally as an array of ones and zeros.

**Features:**
- `initSet` - Initialize an empty set (all zeros)
- `insertElement` - Add an integer to the set
- `deleteElement` - Remove an integer from the set
- `unionOf` - Create a new set from the union of two sets
- `intersectionOf` - Create a new set from the intersection of two sets
- `printSet` - Display all elements in the set
- `equals` - Compare two sets for equality

**Sample Operations:**
- Creates and manipulates multiple sets
- Demonstrates union and intersection operations
- Tests with even numbers, odd numbers, prime numbers, and multiples of 10
- Validates that the union of even and odd numbers equals the full set (0-100)

### 2. Savings Account (`savingsAccount.asm`)
A `SavingsAccount` class implementation with instance data and methods for account management.

**Features:**
- `initAccount` - Create a new account with account number and balance
- `setInterestRate` - Set the annual interest rate
- `calculateMonthlyInterest` - Calculate and apply monthly interest (rate/12)
- `printBalance` - Display account number and current balance

**Demonstration:**
- Creates two accounts with balances of $2000.00 and $3000.00
- Applies 3% annual interest rate and calculates monthly interest
- Updates to 4% annual interest rate and recalculates

### 3. File I/O with Accounts (`savingsAccountFile.asm`)
Extended savings account implementation that reads account data from text files.

**Input Files:**
- `balances.txt` - Account numbers and initial balances (pairs of lines)
- `transactions.txt` - Account numbers and transaction amounts (pairs of lines)

**Processing:**
1. Reads initial account balances from file
2. Sets 3% annual interest rate on all accounts
3. Processes transactions (deposits/withdrawals)
4. Calculates monthly interest
5. Displays final balances

## Requirements

To run these programs, you need:
- **QtSPIM** - A MIPS simulator with a graphical interface
- Alternatively, **SPIM** or **MARS** MIPS simulators

## Usage

### Running with QtSPIM

1. Open QtSPIM
2. Load one of the assembly files:
   - `File → Load File → select .asm file`
3. For file I/O programs, ensure `balances.txt` and `transactions.txt` are in the same directory
4. Run the program:
   - Click the "Run/Continue" button or press F5
   - Or use the console: `run`

### File Structure

```
.
├── Robert Bennethum IV 313 HW5/
│   ├── set.asm                  # Integer set operations
│   ├── savingsAccount.asm       # Basic savings account
│   ├── savingsAccountFile.asm   # Account with file I/O
│   ├── balances.txt             # Initial account balances
│   └── transactions.txt         # Account transactions
├── Homework_5.pdf               # Assignment specification
├── Homework_5.txt               # Assignment details (text format)
└── README.md                    # This file
```

## Implementation Details

### Data Structures

**IntegerSet:**
- 101 words (404 bytes) per set
- Each word represents presence (1) or absence (0) of an integer
- Supports range 0-100

**SavingsAccount:**
- 3 words (12 bytes) per account:
  - Word 0: Account number (integer)
  - Word 1: Balance (float)
  - Word 2: Annual interest rate (float)

### Memory Management

All programs use stack-based memory allocation:
- Sets are allocated on the stack in 404-byte chunks
- Accounts are allocated on the stack in 12-byte structures
- Stack pointer is properly maintained across function calls

### MIPS Conventions

The code follows standard MIPS calling conventions:
- Arguments passed in `$a0-$a3` and `$f12-$f15` (for floats)
- Return values in `$v0-$v1`
- Saved registers (`$s0-$s7`) are preserved across calls
- Return address (`$ra`) is saved/restored when making nested calls

## Educational Value

This project demonstrates:
1. **Low-level OOP**: Implementing classes and methods in assembly
2. **Memory management**: Manual stack allocation and pointer arithmetic
3. **Data structures**: Array-based set representation
4. **File I/O**: Reading and parsing text files at the assembly level
5. **Floating-point arithmetic**: Using MIPS coprocessor 1 for financial calculations
6. **Algorithm implementation**: Set operations (union, intersection)

## Author

Robert Bennethum IV

## License

This is academic coursework. Please refer to your institution's academic integrity policies before using this code.
