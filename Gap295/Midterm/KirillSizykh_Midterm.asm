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
        call InitMap

        ; Init Player
        PushMapOffset
        mov esi, ebp
        sub esi, PLAYER_OFFSET
        push esi
        push 1
        push 50h
        call Init

        ; Init Enemies
        PushMapOffset
        mov esi, ebp
        sub esi, ENEMY_OFFSET
        push esi
        push ENEMY_COUNT
        push 45h
        call Init

        ; Init Traps
        PushMapOffset
        mov esi, ebp
        sub esi, TRAP_OFFSET
        push esi
        push TRAP_COUNT
        push 54h
        call Init

        ; Init exit
        PushMapOffset
        mov esi, ebp
        sub esi, EXIT_OFFSET
        push esi
        push 1
        push 57h
        call Init

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

        ; Process player input
        mov esi, ebp
        sub esi, PLAYER_OFFSET
        push esi
        push MAP_WIDTH
        push MAP_HEIGHT
        call GetInput
        cmp eax, 1
        je Quit

        ; Start Update Enemies
        
        ; Enemies take turns every other player's turn (First turn of the game is skipped)
        mov eax, ebx
        xor edx, edx
        mov ecx, 2
        
        ; If enemies are not supposed to take turn, skip the enemy update section
        idiv ecx
        cmp edx, 0
        jne EnemyUpdateExit

        ; Push pointer to the start of the map
        PushMapOffset
        
        ; Push map width
        push MAP_WIDTH

        ; Push pointer to start of enemies
        mov esi, ebp
        sub esi, ENEMY_OFFSET
        push esi
        
        ; Push enemies count
        push ENEMY_COUNT

        ; Push pointer to player
        mov esi, ebp
        sub esi, PLAYER_OFFSET
        push esi

        call UpdateEnemies
    EnemyUpdateExit:

        ; Draw traps
        PushMapOffset
        mov esi, ebp
        sub esi, TRAP_OFFSET
        push esi
        push TRAP_COUNT
        push 54h
        call Draw

        ; Draw exit
        PushMapOffset
        mov esi, ebp
        sub esi, EXIT_OFFSET
        push esi
        push 1
        push 57h
        call Draw
        ; End draw exit

        ; Trying to draw player and also checking if it did hit some object
        mov esi, ebp
        sub esi, MAP_WIDTH * MAP_HEIGHT + MAP_HEIGHT + 1
        add esi, [edi]
        mov ecx, MAP_WIDTH + 1
        imul ecx, [edi+4]
        add esi, ecx

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

        ; If player didnt hit anything, draw him
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

; void InitRng()
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

; void InitMap(char* pMap, int mapWidth, int mapHeight, char emptyTile)
InitMap proc
        Prologue

        push esi
        push edi
        push ebx

        ; Map ptr
        mov esi, [ebp+16]
        ; Width 
        mov edi, [ebp+12]
        ; Height
        mov ebx, [ebp+8]

        ; After this ebx should have end of map ptr
        mov ecx, [ebp+8]
        imul ecx, edi
        add ebx, ecx
        add ebx, esi

    InitMapLoop:
        mov ecx, edi
    InitMapRow:
        mov byte ptr [esi-1], 2eh
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

        Epilogue 12
InitMap endp

; bool GetInput(Vec2* playerPos, int mapWidth, int mapHeight)
GetInput proc
        Prologue

        push ebx
        push esi
        push edi

        ; Player pos offset
        mov ebx, [ebp+16]
        ; Map Width
        mov esi, [ebp+12]
        dec esi
        ; Map Height
        mov edi, [ebp+8]
        dec edi

    ProcessInput:
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
        jmp ProcessInput

    CaseA:
        cmp dword ptr [ebx], 0
        je ProcessInput
        dec dword ptr [ebx]
        jmp Success
    CaseD:
        cmp dword ptr [ebx], esi
        je ProcessInput
        inc dword ptr [ebx]
        jmp Success
    CaseS:
        cmp dword ptr [ebx+4], edi
        je ProcessInput
        inc dword ptr [ebx+4]
        jmp Success
    CaseW:
        cmp dword ptr [ebx+4], 0
        je ProcessInput
        dec dword ptr [ebx+4]
        jmp Success
    CaseQ:
        mov eax, 1
        jmp GetInputEnd

    Success:
        xor eax, eax

    GetInputEnd:
        pop edi
        pop esi
        pop ebx

        Epilogue 12
