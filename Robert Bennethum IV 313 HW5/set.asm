# Robert Bennethum IV
.data
    msg_set1:       .asciiz "set1 = "
    msg_set2:       .asciiz "set2 = "
    msg_union:      .asciiz "union = "
    msg_intersection: .asciiz "intersect = "
    msg_after_insert: .asciiz "after inserts: "
    msg_after_delete: .asciiz "after deletes: "
    msg_equals_true:  .asciiz "same\n"
    msg_equals_false: .asciiz "diff\n"
    msg_newline:    .asciiz "\n"
    msg_space:      .asciiz " "
    msg_empty:      .asciiz "{}\n"
    msg_even:       .asciiz "even = "
    msg_odd:        .asciiz "odd = "
    msg_primes:     .asciiz "primes = "
    msg_tens:       .asciiz "x10 = "
    msg_full:       .asciiz "full = "
    msg_big_union:  .asciiz "union(e,o) = "
    msg_big_test:   .asciiz "union==full? "

.text
.globl main

# clear set to zeros
initSet:
    li $t0, 0
    li $t1, 101
init_loop:
    bge $t0, $t1, init_done
    sll $t2, $t0, 2
    add $t3, $a0, $t2
    sw $zero, 0($t3)
    addi $t0, $t0, 1
    j init_loop
init_done:
    jr $ra

# add k if 0<=k<=100
insertElement:
    bltz $a1, insert_done
    li $t0, 100
    bgt $a1, $t0, insert_done
    
    sll $t1, $a1, 2
    add $t2, $a0, $t1
    li $t3, 1
    sw $t3, 0($t2)
insert_done:
    jr $ra

# remove k if 0<=k<=100
deleteElement:
    bltz $a1, delete_done
    li $t0, 100
    bgt $a1, $t0, delete_done
    
    sll $t1, $a1, 2
    add $t2, $a0, $t1
    sw $zero, 0($t2)
delete_done:
    jr $ra

# union operation
unionOf:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    move $t9, $a0
    move $t8, $a1
    move $a0, $a2
    jal initSet
    move $a0, $t9
    move $a1, $t8
    
    li $t0, 0
    li $t1, 101
union_loop:
    bge $t0, $t1, union_done
    
    sll $t2, $t0, 2
    add $t3, $a0, $t2
    lw $t4, 0($t3)
    
    add $t3, $a1, $t2
    lw $t5, 0($t3)
    
    or $t6, $t4, $t5
    add $t3, $a2, $t2
    sw $t6, 0($t3)
    
    addi $t0, $t0, 1
    j union_loop
union_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# result = set1 ^ set2 (AND)
intersectionOf:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    move $t9, $a0
    move $t8, $a1
    move $a0, $a2
    jal initSet
    move $a0, $t9
    move $a1, $t8
    
    li $t0, 0
    li $t1, 101
intersect_loop:
    bge $t0, $t1, intersect_done
    
    sll $t2, $t0, 2
    add $t3, $a0, $t2
    lw $t4, 0($t3)
    
    add $t3, $a1, $t2
    lw $t5, 0($t3)
    
    and $t6, $t4, $t5
    add $t3, $a2, $t2
    sw $t6, 0($t3)
    
    addi $t0, $t0, 1
    j intersect_loop
intersect_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# print all elements in set
printSet:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    
    move $s0, $a0
    li $s1, 0
    li $s2, 0
    
print_loop:
    li $t0, 101
    bge $s1, $t0, print_end
    
    sll $t1, $s1, 2
    add $t2, $s0, $t1
    lw $t3, 0($t2)
    
    beqz $t3, print_next
    
    li $v0, 1
    move $a0, $s1
    syscall

    li $v0, 4
    la $a0, msg_space
    syscall
    
    addi $s2, $s2, 1
    
print_next:
    addi $s1, $s1, 1
    j print_loop
    
print_end:
    li $v0, 4
    la $a0, msg_newline
    syscall
    
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra

# v0=1 if sets equal, else 0
equals:
    li $t0, 0
    li $t1, 101
equals_loop:
    bge $t0, $t1, equals_true
    
    sll $t2, $t0, 2
    add $t3, $a0, $t2
    lw $t4, 0($t3)
    
    add $t3, $a1, $t2
    lw $t5, 0($t3)
    
    bne $t4, $t5, equals_false
    
    addi $t0, $t0, 1
    j equals_loop
    
equals_true:
    li $v0, 1
    jr $ra
    
