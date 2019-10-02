.586 
.model  flat, stdcall
option casemap:none  

; Link in the CRT.
includelib libcmt.lib
includelib libvcruntime.lib
includelib libucrt.lib
includelib legacy_stdio_definitions.lib

extern printf:NEAR
extern _getch:NEAR
extern rand:NEAR
extern srand:NEAR
extern time:NEAR

.data
    testString db '%d', 0ah, 0
    player dd 0, 0

    playerPosTestString db 'Player pos: x = %d, y = %d', 0ah, 0

    ; MACROS
    MAP_WIDTH EQU 10
    MAP_HEIGHT EQU 10

InitPlayer MACRO
    call rand
    idiv MAP_WIDTH
    mov offset player, edx
    call rand
    idiv MAP_HEIGHT
    mov offset player + 4, edx
ENDM

InitializeMap MACRO
        mov edi, ebp
        sub edi, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT
    InitLoop:
        mov ecx, MAP_WIDTH
    InitRow:
        mov byte ptr [edi-1], 2eh
        inc edi
        loop InitRow
        mov byte ptr [edi-1], 0ah
        inc edi
        cmp edi, ebp
        jl InitLoop
        mov byte ptr [edi-1], 0h
ENDM

PrintMap MACRO
        mov edi, ebp
        sub edi, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1
        push edi
        call printf
        add esp, 4
ENDM

.code

main proc C
        push ebp
        mov ebp, esp
        push edi
        push esi

        sub esp, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1

        push 0
        call time
        add esp, 4
        push eax
        call srand
        add esp, 4

        InitializeMap

        call rand
        mov ecx, MAP_WIDTH
        idiv ecx
        mov edi, offset player
        mov [edi], edx
        call rand
        mov ecx, MAP_HEIGHT
        idiv ecx
        mov [edi+4], edx

        mov esi, ebp
        sub esi, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1
        add esi, [edi]
        mov ecx, MAP_WIDTH + 1
        imul ecx, [edi+4]
        add esi, ecx

        mov byte ptr [esi], 50h

        ;int 3

        push [edi+4]
        push [edi]
        ;push 1
        ;push 1
        push offset playerPosTestString
        call printf
        add esp, 12

        PrintMap

; GetInput:
;         call _getch
;         cmp 
;     CaseW:
;     CaseA:
;     CaseS:
;     CaseD:    


        add esp, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1

        pop esi
        pop edi
        mov esp, ebp
        pop ebp

        xor eax, eax
        ret
main endp

END