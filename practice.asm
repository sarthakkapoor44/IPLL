section .data
    msg db "Please enter the filename you want to read from: ",0
    error_msg db "Error while handling file",10,0
    success_msg db "File opened successfully",10,0
    format_spec db "%s",0
    format_int db "%d",10,0
    format_str db "%s",10,0
    format_char db "%c: %d",10,0
    arr dd 256 dup(0)
section .bss
    filename resb 100
    file_desc resd 1
    info resb 101
    bytes_read resd 1
section .note.GNU-stack
    ;nothing here

section .text
    extern printf
    extern scanf
    global main
main:
    push msg
    call printf
    add esp, 4
    
    push filename
    push format_spec
    call scanf
    add esp, 8

    mov eax,5 ; file open system call number
    mov ebx,filename ; filename
    mov ecx,0 ; read only mode
    mov edx,0 ; all permissions
    int 0x80
    cmp eax,0
    jl error

    mov dword [file_desc],eax 

    push success_msg
    call printf
    add esp,4

    mov eax,3
    mov ebx,[file_desc]
    mov ecx,info
    mov edx,100
    int 0x80
    cmp eax,0
    jl error

    mov dword [bytes_read],eax
    mov byte [info+eax],0

    mov eax, 6
    mov ebx, [file_desc]
    int  0x80
    cmp eax,0 
    jl error

    push info
    push format_str
    call printf
    add esp,8

    xor esi,esi
    mov edx,arr
Loop1:
    movzx eax,byte [info+esi]
    inc dword[edx+4*eax]
    inc esi
    cmp esi,[bytes_read]
    jl Loop1

    xor esi,esi
arr_print:
    mov eax,dword[edx + 4*esi]
    inc esi
    cmp eax,0
    jg print
    cmp esi,256
    jl arr_print
  
jmp done 
print:
    dec esi
    push edx
    push eax
    push esi
    push format_char
    call printf
    add esp,8
    pop eax
    pop edx
    inc esi
    jmp arr_print

error:
    push error_msg
    call printf
    add esp,4
    ret
done:
    ret




    



   