; Программа для вычисления Y = |A - 3*B| / (B*B)
; С подробным выводом

extern printf
extern scanf
extern exit

section .data
    promptA db "Enter A: ", 0
    promptB db "Enter B: ", 0
    inputMsg db "A = %d, B = %d", 10, 0
    resultMsg db "Y = %.3f", 10, 0
    errorMsg db "Error: Division by zero!", 10, 0
    formatInt db "%d", 0

section .bss
    A resd 1
    B resd 1
    resultFloat resq 1

section .text
    global main

main:
    push ebp
    mov ebp, esp

    ; Ввод A
    push promptA
    call printf
    add esp, 4
    
    push A
    push formatInt
    call scanf
    add esp, 8

    ; Ввод B
    push promptB
    call printf
    add esp, 4
    
    push B
    push formatInt
    call scanf
    add esp, 8

    ; Проверка B на 0
    mov eax, [B]
    cmp eax, 0
    je .error

    ; Выводим введенные значения
    push dword [B]
    push dword [A]
    push inputMsg
    call printf
    add esp, 12

    ; Вычисляем |A - 3B|
    mov eax, [B]
    imul eax, 3         ; eax = 3B
    mov ebx, [A]
    sub ebx, eax        ; ebx = A - 3B
    
    ; Модуль
    mov eax, ebx
    cmp eax, 0
    jge .abs_done
    neg eax
.abs_done:
    push eax            ; сохраняем |A-3B| в стек

    ; Вычисляем B^2
    mov eax, [B]
    imul eax, eax       ; eax = B^2
    push eax            ; сохраняем B^2 в стек

    ; Загружаем в FPU для точного деления
    fild dword [esp+4]  ; ST(0) = |A-3B|
    fild dword [esp]    ; ST(0) = B^2, ST(1) = |A-3B|
    fdivp               ; ST(0) = |A-3B| / B^2
    
    ; Сохраняем результат
    fstp qword [resultFloat]
    
    add esp, 8          ; очищаем стек от сохраненных значений

    ; Выводим результат
    push dword [resultFloat+4]
    push dword [resultFloat]
    push resultMsg
    call printf
    add esp, 12

    push 0
    call exit

.error:
    push errorMsg
    call printf
    add esp, 4
    push 1
    call exit