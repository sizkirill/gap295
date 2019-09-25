; Demo2_1_math.asm
.586  ; 586 CPU model (Pentium processors)
.model  flat, stdcall  ; flat memory model and stdcall calling convention
option casemap:none  ; force names to be case sensitive

; Link in the CRT.
includelib libcmt.lib
includelib libvcruntime.lib
includelib libucrt.lib
includelib legacy_stdio_definitions.lib

; Use extern for any necessary functions
extern printf:NEAR

; Beginning of data section.
.data
	eaxString db 'EAX: %u', 0ah, 0
        newline db 0ah, 0
	
; Beginning of code section.	
.code

; This is the main entry point.  It must be named main and follow the C calling convention.  This will cause it to 
; be automatically treated as the main entry point, like the main() function in C programs.
main proc C
        ; stuff Rez didnt show
        ;   AND, OR, XOR, SHL, SHR

        mov eax, 13
        call PrintEax ; 13

        ; add
        add eax, 5 ; eax = eax + 5
        call PrintEax ; 18
        mov ebx, 10 ; ebx = 10
        add eax, ebx ; eax = eax + 10
        call PrintEax ; 28

        ; sub
        sub eax, 15 ; eax = eax - 15
        call PrintEax ; 13

        ; increment / decrement
        inc eax
        dec eax

        ; multiplication (integer)
        imul eax, 2 ; eax = eax * 2
        call PrintEax ; 26
        imul eax, ebx
        call PrintEax ; 260

        call PrintNewLine

        ; Division!
        ; idiv <val>
        ; Divides EDX:EAX by <val>
        ; EAX: result
        ; EDX: remainder
        ; 15 / 2
        ; mov edx, 0
        xor edx, edx ; same as "mov edx, 0". Intel Manual: prefer xor rather than mov 0
        mov eax, 15
        mov ebx, 2
        idiv ebx ; eax = edx:eax / ebx as well as edx = edx:eax % ebx
        push edx ; hand-waive
        call PrintEax
        pop eax
        call PrintEax

        call PrintNewLine

        ; EAX is used as the return value for all functions.  Doing this will return success back to the operating 
        ; system.
        mov eax, 0
        ret
main endp

; Prints the value of EAX as a decimal number. EAX is not modified by this call.
PrintEax proc
        push eax
        push offset eaxString
        call printf
        add esp, 4
        pop eax
        ret
PrintEax endp

; Prints a single newline character.
PrintNewLine proc
        push offset newline
        call printf
        add esp, 4
        ret
PrintNewLine endp

END