GetInput endp

; void UpdateEnemies(char* pMap, int mapWidth, Vec2** pEnemies, int enemyCount, Vec2* playerPos)
UpdateEnemies proc
        Prologue
        push esi
        push edi

        ; enemy count
        mov esi, [ebp+12]
        ; ptr to first enemy pos
        mov edi, [ebp+16]

    UpdateEnemiesLoop:
        push dword ptr [ebp+24]
        push dword ptr [ebp+20]
        push edi
        push dword ptr [ebp+8]
        call UpdateEnemy

        dec esi
        jz UpdateEnemiesEnd
        add edi, 8
        jmp UpdateEnemiesLoop
        
    UpdateEnemiesEnd:
        xor eax, eax
        pop edi
        pop esi
        Epilogue 20
UpdateEnemies endp

; void UpdateEnemy(char* pMap, int mapWidth, Vec2* pEnemy, Vec2* playerPos)
UpdateEnemy proc
        Prologue
        sub esp, 8
        push esi
        push edi
        push ebx

        ; local for new enemyPos
        mov esi, [ebp+12]
        mov eax, [esi]
        mov [ebp-8], eax ; x
        add esi, 4
        mov eax, [esi]
        mov [ebp-4], eax ; y

        ; map ptr
        mov esi, [ebp+20]

        ; player Pos ptr
        mov edi, [ebp+8] ; x
        mov ebx, edi
        add ebx, 4 ; y

        mov eax, [ebp-8]

        sub eax, [edi]
        je CompareY
        cmp eax, 0
        jg DecX
        inc dword ptr [ebp-8]
        jmp CompareY
    DecX:
        dec dword ptr [ebp-8]
    
    CompareY:
        mov eax, [ebp-4]

        sub eax, [ebx]
        je CheckPos
        cmp eax, 0
        jg DecY
        inc dword ptr [ebp-4]
        jmp CheckPos
    
    DecY:
        dec dword ptr [ebp-4]

    CheckPos:
        add esi, [ebp-8]
        mov eax, [ebp+16]
        inc eax
        imul eax, [ebp-4]
        add esi, eax
        cmp [esi], byte ptr 45h ; if the place is occupied with enemy - we're done
        je UpdateEnemyExit
        mov [esi], byte ptr 45h ; else we mark the new place with enemy

        ; And now we need to mark last place with empty tile and update enemy position
        mov esi, [ebp+20]
        mov eax, [ebp+12]
        add esi, [eax]
        add eax, 4
        mov eax, [eax]
        mov edx, [ebp+16]
        inc edx
        imul eax, edx
        add esi, eax
        mov [esi], byte ptr 2eh
        
        ;Updating enemy position
        mov eax, [ebp+12]
        mov edi, [ebp-8]
        mov [eax], edi
        add eax, 4
        mov edi, [ebp-4]
        mov [eax], edi

        ; We're probably done
    UpdateEnemyExit:
        pop ebx
        pop edi
        pop esi
        add esp, 8
        Epilogue 16
UpdateEnemy endp

; void Draw(char* pMap, int* pToDraw, int numToDraw, char whatToDraw)
Draw proc
        Prologue

        ; storing registers we're gonna modify
        push edi
        push esi
        push ebx

        ; EDI = pointer to something that we're drawing
        mov edi, [ebp+16]
        ; EBX = number of things that we're drawing
        mov ebx, [ebp+12]
    DrawLoop:
        ; ESI = pointer to the start of the map
        mov esi, [ebp+20]
        add esi, [edi]
        mov ecx, MAP_WIDTH + 1
        imul ecx, [edi+4]
        add esi, ecx
        ; Draw only if it is an empty place
        cmp byte ptr [esi], 2eh
        jne NextDraw
        mov dl, byte ptr [ebp+8]
        mov byte ptr [esi], dl

    NextDraw:
        add edi, 8
        dec ebx
        cmp ebx, 0
        jg DrawLoop

        ; Restoring registers
        pop ebx
        pop esi
        pop edi

        Epilogue 16
Draw endp

END