equals_false:
    li $v0, 0
    jr $ra

main:
    # make 9 sets on stack
    addi $sp, $sp, -3636
    
    # fill set1
    move $a0, $sp
    jal initSet
    
    # fill set2
    addi $a0, $sp, 404
 # ------------------------------------------------------------
 # SAMPLE DATA FOR TESTING
 # ------------------------------------------------------------
    jal initSet
    
    addi $a0, $sp, 808
    jal initSet
    
    addi $a0, $sp, 1212
    jal initSet
    
    addi $a0, $sp, 1616
    jal initSet
    
    move $a0, $sp
    li $a1, 1
    jal insertElement
    
    move $a0, $sp
    li $a1, 3
    jal insertElement
    
    move $a0, $sp
    li $a1, 5
    jal insertElement
    
    move $a0, $sp
    li $a1, 7
    jal insertElement
    
    move $a0, $sp
    li $a1, 9
    jal insertElement
    
    move $a0, $sp
    li $a1, 25
    jal insertElement
    
    move $a0, $sp
    li $a1, 50
    jal insertElement
    
    move $a0, $sp
    li $a1, 75
    jal insertElement
    
    move $a0, $sp
    li $a1, 100
    jal insertElement
    
    addi $a0, $sp, 404
    li $a1, 2
    jal insertElement
    
    addi $a0, $sp, 404
    li $a1, 3
    jal insertElement
    
    addi $a0, $sp, 404
    li $a1, 4
    jal insertElement
    
    addi $a0, $sp, 404
    li $a1, 5
    jal insertElement
    
    addi $a0, $sp, 404
    li $a1, 6
    jal insertElement
    
    addi $a0, $sp, 404
    li $a1, 25
    jal insertElement
    
    addi $a0, $sp, 404
    li $a1, 50
    jal insertElement
    
    addi $a0, $sp, 404
    li $a1, 60
    jal insertElement
    
    # show set1
    li $v0, 4
    la $a0, msg_set1
    syscall
    
    move $a0, $sp
    jal printSet
    
    # show set2
    li $v0, 4
    la $a0, msg_set2
    syscall
    
    addi $a0, $sp, 404
    jal printSet
    
    # union and print
    move $a0, $sp
    addi $a1, $sp, 404
    addi $a2, $sp, 808
    jal unionOf
    
    li $v0, 4
    la $a0, msg_union
    syscall
    
    addi $a0, $sp, 808
    jal printSet
    
    # intersection and print
    move $a0, $sp
    addi $a1, $sp, 404
    addi $a2, $sp, 1212
    jal intersectionOf
    
    li $v0, 4
    la $a0, msg_intersection
    syscall
    
    addi $a0, $sp, 1212
    jal printSet
    
    # delete a few from set1
    move $a0, $sp
    li $a1, 7
    jal deleteElement
    
    move $a0, $sp
    li $a1, 100
    jal deleteElement
    
    li $v0, 4
    la $a0, msg_after_delete
    syscall
    
    move $a0, $sp
    jal printSet
    
    # insert into set5
    addi $a0, $sp, 1616
    li $a1, 10
    jal insertElement
    
    addi $a0, $sp, 1616
    li $a1, 20
    jal insertElement

    addi $a0, $sp, 1616
    li $a1, 30
    jal insertElement
    
    li $v0, 4
    la $a0, msg_after_insert
    syscall
    
    addi $a0, $sp, 1616
    jal printSet
    
    # equals(set1,set2)
    move $a0, $sp
    addi $a1, $sp, 404
    jal equals
    
    li $v0, 4
    beqz $v0, print_not_equal1
    la $a0, msg_equals_true
    j print_equal1
print_not_equal1:
    la $a0, msg_equals_false
print_equal1:
    syscall
    
    # equals(set1,set1)
    move $a0, $sp
    move $a1, $sp
    jal equals
    
    move $t0, $v0
    li $v0, 4
    beqz $t0, print_not_equal2
    la $a0, msg_equals_true
    j print_equal2
print_not_equal2:
    la $a0, msg_equals_false
print_equal2:
    syscall
    
    # build extra sets
    # set6 even numbers
    addi $a0, $sp, 2020
    jal initSet
    li $t0, 0
even_loop:
    li $t1, 100
    bgt $t0, $t1, even_done
    addi $a0, $sp, 2020
    move $a1, $t0
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    jal insertElement
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    addi $t0, $t0, 2
    j even_loop
