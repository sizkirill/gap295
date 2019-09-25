; Assignment_2.1.asm
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
    someArray DD 4,8,15,16,23 ;42
    arraySize DD 5
    arraySum DD 0
.code

main proc C
    ; Storing begin and end in esi and edi accordingly
    call PrepareLoop
    ; while (esi < edx)
    printArray:
        ; eax = *esi
        mov eax, [esi]
        ; printf(eax)
        call PrintEax
        ; esi += sizeof(int)
        add esi, 4
        cmp esi, edi
        jl printArray

        call PrintNewline

        ; Get two numbers, store first in 'ebx', second in 'ecx'
        call GetNumber
        imul eax, 4
        mov ebx, eax
        call GetNumber
        mov ecx, eax

        call PrintNewline ; <-- this thing puts 1 in eax
        mov esi, offset someArray
        imul ecx, [esi + ebx]
        mov eax, ecx
        call PrintEax

        call PrintNewline
        ; Separated the division result out of other stuff. Now eax contains 1, so we need to restore the eax value
        mov eax, ecx
        ; pointer to next element of array
        add ebx, 4
        ; storing the value that we're going to divide by
        mov ecx, [esi + ebx]
        ; zeroing out the register for remainder
        xor edx, edx
        idiv ecx

        ; print division result
        call PrintEax
        mov eax, edx
        ; print remainder
        call PrintEax

        ; storing array begin and end in esi and edi accordingly
        call PrepareLoop
        xor eax, eax
    ; calculating sum (132)
    calcSum:
        add eax, [esi]
        add esi, 4
        cmp esi, edi
        jl calcSum

        ; storing sum in a variable
        mov [arraySum], eax

        ; multiplying sum by 2
        imul eax, 2
        ; push it on the stack
        push eax
        ; pop it into esi
        pop esi

        ; Nothing was told about printing the value, but it is there to test that esi actually has the sum
        ;mov eax, esi
        ;call PrintEax

        ; return success
		mov eax, 0
		ret
main endp

;======================================================================================================================
; Helper Functions

; I was little lazy to setup the loop twice
; Stores pBegin* in esi and pEnd* in edi
PrepareLoop PROC
		; store adress of someArray in esi
        mov esi, offset someArray
        ; store arraySize in edx
        mov edi, arraySize
        ; multiply arraySize by size of int
        imul edi, 4
        ; store end of array in edx
        add edi, esi

        ret
PrepareLoop ENDP

; Prints the value of EAX as a decimal number.  EAX is not modified by this call.
PrintEax PROC
        ; set the up the stack
        push ebp
        mov ebp, esp

        ; string to print: "%d\n"
        sub esp, 4
        mov byte ptr[ebp-4], 25h
        mov byte ptr[ebp-3], 64h
        mov byte ptr[ebp-2], 0Ah
        mov byte ptr[ebp-1], 0

        ; push all the general purpose registers this function could overwrite
        push edi
		push ecx
		push edx

        ; push the eax parameter to printf
        push eax

        ; push the address of the string to printf
        mov edi, ebp
        sub edi, 4
        push edi

        ; call printf
		call printf

        ; Only reset the stack by one parameter manually, then pop off the eax parameter so it remains the 
        ; same.  printf often changes it.
        add esp, 4
        pop eax

        ; restore registers
		pop edx
		pop ecx
        pop edi

        ; fully reset the stack and base pointers to whatever they were
        mov esp, ebp
        pop ebp

		ret
PrintEax ENDP


; Prints a single newline character.
PrintNewline PROC
        ; set the up the stack
        push ebp
        mov ebp, esp

        ; string to print: "\n"
        sub esp, 2
        mov byte ptr[ebp-2], 0Ah
        mov byte ptr[ebp-1], 0

        ; push all the general purpose registers this function could overwrite
        push edi
		push ecx
		push edx

        ; push the address of the string to printf
        mov edi, ebp
        sub edi, 2
        push edi

        ; call printf and reset the stack
		call printf
        add esp, 4

        ; restore registers
		pop edx
		pop ecx
        pop edi

        ; fully reset the stack and base pointers to whatever they were
        mov esp, ebp
        pop ebp

		ret
PrintNewline ENDP

; Calls scanf to get a number from the user.  This will be saved in eax.
GetNumber PROC
        ; set the up the stack
        push ebp
        mov ebp, esp
		
		; seven bytes worth of local data
        sub esp, 7

        ; string sent to scanf: "%d"
        mov byte ptr[ebp-3], 25h
        mov byte ptr[ebp-2], 64h
        mov byte ptr[ebp-1], 0
		
        ; push all the general purpose registers this function could overwrite
		push ecx
		push edx
        push edi
		
		; push the address of output variable
        mov edx, ebp
        sub edx, 7
		mov dword ptr[edx], 0  ; initialize the output
        push edx
		
		; push the address of the scanf string
        mov edi, ebp
        sub edi, 3
        push edi

        ; call printf
		call scanf

        ; Reset the stack after the call to scanf
        add esp, 4
		pop edx  ; we need to pop this off the stack because it was likely overwritten
		
		; Our local contains the input, so set eax
		mov eax, [edx]

        ; restore general purpose registers
        pop edi
		pop edx
		pop ecx

        ; fully reset the stack and base pointers to whatever they were
        mov esp, ebp
        pop ebp

		ret
GetNumber ENDP

;======================================================================================================================

END

