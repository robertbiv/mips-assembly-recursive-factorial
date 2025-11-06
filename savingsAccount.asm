# Robert Bennethum IV
.data
    msg_account:        .asciiz "acct "
    msg_balance:        .asciiz " $"
    msg_newline:        .asciiz "\n"
    msg_initial:        .asciiz "start balances:\n"
    msg_after_3pct:     .asciiz "\nafter 3% month:\n"
    msg_after_4pct:     .asciiz "\nafter 4% month:\n"
    
    const_100:          .float 100.0
    const_12:           .float 12.0
    const_3:            .float 3.0
    const_4:            .float 4.0

.text
.globl main

# initialize account with number and balance
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

main:
    # create two accounts
    addi $sp, $sp, -24
    
    move $a0, $sp
    li $a1, 1001
    li $t0, 2000
    mtc1 $t0, $f12
    cvt.s.w $f12, $f12
    jal initAccount
    
    addi $a0, $sp, 12
    li $a1, 1002
    li $t0, 3000
    mtc1 $t0, $f12
    cvt.s.w $f12, $f12
    jal initAccount
    
    # show initial balances
    li $v0, 4
    la $a0, msg_initial
    syscall
    
    # set 3% and apply once
    move $a0, $sp
    jal printBalance
    
    addi $a0, $sp, 12
    jal printBalance
    
    move $a0, $sp
    l.s $f12, const_3
    jal setInterestRate
    
    addi $a0, $sp, 12
    l.s $f12, const_3
    jal setInterestRate
    
    move $a0, $sp
    jal calculateMonthlyInterest
    
    addi $a0, $sp, 12
    jal calculateMonthlyInterest
    
    # show after 3%
    li $v0, 4
    la $a0, msg_after_3pct
    syscall
    
    # set 4% and apply once
    move $a0, $sp
    jal printBalance
    
    addi $a0, $sp, 12
    jal printBalance
    
    move $a0, $sp
    l.s $f12, const_4
    jal setInterestRate
    
    addi $a0, $sp, 12
    l.s $f12, const_4
    jal setInterestRate
    
    move $a0, $sp
    jal calculateMonthlyInterest
    
    addi $a0, $sp, 12
    jal calculateMonthlyInterest
    
    # show after 4%
    li $v0, 4
    la $a0, msg_after_4pct
    syscall
    
    move $a0, $sp
    jal printBalance
    
    addi $a0, $sp, 12
    jal printBalance
    
    # exit
    addi $sp, $sp, 24
    li $v0, 10
    syscall
