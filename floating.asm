; Filename: fp_arithmetic_menu.asm
; Description: Menu-driven floating-point arithmetic operations in x86 assembly (32-bit)
; Assembler: NASM
; Linker: GCC

section .data
    ; **Prompt Messages**
    msg_prompt          db "Enter two numbers (a, b): ", 0
    msg_menu            db "Select operation:", 10, \
                          "1. Add", 10, \
                          "2. Subtract", 10, \
                          "3. Multiply", 10, \
                          "4. Divide", 10, \
                          "5. Square Root of a", 10, \
                          "6. Power (a^b)", 10, \
                          "7. Exit", 10, 0
    msg_invalid_choice  db "Invalid choice. Please try again.", 10, 0
    msg_div_zero        db "Error: Division by zero is undefined.", 10, 0
    msg_power_error     db "Error: Negative base with non-integer exponent may result in complex numbers.", 10, 0
    msg_exit            db "Exiting program. Goodbye!", 10, 0

    ; **Format Specifiers**
    format_double       db "%lf", 0             ; For reading doubles with scanf
    format_int          db "%d", 0              ; For reading integer choices
    format_output       db "Result: %lf", 10, 0  ; For printing doubles

    ; **Zero for Division Check**
    zero                dq 0.0                 ; Double-precision zero

section .bss
    var_a       resq 1    ; 8 bytes for double a
    var_b       resq 1    ; 8 bytes for double b
    result      resq 1    ; 8 bytes for double result
    choice      resd 1    ; 4 bytes for user choice

section .text
    extern scanf
    extern printf
    ; extern pow         ; Link with math library for pow
    ; extern sqrt        ; Link with math library for sqrt
    global main

main:
    ; **Function Prologue**
    push ebp
    mov ebp, esp

main_loop:
    ; **1. Prompt User to Enter Two Numbers**
    push msg_prompt
    call printf
    add esp, 4

    ; **2. Read First Double (a)**
    push var_a
    push format_double
    call scanf
    add esp, 8

    ; **3. Read Second Double (b)**
    push var_b
    push format_double
    call scanf
    add esp, 8

    ; **4. Display Operation Menu**
    push msg_menu
    call printf
    add esp, 4

    ; **5. Read User Choice as Integer**
    push choice
    push format_int
    call scanf
    add esp, 8

    ; **6. Move Choice to EAX for Comparison**
    mov eax, [choice]

    ; **7. Compare Choice and Branch Accordingly**
    cmp eax, 1
    je perform_add
    cmp eax, 2
    je perform_subtract
    cmp eax, 3
    je perform_multiply
    cmp eax, 4
    je perform_divide
    cmp eax, 5
    ; je perform_sqrt
    ; cmp eax, 6
    ; je perform_power
    ; cmp eax, 7
    je exit_program
    ; **If Choice Doesn't Match Any Option, Invalid Choice**
    push msg_invalid_choice
    call printf
    add esp, 4
    jmp main_loop

; **Operation: Addition**
perform_add:
    ; Load a into xmm0
    movsd xmm0, [var_a]
    ; Add b to xmm0
    addsd xmm0, [var_b]
    ; Store result
    movsd [result], xmm0
    ; Prepare to print the result
    push dword [result+4]    ; Higher 4 bytes
    push dword [result]      ; Lower 4 bytes
    push format_output        ; Format string
    call printf
    add esp, 12               ; Clean up stack (3 pushes * 4 bytes)
    jmp main_loop

; **Operation: Subtraction**
perform_subtract:
    ; Load a into xmm0
    movsd xmm0, [var_a]
    ; Subtract b from xmm0
    subsd xmm0, [var_b]
    ; Store result
    movsd [result], xmm0
    ; Prepare to print the result
    push dword [result+4]    ; Higher 4 bytes
    push dword [result]      ; Lower 4 bytes
    push format_output        ; Format string
    call printf
    add esp, 12               ; Clean up stack
    jmp main_loop

; **Operation: Multiplication**
perform_multiply:
    ; Load a into xmm0
    movsd xmm0, [var_a]
    ; Multiply xmm0 by b
    mulsd xmm0, [var_b]
    ; Store result
    movsd [result], xmm0
    ; Prepare to print the result
    push dword [result+4]    ; Higher 4 bytes
    push dword [result]      ; Lower 4 bytes
    push format_output        ; Format string
    call printf
    add esp, 12               ; Clean up stack
    jmp main_loop

; **Operation: Division with Error Handling**
perform_divide:
    ; **Check if b is zero**
    movsd xmm0, [var_b]           ; Load b into xmm0
    ucomisd xmm0, qword [zero]    ; Compare xmm0 with 0.0
    jne perform_division          ; If b != 0.0, proceed to division
    ; **If b is zero, print error message**
    push msg_div_zero
    call printf
    add esp, 4
    jmp main_loop

perform_division:
    ; **Perform Division: a / b**
    movsd xmm0, [var_a]           ; Load a into xmm0
    divsd xmm0, [var_b]           ; Divide xmm0 by b (a / b)
    movsd [result], xmm0           ; Store result
    ; **Prepare to print the result**
    push dword [result+4]          ; Higher 4 bytes
    push dword [result]            ; Lower 4 bytes
    push format_output              ; Format string
    call printf
    add esp, 12                     ; Clean up stack
    jmp main_loop

; **Operation: Square Root of a**
; perform_sqrt:
;     ; **Load a into xmm0**
;     movsd xmm0, [var_a]
;     ; **Call sqrt**
;     sub esp, 8                      ; Allocate space on stack
;     movsd [esp], xmm0               ; Move xmm0 to stack
;     call sqrt                       ; Call sqrt(a)
;     ; **Store the result**
;     movsd [result], xmm0
;     add esp, 8                      ; Restore stack
;     ; **Prepare to print the result**
;     push dword [result+4]           ; Higher 4 bytes
;     push dword [result]             ; Lower 4 bytes
;     push format_output               ; Format string
;     call printf
;     add esp, 12                      ; Clean up stack
;     jmp main_loop

; ; **Operation: Exponentiation (a^b)**
; perform_power:
;     ; **Load a into xmm0 and b into xmm1**
;     movsd xmm0, [var_a]             ; Load a into xmm0
;     movsd xmm1, [var_b]             ; Load b into xmm1
;     ; **Call pow(a, b)**
;     sub esp, 16                      ; Allocate space on stack (2 doubles)
;     movsd [esp], xmm0                ; Move a to stack
;     movsd [esp + 8], xmm1            ; Move b to stack
;     call pow                         ; Call pow(a, b)
;     ; **Store the result**
;     movsd [result], xmm0
;     add esp, 16                      ; Restore stack
;     ; **Prepare to print the result**
;     push dword [result+4]             ; Higher 4 bytes
;     push dword [result]               ; Lower 4 bytes
;     push format_output                 ; Format string
;     call printf
;     add esp, 12                        ; Clean up stack
;     jmp main_loop

; **Exit Program**
exit_program:
    ; **Print Exit Message**
    push msg_exit
    call printf
    add esp, 4
    ; **Function Epilogue**
    mov eax, 0                        ; Return 0
    mov esp, ebp
    pop ebp
    ret

