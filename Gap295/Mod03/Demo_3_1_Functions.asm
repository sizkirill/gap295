
.586 
.model  flat, stdcall
option casemap:none  

; Link in the CRT.
includelib libcmt.lib
includelib libvcruntime.lib
includelib libucrt.lib
includelib legacy_stdio_definitions.lib

extern printf:NEAR
extern scanf:NEAR

.data
	printStr db 'Value: %d', 0Ah, 0
    scanfStr db '%d', 0 

.code

main proc C
        ; set up the stack frame
        push ebp
        mov ebp, esp

        ; allocate a local to store the result of user input
        sub esp, 4

        ; read the console
        call ReadNumber

        mov [ebp-4], eax

        ; print the result to the user
        push eax
        push offset printStr
        int 3
        call printf
        add esp, 8 ; cleanup params from printf

        ; square the input
        push [ebp-4]
        call Square

        ; print the result of the square
        push eax
        push offset printStr
        call printf
        add esp, 8

        ;restore the old stack frame
        mov esp, ebp
        pop ebp

        xor eax, eax
        ret
main endp

; int ReadNumber()
; {
;   int val;
;   scanf("%d", &val);
;   return val;
; }

ReadNumber proc
        ;setup the stack frame
        push ebp
        mov ebp, esp

        ; allocate local variable
        sub esp, 4  ;   local is at ebp-4

        ; push address of local variable
        mov edx, ebp
        sub edx, 4
        push edx

        ; push string
        push offset scanfStr

        ;actually call scanf()
        call scanf

        ; clean up the stack because scanf() is cdecl
        add esp, 8

        ; store the return value
        mov eax, [ebp-4]

        ;restore the old stack frame
        mov esp, ebp
        pop ebp

        ret
ReadNumber endp

; int Square(int val)
; {
;    return val * val;
; }

Square proc
        ;setup the stack frame
        push ebp
        mov ebp, esp

        ; perform square operation
        mov eax, [ebp + 8]
        imul eax, eax

        ;restore the old stack frame
        mov esp, ebp
        pop ebp

        ret 4
Square endp

END