even_done:
    # set7 odd numbers
    addi $a0, $sp, 2424
    jal initSet
    li $t0, 1
odd_loop:
    li $t1, 99
    bgt $t0, $t1, odd_done
    addi $a0, $sp, 2424
    move $a1, $t0
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    jal insertElement
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    addi $t0, $t0, 2
    j odd_loop
odd_done:
    # set8 primes
    addi $a0, $sp, 2828
    jal initSet
    addi $a0, $sp, 2828
    li $a1, 2
    jal insertElement
    addi $a0, $sp, 2828
    li $a1, 3
    jal insertElement
    addi $a0, $sp, 2828
    li $a1, 5
    jal insertElement
    addi $a0, $sp, 2828
    li $a1, 7
    jal insertElement
    addi $a0, $sp, 2828
    li $a1, 11
    jal insertElement
    addi $a0, $sp, 2828
    li $a1, 13
    jal insertElement
    addi $a0, $sp, 2828
    li $a1, 17
    jal insertElement
    addi $a0, $sp, 2828
    li $a1, 19
    jal insertElement
    addi $a0, $sp, 2828
    li $a1, 23
    jal insertElement
    addi $a0, $sp, 2828
    li $a1, 29
    jal insertElement
    addi $a0, $sp, 2828
    li $a1, 31
    jal insertElement
    addi $a0, $sp, 2828
    li $a1, 37
    jal insertElement
    addi $a0, $sp, 2828
    li $a1, 41
    jal insertElement
    addi $a0, $sp, 2828
    li $a1, 43
    jal insertElement
    addi $a0, $sp, 2828
    li $a1, 47
    jal insertElement
    addi $a0, $sp, 2828
    li $a1, 53
    jal insertElement
    addi $a0, $sp, 2828
    li $a1, 59
    jal insertElement
    addi $a0, $sp, 2828
    li $a1, 61
    jal insertElement
    addi $a0, $sp, 2828
    li $a1, 67
    jal insertElement
    addi $a0, $sp, 2828
    li $a1, 71
    jal insertElement
    addi $a0, $sp, 2828
    li $a1, 73
    jal insertElement
    addi $a0, $sp, 2828
    li $a1, 79
    jal insertElement
    addi $a0, $sp, 2828
    li $a1, 83
    jal insertElement
    addi $a0, $sp, 2828
    li $a1, 89
    jal insertElement
    addi $a0, $sp, 2828
    li $a1, 97
    jal insertElement
    # set9 multiples of 10
    addi $a0, $sp, 3232
    jal initSet
    li $t0, 0
tens_loop:
    li $t1, 100
    bgt $t0, $t1, tens_done
    addi $a0, $sp, 3232
    move $a1, $t0
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    jal insertElement
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    addi $t0, $t0, 10
    j tens_loop
tens_done:
    # build full set in set5
    addi $a0, $sp, 1616
    jal initSet
    li $t0, 0
full_loop:
    li $t1, 100
    bgt $t0, $t1, full_done
    addi $a0, $sp, 1616
    move $a1, $t0
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    jal insertElement
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    addi $t0, $t0, 1
    j full_loop
full_done:
    # union even+odd -> set3
    addi $a0, $sp, 2020   # even
    addi $a1, $sp, 2424   # odd
    addi $a2, $sp, 808    # reuse set3
    jal unionOf
    # print new sets
    li $v0, 4
    la $a0, msg_even
    syscall
    addi $a0, $sp, 2020
    jal printSet
    li $v0, 4
    la $a0, msg_odd
    syscall
    addi $a0, $sp, 2424
    jal printSet
    li $v0, 4
    la $a0, msg_primes
    syscall
    addi $a0, $sp, 2828
    jal printSet
    li $v0, 4
    la $a0, msg_tens
    syscall
    addi $a0, $sp, 3232
    jal printSet
    li $v0, 4
    la $a0, msg_full
    syscall
    addi $a0, $sp, 1616
    jal printSet
    li $v0, 4
    la $a0, msg_big_union
    syscall
    addi $a0, $sp, 808
    jal printSet
    # test union == full
    addi $a0, $sp, 808
    addi $a1, $sp, 1616
    jal equals
    li $v0, 4
    la $a0, msg_big_test
    syscall
    li $v0, 4
    beqz $v0, big_not_eq
    la $a0, msg_equals_true
    j big_print_done
big_not_eq:
    la $a0, msg_equals_false
big_print_done:
    syscall
    # exit
    addi $sp, $sp, 3636
    li $v0, 10
    syscall