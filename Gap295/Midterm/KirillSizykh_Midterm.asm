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

    turncounter dd 0

    playerPosTestString db 'Player pos: x = %d, y = %d', 0ah, 0

    clearScreen db 'cls', 0
    fakeClearScreen db 0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0ah,0

    loseString db 'Oh nO! You lost!', 0ah, 0
    winString db 'Congrats! You win!', 0ah, 0

    ; MACROS
    MAP_WIDTH EQU 20
    MAP_HEIGHT EQU 15
	
    ENEMY_COUNT EQU 5
	TRAP_COUNT EQU 3

    MAP_OFFSET EQU MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1
    ENEMY_OFFSET EQU MAP_OFFSET + ENEMY_COUNT * 8
	TRAP_OFFSET EQU ENEMY_OFFSET + TRAP_COUNT * 8
	EXIT_OFFSET EQU TRAP_OFFSET + 8

InitPlayer MACRO
    call rand
    xor edx, edx
    idiv MAP_WIDTH
    mov offset player, edx
    call rand
    xor edx, edx
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

InitExit MACRO
		mov edi, ebp
        sub edi, EXIT_OFFSET
        mov ebx, 0
    InitExitLoop:
        call rand
        mov ecx, MAP_WIDTH
        xor edx, edx
        idiv ecx
        mov [edi], edx
        call rand
        mov ecx, MAP_HEIGHT
        xor edx, edx
        idiv ecx
        mov [edi+4], edx

        ;;;; CHECKING IF SPACE IS EMPTY
        mov esi, ebp
        sub esi, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1
        add esi, [edi]
        mov ecx, MAP_WIDTH + 1
        imul ecx, [edi+4]
        add esi, ecx
        cmp [esi], byte ptr 2eh
        jne InitExitLoop
        mov [esi], byte ptr 57h
ENDM

InitTraps MACRO
		mov edi, ebp
        sub edi, TRAP_OFFSET
        mov ebx, 0
    InitTrapLoop:
        call rand
        mov ecx, MAP_WIDTH
        xor edx, edx
        idiv ecx
        mov [edi], edx
        call rand
        mov ecx, MAP_HEIGHT
        xor edx, edx
        idiv ecx
        mov [edi+4], edx

        ;;;; CHECKING IF SPACE IS EMPTY
        mov esi, ebp
        sub esi, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1
        add esi, [edi]
        mov ecx, MAP_WIDTH + 1
        imul ecx, [edi+4]
        add esi, ecx
        cmp [esi], byte ptr 2eh
        jne InitTrapLoop
        mov [esi], byte ptr 54h
        ;;;;

        add edi, 8
        inc ebx
        cmp ebx, TRAP_COUNT
        jl InitTrapLoop
ENDM

InitializeEnemies MACRO
        mov edi, ebp
        sub edi, ENEMY_OFFSET
        mov ebx, 0
    InitEnemyLoop:
        call rand
        mov ecx, MAP_WIDTH
        xor edx, edx
        idiv ecx
        mov [edi], edx
        call rand
        mov ecx, MAP_HEIGHT
        xor edx, edx
        idiv ecx
        mov [edi+4], edx

        ;;;; CHECKING IF SPACE IS EMPTY
        mov esi, ebp
        sub esi, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1
        add esi, [edi]
        mov ecx, MAP_WIDTH + 1
        imul ecx, [edi+4]
        add esi, ecx
        cmp [esi], byte ptr 2eh
        jne InitEnemyLoop
        mov [esi], byte ptr 45h
        ;;;;

        add edi, 8
        inc ebx
        cmp ebx, ENEMY_COUNT
        jl InitEnemyLoop
ENDM

ClearScreen MACRO
        push offset clearScreen
        call system
        add esp, 4
ENDM

FakeClearScreen MACRO
        push offset fakeClearScreen
        call printf
        add esp, 4
ENDM

PrintMap MACRO
        ;push offset clearScreen
        ;call system
        ;add esp,4

        ClearScreen

        push [edi+4]
        push [edi]
        push offset playerPosTestString
        call printf
        add esp, 12

        mov esi, ebp
        sub esi, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1
        push esi
        call printf
        add esp, 4
ENDM

