.intel_syntax noprefix

.section .data
prompt_a: .asciz "Enter A: "
prompt_b: .asciz "Enter B: "
format_in: .asciz "%d"
format_out: .asciz "Result = %f\n"
error_msg: .asciz "B cannot be zero!\n"

.section .bss
a: .space 4
b: .space 4

.section .text
.globl main
.extern printf
.extern scanf

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    lea rcx, prompt_a
    call printf
    lea rdx, a
    lea rcx, format_in
    call scanf

    lea rcx, prompt_b
    call printf
    lea rdx, b
    lea rcx, format_in
    call scanf

    mov eax, dword ptr [a]
    mov ebx, dword ptr [b]

    cmp ebx, 0
    je error

    mov ecx, ebx
    imul ebx, ebx, 3
    sub eax, ebx
    
    cdq
    xor eax, edx
    sub eax, edx

    cvtsi2sd xmm0, eax
    imul ecx, ecx
    cvtsi2sd xmm1, ecx
    divsd xmm0, xmm1
    
    lea rcx, format_out
    movq rdx, xmm0
    call printf
    jmp done

error:
    lea rcx, error_msg
    call printf

done:
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret