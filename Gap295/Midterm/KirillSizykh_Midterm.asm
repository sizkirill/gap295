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
    playerPosString db 'Player pos: x = %d, y = %d', 0ah, 0
    clearScreen db 'cls', 0

    loseString db 'Oh nO! You lost!', 0ah, 0
    winString db 'Congrats! You win!', 0ah, 0

    ; MACROS
    MAP_WIDTH EQU 35
    MAP_HEIGHT EQU 25
	
    ENEMY_COUNT EQU 5
	TRAP_COUNT EQU 3

    MAP_OFFSET EQU MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1
    ENEMY_OFFSET EQU MAP_OFFSET + ENEMY_COUNT * 8
	TRAP_OFFSET EQU ENEMY_OFFSET + TRAP_COUNT * 8
    PLAYER_OFFSET EQU TRAP_OFFSET + 8
	EXIT_OFFSET EQU PLAYER_OFFSET + 8

PushMapOffset MACRO
        mov esi, ebp
        sub esi, MAP_OFFSET
        push esi
ENDM

Prologue MACRO
        push ebp
        mov ebp, esp
ENDM

Epilogue MACRO bytesToDealloc
        mov esp, ebp
        pop ebp
        ret bytesToDealloc
ENDM

.code

main proc C
        Prologue

        ; Allocating memory that we're going to use
        sub esp, EXIT_OFFSET

        ; Saving registers
        push edi
        push esi
        push ebx

        ; Init rand
        call InitRng

        ; Init Map
        mov edi, ebp
        sub edi, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT
        push edi
        push MAP_WIDTH
        push MAP_HEIGHT
        push 2eh
        call InitMap

        ; Init Player
        PushMapOffset

        mov esi, ebp
        sub esi, PLAYER_OFFSET
        push esi

        push 1
        push 50h
        call Init
        ; End init player

        ; Init Enemies
        PushMapOffset

        mov esi, ebp
        sub esi, ENEMY_OFFSET
        push esi

        push ENEMY_COUNT
        push 45h
        call Init
        ; End init enemies

        ; Init Traps
        PushMapOffset

        mov esi, ebp
        sub esi, TRAP_OFFSET
        push esi

        push TRAP_COUNT
        push 54h
        call Init
        ; End init traps

        ; Init exit
        PushMapOffset

        mov esi, ebp
        sub esi, EXIT_OFFSET
        push esi

        push 1
        push 57h
        call Init
        ; End init exit

        ; Init Turn counter (enemies take turns every other turn)
        mov ebx, 0
        ; For the rest of the game I am trying to keep player coords offset in the EDX register
        mov edi, ebp
        sub edi, PLAYER_OFFSET
    MainLoop:
        inc ebx
        
        ; Clear screen
        push offset clearScreen
        call system
        add esp, 4

        ; Print player's position
        push [edi+4]
        push [edi]
        push offset playerPosString
        call printf
        add esp, 12

        ; Print map
        mov esi, ebp
        sub esi, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1
        push esi
        call printf
        add esp, 4

        ; Put empty space on player's position
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
        ; Start Update Enemies
        
        ; Enemies take turns every other player's turn (First turn of the game is skipped)
        mov eax, ebx
        xor edx, edx
        mov ecx, 2

        ; We're gonna use ebx later, so save it for now (main loop counts turns in ebx)
        push ebx
        
        ; Counting if enemies are supposed to have turn
        idiv ecx
        cmp edx, 0
        jne EnemyUpdateExit

        mov ecx, ebp
        sub ecx, MAP_OFFSET

        ; Although player offset should always be in edi, let's make sure of it
        mov edi, ebp
        sub edi, PLAYER_OFFSET
        ; ESI stores pointer to the first enemy
        mov esi, ebp
        sub esi, ENEMY_OFFSET
    EnemyUpdateLoop:
        ; Replacing enemy with empty space
        mov eax, ebp
        sub eax, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1
        add eax, [esi]
        mov edx, MAP_WIDTH + 1
        imul edx, [esi+4]
        add eax, edx
        mov [eax], byte ptr 2eh

        ; storing current X of enemy
        push dword ptr [esi]

        ; Checking where should the enemy go
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

        ; Checking if the position enemy wants to go to is empty
    CheckPos:
        mov eax, ebp
        sub eax, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1
        add eax, [esi-4]
        mov edx, MAP_WIDTH + 1
        imul edx, [esi]
        add eax, edx
        cmp [eax], byte ptr 45h
        ; If position is occupied with another enemy we're rolling back to our saved position
        je RollBack
        mov [eax], byte ptr 45h
        ; else we need to restore stack
        jmp RestoreStack
    
    RollBack:
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
        ; End of Enemy update

        ; Draw static objects (traps & exit) if tile is not occupied

        ; Draw traps
        mov esi, ebp
        sub esi, TRAP_OFFSET
        mov ecx, TRAP_COUNT
    UpdateTraps:
        mov eax, ebp
        sub eax, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1
        add eax, [esi]
        mov edx, MAP_WIDTH + 1
        imul edx, [esi+4]
        add eax, edx
        cmp [eax], byte ptr 2eh
        jne NextTrap
        mov [eax], byte ptr 54h
    NextTrap:
        add esi, 8
        dec ecx
        cmp ecx, 0
        jg UpdateTraps
        ; End draw traps

        ; Draw exit
        mov esi, ebp
        sub esi, EXIT_OFFSET
        mov eax, ebp
        sub eax, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1
        add eax, [esi]
        mov edx, MAP_WIDTH + 1
        imul edx, [esi+4]
        add eax, edx
        cmp [eax], byte ptr 2eh
        jne ExitDrawn
        mov [eax], byte ptr 57h
    ExitDrawn:
        ; End draw exit

        ; Updating player
        mov esi, ebp
        sub esi, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1
        add esi, [edi]
        mov ecx, MAP_WIDTH + 1
        imul ecx, [edi+4]
        add esi, ecx
        ; End updating player

        ; Check win/lose conditions
        ; Case step on enemy
        cmp [esi], byte ptr 45h
        je Lose
        ; Case step on trap
		cmp [esi], byte ptr 54h
		je Lose
        ; Case step on exit
        cmp [esi], byte ptr 57h
        je Win
        ; End checking

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
        pop ebx
        pop esi
        pop edi

        add esp, EXIT_OFFSET

        xor eax, eax

        Epilogue
main endp

; void Init(char* pMap, int* pToInit, int numToInit, char howToInit)
Init proc
        Prologue

        ; storing registers we're gonna modify
        push edi
        push esi
        push ebx

        ; EDI = pointer to something that we're initializing
        mov edi, [ebp+16]
        ; EBX = number of things that we're initializing
        mov ebx, [ebp+12]
    InitLoop:
        ; ESI = pointer to the start of the map
        mov esi, [ebp+20]
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

        ; Checking if space we're trying to occupy is empty
        add esi, [edi]
        mov ecx, MAP_WIDTH + 1
        imul ecx, [edi+4]
        add esi, ecx
        cmp [esi], byte ptr 2eh
        jne InitLoop
        mov dl, byte ptr [ebp+8]
        mov byte ptr [esi], dl
        ;

        add edi, 8
        dec ebx
        cmp ebx, 0
        jg InitLoop

        ; Restoring registers
        pop ebx
        pop esi
        pop edi

        Epilogue 16
Init endp

InitRng proc
        Prologue

        push 0
        call time
        add esp, 4
        push eax
        call srand
        add esp, 4

        Epilogue
InitRng endp

InitMap proc
        Prologue

        push esi
        push edi
        push ebx

        ; Map ptr
        mov esi, [ebp+20]
        ; Width 
        mov edi, [ebp+16]
        ; Height
        mov ebx, [ebp+12]

        ; After this ebx should have end of map ptr
        mov ecx, [ebp+12]
        imul ecx, edi
        add ebx, ecx
        add ebx, esi
        inc ebx

        ; Char to init
        mov al, [ebp+8]

    InitMapLoop:
        mov ecx, edi
    InitMapRow:
        mov byte ptr [esi-1], al
        inc esi
        ; while ecx > 0 filling the row with '.'
        loop InitMapRow
        ; Endline at the end of the row
        mov byte ptr [esi-1], 0ah
        inc esi
        cmp esi, ebx
        jl InitMapLoop
        ; Null terminator at the end of the map
        mov byte ptr [esi-1], 0h

        pop ebx
        pop edi
        pop esi

        Epilogue 16
InitMap endp

END