UpdateEnemies MACRO
        ;int 3

        ; Enemies take turns every other player's turn
        mov eax, ebx
        xor edx, edx
        mov ecx, 2
        push ebx
        idiv ecx
        cmp edx, 0
        je EnemyUpdateExit

        mov ecx, ebp
        sub ecx, MAP_OFFSET

        mov esi, ebp
        ; Although player offset should always be in edi, let's make sure of it
        mov edi, offset player
        sub esi, ENEMY_OFFSET
    EnemyUpdateLoop:
        push eax

        ; Replacing enemy with empty space
        mov eax, ebp
        sub eax, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1
        add eax, [esi]
        mov edx, MAP_WIDTH + 1
        imul edx, [esi+4]
        add eax, edx
        mov [eax], byte ptr 2eh
        ;;
        pop eax

        ; storing current X of enemy
        push dword ptr [esi]

        mov eax, [esi]
        sub eax, [edi]
        je CompareY
        cmp eax, 0
        jg IncX
        inc dword ptr [esi]
        jmp CompareY

    IncX:
        dec dword ptr [esi]
        jmp CompareY

    CompareY:
        add esi, 4
        add edi, 4
        ; Storing current Y of enemy
        push dword ptr [esi]
        mov eax, [esi]
        sub eax, [edi]
        je CheckPos
        cmp eax, 0
        jg IncY
        inc dword ptr [esi]
        jmp CheckPos

    IncY:
        dec dword ptr [esi]
        jmp CheckPos

    CheckPos:
        ;;;; CHECKING IF SPACE IS EMPTY
        mov eax, ebp
        sub eax, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1
        add eax, [esi-4]
        mov edx, MAP_WIDTH + 1
        imul edx, [esi]
        add eax, edx
        cmp [eax], byte ptr 2eh
        jne RollBack
        mov [eax], byte ptr 45h
        jmp RestoreStack
        ;;;;
    
    RollBack:
        ;int 3;
        mov eax, ebp
        sub eax, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1
        pop ebx
        mov [esi], ebx
        mov edx, MAP_WIDTH + 1
        imul edx, ebx
        add eax, edx
        pop ebx
        mov [esi-4], ebx
        add eax, ebx
        mov [eax], byte ptr 45h
        jmp NextIter

    RestoreStack:
        ;Restoring stack before next iteration
        add esp, 8
    NextIter:
        add esi, 4
        sub edi, 4
        cmp esi, ecx
        jl EnemyUpdateLoop

    EnemyUpdateExit:
        pop ebx
ENDM

.code

main proc C
        push ebp
        mov ebp, esp
        push edi
        push esi

        ;sub esp, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1
        ;sub esp, ENEMY_COUNT * 8
		sub esp, EXIT_OFFSET

        push 0
        call time
        add esp, 4
        push eax
        call srand
        add esp, 4

        InitializeMap

        call rand
        mov ecx, MAP_WIDTH
        xor edx, edx
        idiv ecx
        mov edi, offset player
        mov [edi], edx
        call rand
        mov ecx, MAP_HEIGHT
        xor edx, edx
        idiv ecx
        mov [edi+4], edx

        mov esi, ebp
        sub esi, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1
        add esi, [edi]
        mov ecx, MAP_WIDTH + 1
        imul ecx, [edi+4]
        add esi, ecx

        mov byte ptr [esi], 50h

        InitializeEnemies
		InitTraps
		InitExit

        ; Turn counter
        mov edi, offset player
        mov ebx, 0
    MainLoop:
        inc ebx
        
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
        UpdateEnemies

        mov esi, ebp
        sub esi, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1
        add esi, [edi]
        mov ecx, MAP_WIDTH + 1
        imul ecx, [edi+4]
        add esi, ecx

        ;;;; CHECKING WIN/LOSE CONDITIONS
        cmp [esi], byte ptr 45h
        je Lose
		cmp [esi], byte ptr 54h
		je Lose
        cmp [esi], byte ptr 57h
        je Win
        ;;;;

        mov byte ptr [esi], 50h
        jmp MainLoop

    Win:
        push offset winString
        call printf
        add esp, 4
        jmp Quit

    Lose:
        push offset loseString
        call printf
        add esp, 4
        jmp Quit

    Quit:
        ;add esp, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1
		;add esp, ENEMY_COUNT*8
		
		add esp, EXIT_OFFSET

        pop esi
        pop edi
        mov esp, ebp
        pop ebp

        xor eax, eax
        ret
main endp

END