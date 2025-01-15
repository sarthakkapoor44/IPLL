section .data
format_int db "%d",0
format_intn db "%d",10,0
format_int_ db "%d ",0
format_str db "%s",0
newline db 10,0
arr times 100 dd 0
edges dd 9
nodes dd 10
 
section .note.GNU-stack
;empty

section .bss
u resd 1
v resd 1

section .text
    global main
    extern printf
    extern scanf

main:

; mov edx,arr
mov esi,0
edge_input:

mov edx,arr
push u
push format_int
call scanf 
add esp,8

push v
push format_int
call scanf 
add esp,8

mov eax,dword[u]
dec eax
mov ebx,dword[v]
dec ebx

mov ecx,10
imul ecx,eax
add ecx,ebx
mov edx,arr
mov dword[edx+ 4*ecx],1

mov ecx,10
imul ecx,ebx
add ecx,eax
mov dword[edx+4*ecx],1
inc esi
cmp esi,dword[edges]
jl edge_input


mov esi,0
mov ebx,arr
loop3:
mov edi,0
mov ecx,10
imul ecx,esi
loop4:
mov eax,dword[ebx+ 4*ecx]

push ecx
push ebx
push eax
push format_int_
call printf
add esp,8
pop ebx
pop ecx

inc ecx
inc edi
cmp edi,[nodes]
jl loop4

push ecx
push edx
push newline
call printf
add esp,4
pop edx
pop ecx

inc esi
cmp esi,[nodes]
jl loop3

mov ebx,0
mov ecx,0
call dfs
jmp done

dfs:
push ecx
push ebx

push ebx
push format_int_
call printf
add esp,8

pop ebx;pos
pop ecx;par

mov esi,0
loopL1:
cmp esi,ecx
je incr
mov edx,arr
mov edi,10
imul edi,ebx
add edi,esi
mov edi,[edx+4*edi]
cmp edi,1
je dfs_call
jmp incr

dfs_call:
push ebx
push ecx
push esi
mov ecx,ebx
mov ebx,esi
call dfs
pop esi
pop ecx
pop ebx

incr:
inc esi
cmp esi,[nodes]
jl loopL1

ret

done:
push newline
call printf
add esp,4
ret
