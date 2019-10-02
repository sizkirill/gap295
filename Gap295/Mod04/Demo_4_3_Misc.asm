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
extern _getch:NEAR

.data
    helloWorldStr DB 'Hello World', 0ah, 0

; Macros
    PARAM_1 EQU [ebp+8]
    PARAM_2 EQU [ebp+12]

FunctionPrologue MACRO
    push ebp
    mov ebp, esp
ENDM

FunctionEpilogue MACRO numBytesToDeallocate
    mov esp, ebp
    pop ebp
    ret numBytesToDeallocate
ENDM

.code

main proc C
        FunctionPrologue

        ; Loop
    ;    mov ecx, 10
    ;LoopTop:
    ;    push ecx
    ;    push offset helloWorldStr
    ;    call printf
    ;    add esp, 4
    ;    pop ecx

    ;    dec ecx
    ;    jnz LoopTop
        ; end loop

        ; loop instruction
        mov ecx, 10
    LoopTop:
        push ecx
        push offset helloWorldStr
        call printf
        add esp, 4
        pop ecx
        
        loop LoopTop

        FunctionEpilogue 0
main endp

END