; Comment is after semicolon

; HelloWorld.asm
.586 ; 586 CPU model (Pentium processors)
.model flat, stdcall ; flat memory model and stdcall calling convention
option casemap:none ; force names to be case sensitive

; Link in the CRT
includelib libcmt.lib
includelib libvcruntime.lib
includelib libucrt.lib
includelib legacy_stdio_definitions.lib

; Use extern for any necessary functions
extern printf:NEAR

; Beginning of data section.
.data
    helloWorld db 'Hello world: %d', 0Ah, 0 ; 0Ah == '\n', 0 == null terminator.

; Beginning of code section
.code

; This is the main entry point. It must be named main and follow the C calling convention. This will cause it
; to be automatically treated as the main entry poinym like the main() function in C programs.
main proc C 

    push eax

    push offset helloWorld

    call printf

    add esp, 8

    ; EAX is used as return value for all functions.
    mov eax, 0
    ret
main endp

END