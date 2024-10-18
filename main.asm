%define READ_LEN 10000000

global _start

section .data
    err_wrong_arg_amount: dw "Wrong amount of arguments, 'bin/main path key'", 10
    err_wrong_arg_amount_len equ $-err_wrong_arg_amount

section .bss
    text: resb READ_LEN

section .text
_start:
    pop r8
    cmp r8, 3
    jne .invalid_args

    pop r8
    pop r8 ; path of file
    pop r9 ; xor key

    mov rdi, r8
    call _read_bytes
    push rax

    mov rdi, r9
    call _strlen

    mov rdi, r9
    mov rsi, rax
    call _xor_bytes

    mov rdi, r8
    pop rsi
    call _write_bytes

    jmp _exit
.invalid_args:
    mov rdi, err_wrong_arg_amount
    mov rsi, err_wrong_arg_amount_len

    jmp _err_exit

_xor_bytes: ; uses key in rdi, key len in rsi
    dec rsi
    mov rdx, 0
    mov r10, 0 ; index of key
.begin:
    cmp byte [text + rdx], 0
    je .done

    mov al, [text + rdx]
    mov bl, [rdi + r10]
    
    xor al, bl
    mov [text + rdx], al

    inc rdx
    cmp r10, rsi
    je .reset_key_index
    inc r10

    jmp .begin
.reset_key_index:
    mov r10, 0
    jmp .begin
.done:
    ret

_read_bytes: ; reads path from rdi into text, rax contains amount read
.open:
    mov rax, 2 ; SYS_OPEN
    mov rsi, 0 ; O_RDONLY
    mov rdx, 0644o
    syscall
.read:
    mov rdi, rax
    mov rax, 0 ; SYS_READ
    mov rsi, text
    mov rdx, READ_LEN
    syscall

    push rax
.close:
    mov rax, 3 ; SYS_CLOSE
    syscall

    pop rax

    ret

_write_bytes: ; writes text to path in rdi with length in rsi
    push rsi
.open:
    mov rax, 2 ; SYS_OPEN
    mov rsi, 0x41 ; O_WRONLY | O_CREAT | O_TRUNC
    mov rdx, 0644o
    syscall
.write:
    pop rsi
    mov rdx, rsi

    mov rdi, rax
    mov rax, 1 ; SYS_WRITE
    mov rsi, text
    syscall
.close:
    mov rax, 3 ; SYS_CLOSE
    syscall

    ret

_strlen: ; gets string in rdi len and stores in rax
    mov rax, 0
.begin:
    cmp byte [rdi + rax], 0
    je .end

    inc rax
    jmp .begin
.end:   
    ret

_err_exit: ; takes pointer to string at rdi and len at rsi
    mov rdx, rsi
    mov rsi, rdi
    mov rax, 1 ; SYS_WRITE
    mov rdi, 0 ; STDERR
    syscall

    jmp _exit

_exit:
    mov rax, 60 ; SYS_EXIT
    mov rdi, 0 ; EXIT_SUCCESS
    syscall
