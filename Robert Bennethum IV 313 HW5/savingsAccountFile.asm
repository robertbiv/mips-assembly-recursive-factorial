# Robert Bennethum IV
.data
    # I needed to use absolute paths for the file names to work correctly, just fyi
    # Use forward slashes '/' in paths, not typical Windows backslashes '\'
    balances_file:      .asciiz "balances.txt"
    transactions_file:  .asciiz "transactions.txt"
    
    msg_error_open:     .asciiz "no file, try absolute path in code\n"
    msg_initial:        .asciiz "start balances:\n"
    msg_transactions:   .asciiz "\napplying transactions...\n"
    msg_final:          .asciiz "\nfinal balances (1 mo @3%):\n"
    msg_account:        .asciiz "acct "
    msg_balance:        .asciiz " $"
    msg_newline:        .asciiz "\n"
    
    buffer:             .space 256
    
    const_100:          .float 100.0
    const_12:           .float 12.0
    const_3:            .float 3.0

.text
.globl main

# initialize account
initAccount:
    sw $a1, 0($a0)
    s.s $f12, 4($a0)
    mtc1 $zero, $f0
    s.s $f0, 8($a0)
    jr $ra

# set annual interest rate (%)
setInterestRate:
    s.s $f12, 8($a0)
    jr $ra

# add one month of interest to balance
calculateMonthlyInterest:
    l.s $f0, 4($a0)
    l.s $f2, 8($a0)
    l.s $f4, const_100
    l.s $f6, const_12
    
    mul.s $f8, $f0, $f2
    div.s $f8, $f8, $f4
    div.s $f8, $f8, $f6
    
    add.s $f0, $f0, $f8
    s.s $f0, 4($a0)
    jr $ra

# add/subtract amount to balance
addToBalance:
    l.s $f0, 4($a0)
    add.s $f0, $f0, $f12
    s.s $f0, 4($a0)
    jr $ra

# print account number and balance
printBalance:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    
    move $s0, $a0
    
    li $v0, 4
    la $a0, msg_account
    syscall
    
    li $v0, 1
    lw $a0, 0($s0)
    syscall

    li $v0, 4
    la $a0, msg_balance
    syscall
    
    li $v0, 2
    l.s $f12, 4($s0)
    syscall
    
    li $v0, 4
    la $a0, msg_newline
    syscall

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

# find account by number, return address or -1
findAccount:
    move $t0, $a0
    li $t1, 0
    
find_loop:
    bge $t1, $a1, find_not_found
    
    lw $t2, 0($t0)
    beq $t2, $a2, find_found
    
    addi $t0, $t0, 12
    addi $t1, $t1, 1
    j find_loop
    
find_found:
    move $v0, $t0
    jr $ra
    
find_not_found:
    li $v0, -1
    jr $ra

# parse float from string
parseFloat:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    
    move $s0, $a0
    
    mtc1 $zero, $f0
    cvt.s.w $f0, $f0
    li $t0, 1
    mtc1 $t0, $f10
    cvt.s.w $f10, $f10
    
    lb $t1, 0($s0)
    li $t2, 45
    bne $t1, $t2, parse_after_sign
    
    li $t0, -1
    mtc1 $t0, $f10
    cvt.s.w $f10, $f10
    addi $s0, $s0, 1

parse_after_sign:
    li $t3, 10
    mtc1 $t3, $f12
    cvt.s.w $f12, $f12
    
parse_int_loop:
    lb $t1, 0($s0)
    
    li $t2, 48
    blt $t1, $t2, parse_int_done
    li $t2, 57
    bgt $t1, $t2, parse_int_done
    
    li $t2, 48
    sub $t1, $t1, $t2
    
    mul.s $f0, $f0, $f12
    mtc1 $t1, $f14
    cvt.s.w $f14, $f14
    add.s $f0, $f0, $f14
    
    addi $s0, $s0, 1
    j parse_int_loop
    
parse_int_done:
    lb $t1, 0($s0)
    li $t2, 46
    bne $t1, $t2, parse_done
    
    addi $s0, $s0, 1
    
    # decimal part
    li $t3, 1
    mtc1 $t3, $f14
    cvt.s.w $f14, $f14
    
parse_frac_loop:
    lb $t1, 0($s0)
    
    li $t2, 48
    blt $t1, $t2, parse_done
    li $t2, 57
    bgt $t1, $t2, parse_done
    
    li $t2, 48
    sub $t1, $t1, $t2
    
    mul.s $f14, $f14, $f12
    
    mtc1 $t1, $f16
    cvt.s.w $f16, $f16
    div.s $f16, $f16, $f14
    add.s $f0, $f0, $f16
    
    addi $s0, $s0, 1
    j parse_frac_loop
    
parse_done:
    mul.s $f0, $f0, $f10
    
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

main:
    # storage for up to 50 accounts
    addi $sp, $sp, -600
    move $s7, $sp
    li $s6, 0
    
    # open balances.txt
    li $v0, 13
    la $a0, balances_file
    li $a1, 0
    li $a2, 0
    syscall
    move $s0, $v0
    
        bltz $s0, error_opening_file
    
    # read entire file
    li $v0, 14
    move $a0, $s0
    la $a1, buffer
    li $a2, 1024
    syscall
    
    blez $v0, close_balances
    
    # null terminate
    la $t0, buffer
    add $t0, $t0, $v0
    sb $zero, 0($t0)
    
    # parse buffer
    la $s1, buffer
    
read_balances_loop:
    lb $t0, 0($s1)
    beqz $t0, close_balances
    
    # parse account number
    move $a0, $s1
    jal parseInt
    move $s2, $v0
    
    # skip to next line
