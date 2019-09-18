; Demo2_2_memory.asm
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
    ; name size init-value
    integer dd 2, 4, 6

    foo dd 0

; Beginning of code section.	
.code

; This is the main entry point.  It must be named main and follow the C calling convention.  This will cause it to 
; be automatically treated as the main entry point, like the main() function in C programs.
main proc C
        mov eax, integer ; eax = integer
        call PrintEax

        int 3 ; int = interrupt. int 3 - setting a breakpoint

        mov esi, offset integer ; eax = &integer
        add esi, 4
        mov eax, [esi] ; eax = *esi
        call PrintEax

        mov eax, [esi+4] ; eax = *(esi + 4)
        call PrintEax

        call PrintNewLine

        ; mov foo, [esi] - Assembler error! Can't mov memory to memory

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
