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
extern system:NEAR

.data
    testString db '%d', 0ah, 0
    player dd 0, 0

    playerPosTestString db 'Player pos: x = %d, y = %d', 0ah, 0

    clearScreen db 'cls', 0
    fakeClearScreen db 0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0

    ; MACROS
    MAP_WIDTH EQU 40
    MAP_HEIGHT EQU 15

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
        ;push offset clearScreen
        ;call system
        ;add esp,4

        push offset fakeClearScreen
        call printf
        add esp, 4

        mov esi, ebp
        sub esi, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1
        push esi
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

    MainLoop:
        PrintMap

        mov esi, ebp
        sub esi, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1
        add esi, [edi]
        mov ecx, MAP_WIDTH + 1
        imul ecx, [edi+4]
        add esi, ecx
        mov byte ptr [esi], 2eh

    GetInput:
        call _getch
        sub eax, 97
        jz CaseA
        sub eax, 3
        jz CaseD
        sub eax, 13
        jz CaseQ
        sub eax, 2
        jz CaseS
        sub eax, 4
        jz CaseW
        jmp GetInput

    CaseA:
        cmp dword ptr [edi], 0
        je GetInput
        dec dword ptr [edi]
        jmp Update
    CaseD:
        cmp dword ptr [edi], MAP_WIDTH-1
        je GetInput
        inc dword ptr [edi]
        jmp Update
    CaseS:
        cmp dword ptr [edi+4], MAP_HEIGHT-1
        je GetInput
        inc dword ptr [edi+4]
        jmp Update
    CaseW:
        cmp dword ptr [edi+4], 0
        je GetInput
        dec dword ptr [edi+4]
        jmp Update
    CaseQ:
        jmp Quit

    Update:
        mov esi, ebp
        sub esi, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1
        add esi, [edi]
        mov ecx, MAP_WIDTH + 1
        imul ecx, [edi+4]
        add esi, ecx
        mov byte ptr [esi], 50h
        jmp MainLoop

    Quit:
        add esp, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1

        pop esi
        pop edi
        mov esp, ebp
        pop ebp

        xor eax, eax
        ret
main endp

END