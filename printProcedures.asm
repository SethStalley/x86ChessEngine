global print		;global procedures contained here
global printSpace
global printBitMap
extern	printf
section .data
	printH		db	"%016llx",10,0	;print in hex 64bit
	printD		db	"%d",10,0	;print normal decimal
	printNoSpace	db	"%d",0		;print normal decimal
	printHere	db	"Here",10,0	;test msg
	nwln		db	10,0		;new line
section .text
print:			;print rax for testing
	push rax
	push rcx	;printf used this save it
	push rsi
	push rdi
	push rdx
	mov rsi,rax
	mov rdi, printD
	xor rax, rax
	call printf
	pop rdx
	pop rdi
	pop rsi
	pop rcx
	pop rax
	ret

printSpace:
	push rsi
	push rax
	push rcx
	mov edi, nwln
	xor rax, rax
	call printf
	pop rcx
	pop rax
	pop rsi
	ret

printBitMap:		;print a bitmap stored in rax
	push rbx
	push rcx
	push rsi
	push rdi
	xor rcx, rcx
	mov rsi, 0x8000000000000000
printBitMapFiles:
	cmp ch, 8
	je donePrintBitMap
	call printSpace
	inc ch
	xor cl, cl
printBitMapColums:
	cmp cl, 8
	je printBitMapFiles
	inc cl
	push rsi
	push rcx
	push rax
	and rsi, rax		;is this bit on
	mov rax, rsi
	cmp rsi, 0
	je showBit
	mov rsi, 1
showBit:
	mov rdi, printNoSpace
	xor rax, rax
	call printf
	pop rax
	pop rcx
	pop rsi
	shr rsi, 1
	jmp printBitMapColums
donePrintBitMap:
	call printSpace
	pop rdi
	pop rsi
	pop rcx
	pop rbx
	ret
