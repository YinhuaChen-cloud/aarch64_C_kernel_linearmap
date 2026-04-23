.section .text.head, "ax"
.global head_jump_to_main
.extern main

head_jump_to_main:
    b main
