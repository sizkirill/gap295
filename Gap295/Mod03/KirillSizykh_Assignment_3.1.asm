; Assignment_3.1.asm
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
        promptDividend db 'Enter the dividend', 0Ah, 0
        promptDivisor db 'Enter the divisor', 0Ah, 0
        printResult db '%d divided by %d = %d',0Ah,0
.code

; "main should do nothing but call the first function" means literally nothing or setting/cleaning stack & returning 0 too?
main proc C
        ; set up stack frame
        push ebp
        mov ebp, esp

        ; We don't need any registers to be saved, so just leave them as they are
        call DoStuff

        ; Well, we didn't actually change the stack but anyway,
        ;   restore stack frame
        mov esp, ebp
        pop ebp

        ; return 0
        xor eax, eax
        ret
main endp

;======================================================================================================================
; Helper Functions

; This function reads 2 numbers, calls divide and prints the quotient
DoStuff proc
        ; set up stack frame
        push ebp
        mov ebp, esp

        ; Allocating memory for locals (3 bytes for scanf string, 8 bytes for 2 ints)
        sub esp, 11
        mov byte ptr [ebp-11], 25h
        mov byte ptr [ebp-10], 64h
        mov byte ptr [ebp-9], 0h

        ; prompting for dividend
        push offset promptDividend
        call printf
        add esp, 4

        ; push address of dividend
        mov edx, ebp
        sub edx, 8
        push edx

        ; push scanf str
        sub edx, 3
        push edx

        ; read dividend
        call scanf
        add esp, 8

        ; prompting for divisor
        push offset promptDividend
        call printf
        add esp, 4

        ; push address of divisor
        mov edx, ebp
        sub edx, 4
        push edx

        ; push scanf str
        sub edx, 7
        push edx

        ; read divisor
        call scanf
        add esp, 8

        ; push divisor and dividend
        push [ebp-4]
        push [ebp-8]
        call Divide

        ; print result
        push eax
        push [ebp-4]
        push [ebp-8]
        push offset printResult
        call printf
        add esp, 16

        ;restore stack frame
        mov esp, ebp
        pop ebp
        ret
DoStuff endp

; Divides two numbers, returns quotient
Divide proc
        ; set up stack frame
        push ebp
        mov ebp, esp

        ; moving dividend to eax
        mov eax, [ebp+8]
        idiv dword ptr [ebp+12]
        ; result is now in eax, remainder in edx

        ;restore stack frame
        mov esp, ebp
        pop ebp
        ret 8
Divide endp

END