skip_line1:
    lb $t0, 0($s1)
    beqz $t0, close_balances
    addi $s1, $s1, 1
    li $t1, 10
    bne $t0, $t1, skip_line1
    
    # parse balance
    move $a0, $s1
    jal parseFloat
    mov.s $f12, $f0
    
    # skip to next line
skip_line2:
    lb $t0, 0($s1)
    beqz $t0, close_balances
    addi $s1, $s1, 1
    li $t1, 10
    bne $t0, $t1, skip_line2
    
    # create account
    move $a0, $s7
    li $t0, 12
    mult $s6, $t0
    mflo $t0
    add $a0, $a0, $t0
    move $a1, $s2
    jal initAccount
    
    addi $s6, $s6, 1
    
    j read_balances_loop
    
close_balances:
    # close file and print initial
    li $v0, 16
    move $a0, $s0
    syscall
    
    li $v0, 4
    la $a0, msg_initial
    syscall
    
    li $t0, 0
print_initial_loop:
    bge $t0, $s6, print_initial_done
    
    move $a0, $s7
    li $t1, 12
    mult $t0, $t1
    mflo $t1
    add $a0, $a0, $t1
    
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    
    jal printBalance
    
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    
    addi $t0, $t0, 1
    j print_initial_loop
    
print_initial_done:
    
    # set 3% for all accounts
    li $t0, 0
set_interest_loop:
    bge $t0, $s6, set_interest_done
    
    move $a0, $s7
    li $t1, 12
    mult $t0, $t1
    mflo $t1
    add $a0, $a0, $t1
    
    l.s $f12, const_3
    
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    
    jal setInterestRate
    
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    
    addi $t0, $t0, 1
    j set_interest_loop
    
set_interest_done:
    
    # open transactions.txt
    li $v0, 13
    la $a0, transactions_file
    li $a1, 0
    li $a2, 0
    syscall
    move $s0, $v0
    
    bltz $s0, error_opening_file
    
    # start processing
    li $v0, 4
    la $a0, msg_transactions
    syscall
    
    # read entire file
    li $v0, 14
    move $a0, $s0
    la $a1, buffer
    li $a2, 1024
    syscall
    
    blez $v0, close_transactions
    
    # null terminate
    la $t0, buffer
    add $t0, $t0, $v0
    sb $zero, 0($t0)
    
    # parse buffer
    la $s1, buffer
    
read_transactions_loop:
    lb $t0, 0($s1)
    beqz $t0, close_transactions
    
    # parse account number
    move $a0, $s1
    jal parseInt
    move $s2, $v0
    
    # skip to next line
skip_trans_line1:
    lb $t0, 0($s1)
    beqz $t0, close_transactions
    addi $s1, $s1, 1
    li $t1, 10
    bne $t0, $t1, skip_trans_line1
    
    # parse amount
    move $a0, $s1
    jal parseFloat
    mov.s $f12, $f0
    
    # skip to next line
skip_trans_line2:
    lb $t0, 0($s1)
    beqz $t0, close_transactions
    addi $s1, $s1, 1
    li $t1, 10
    bne $t0, $t1, skip_trans_line2
    
    # find and update account
    move $a0, $s7
    move $a1, $s6
    move $a2, $s2
    jal findAccount
    
    li $t0, -1
    beq $v0, $t0, read_transactions_loop
    
    move $a0, $v0
    jal addToBalance
    
    j read_transactions_loop
    
close_transactions:
    # close file and apply monthly interest
    li $v0, 16
    move $a0, $s0
    syscall
    
    li $t0, 0
calc_interest_loop:
    bge $t0, $s6, calc_interest_done
    
    move $a0, $s7
    li $t1, 12
    mult $t0, $t1
    mflo $t1
    add $a0, $a0, $t1
    
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    
    jal calculateMonthlyInterest
    
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    
    addi $t0, $t0, 1
    j calc_interest_loop
    
calc_interest_done:
    
    # print final balances
    li $v0, 4
    la $a0, msg_final
    syscall
    
    li $t0, 0
print_final_loop:
    bge $t0, $s6, print_final_done
    
    move $a0, $s7
    li $t1, 12
    mult $t0, $t1
    mflo $t1
    add $a0, $a0, $t1
    
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    
    jal printBalance
    
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    
    addi $t0, $t0, 1
    j print_final_loop
    
print_final_done:
    
    # exit
    addi $sp, $sp, 600
    li $v0, 10
    syscall

error_opening_file:
    # simple error message then exit
    li $v0, 4
    la $a0, msg_error_open
    syscall
    
    addi $sp, $sp, 600
    li $v0, 10
    syscall

# parse ASCII int (optional '-')
parseInt:
    li $v0, 0
    li $t0, 1
    move $t1, $a0
    
    lb $t2, 0($t1)
    li $t3, 45
    bne $t2, $t3, parse_int_after_sign
    
    li $t0, -1
    addi $t1, $t1, 1
    
parse_int_after_sign:
parse_int_digit_loop:
    lb $t2, 0($t1)
    
    li $t3, 48
    blt $t2, $t3, parse_int_end
    li $t3, 57
    bgt $t2, $t3, parse_int_end
    
    li $t3, 48
    sub $t2, $t2, $t3
    
    li $t3, 10
    mult $v0, $t3
    mflo $v0
    add $v0, $v0, $t2
    
    addi $t1, $t1, 1
    j parse_int_digit_loop
    
parse_int_end:
    mult $v0, $t0
    mflo $v0
    
    jr $ra

