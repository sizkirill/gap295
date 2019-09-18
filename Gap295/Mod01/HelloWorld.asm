; HelloWorld.asm
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
	helloWorld db 'Hello world: %d', 0Ah, 0  ; super version
	
; Beginning of code section.	
.code

; This is the main entry point.  It must be named main and follow the C calling convention.  This will cause it to 
; be automatically treated as the main entry point, like the main() function in C programs.
main proc C
		; Regular credit:
		; 1) Move 42 into eax.
                mov eax, 42
		push eax

		; Push address of the string we want to pass onto the stack.
		push offset helloWorld
		
		; Call the printf function.
		call printf
		
		; Reset the stack pointer back to where it was before the function call.  This effectively deallocates the 
		; the parameter we passed in.
		add esp, 8

		; EAX is used as the return value for all functions.  Doing this will return success back to the operating 
		; system.
		mov eax, 0
		ret
main endp

END
