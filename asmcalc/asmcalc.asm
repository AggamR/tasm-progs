;Aggam Rahamim
IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------
    num1 dw 0
    num2 dw 0
    resadd dd 0
    bigmsg db 'the result of this calculation is out of range for ASMCalc to handle.$'
    needeqerrmsg db 'you need to type equal (=) to finish.$'
    numinpdw dw 0  ; for inpdw
    largeinperr db 'you have entered a number too big.$'  ; for inpdw
    opr db 0
    modd dw 0
    temp dw 0
    facerrmsg db "You cannot factorial 9.$"
    d0err db "division by 0 is not supported.$"
    n1err db "the first caharcter input should be a number.$"
    n2err db "the third caharcter input should be a number.$"
    WelcomeMSG db "Hello, welcome to ASMCalc. This is a calculator developed in assembly. The usage goes as followed: $"
    WelcomeMSG2 db "the first operand first, followed by the mathematical operation, followed by the second operand. If you would like to do a square root, you may enter a two digit number and press 's' on your keyboard. Press the ESC key to quit.$"
    signERR db "The second character input should be a one of the following math operations (+, -, /, x, ^, !).$"
CODESEG
; FUNCS
proc inpdw
    pop ax
    mov [numinpdw], 0
    mov [temp], ax
    xor di, di  ; used for equal
    xor si, si
    mov ax, '$$'
    push ax  ; IGNORE_LINE
    mov bx, 10
	xor bp, bp
getdw:
    mov ah, 1h
    int 21h
    sub al, '0'
    cmp al, 10
    jb isnumberdwinp
    add al, '0'
    cmp al, '='
    jne noteqdwinp
    mov di, 1
    jmp endgetdw
noteqdwinp:
    cmp al, 27
    jne notescinpdw
    ;jmp myExit
	mov bp, 69h
	jmp endasmdw
notescinpdw:
    mov [opr], al
    jmp endgetdw
isnumberdwinp:
    xor ah, ah
    push ax
    jmp getdw
endgetdw:
    pop ax
    cmp ax, '$$'
    je endasmdw
    ; put in num here
    mov cx, si
    cmp cx, 0
    jne mult10dwinp
    add [numinpdw], ax
    inc si
    jmp endgetdw
mult10dwinp:
    mul bx
    cmp dx, 0
    je notDXErr
    mov dx, offset largeinperr
    call print
notDXErr:
    loop mult10dwinp
    ;
    add [numinpdw], ax
    inc si  ; counter for digit num 
    jmp endgetdw
endasmdw:
    mov dx, [temp]
    push dx
    ret
endp
proc printdd
    cmp dx, 0
    je printddax
    mov bx, 10000
	div bx
	mov [temp], dx
	call printAX
	mov ax, [temp]
	call printAX0
    jmp endprintdd
printddax:
    call printAX
endprintdd:
	ret
endp
proc sqrt  ; sqrt num1 -> result in ax
    xor cx, cx
sqrtLoop:
    cmp cx, [num1]
    je endLoop
    mov ax, cx
    mul ax
    cmp ax, [num1]
    ja endLoop
    inc cx
    jmp sqrtLoop 
endLoop:
    dec cx
    mov ax, cx
    ret
endp
proc printChar
    mov ah, 2h
    int 21h
    ret
endp
proc newline
    push ax
    push dx
    mov dl, 10
    mov ah, 2h
    int 21h
    pop dx
    pop ax
    ret
endp
proc fac  ; factorials num1
facmain:
    xor dx, dx
    xor ax, ax
    xor bx, bx
	xor di, di
    mov cx, [num1]  ; num of times to multiply
    sub cx, 2
    mov ax, [num1]
	mov si, ax
    mov bx, 2
dofac:
	mov ax, di
    mul bx
	mov di, ax
	mov ax, si
	mul bx
	mov si, ax
	add di, dx
    inc bx
    loop dofac
	mov ax, si
	mov dx, di
    ret
endp
proc printAX
    push bp
	mov bp, sp
	mov bp, 10  ;Constant divider 10
	push bp      ;Will signal the end of the PUSHed remainders
    mov di, 1
NextAX:
	mul di
	div bp      ;Divide Word3
	push dx
	cmp ax, 0
	jne NextAX   ;
	pop dx      ;This is digit for sure
	mov ah, 2h
MoreAX:
	add dl, '0' ;Convert from remainder [0,9] to character ["0","9"]
	int 21h     ;DisplayCharacter
	pop dx  ; BYPASS_POP_MATCH
	cmp dx, bp  ;Repeat until it was the 'signal (bp=10)' that was POPed
	jb MoreAX
	pop bp
	ret
endp
proc printAX0
    push bp
    xor si, si  ; for counter of times printed char
	mov bp, sp
	mov bp, 10  ;Constant divider 10
	push bp      ;Will signal the end of the PUSHed remainders
Next0ax:
	push di
	mov di, 1
	mul di
	pop di
	div bp      ;Divide Word3
	push dx
	cmp ax, 0
	jne Next0ax    ;
	pop dx      ;This is digit for sure
	mov ah, 2h
More0ax:
	add dl, '0' ;Convert from remainder [0,9] to character ["0","9"]
	int 21h  ;DisplayCharacter
    inc si  ; as counter
	pop dx  ; BYPASS_POP_MATCH
	cmp dx, bp  ;Repeat until it was the 'signal (bp=10)' that was POPed
	jb More0ax
    ;
    mov cx, 4
    cmp si, 4
    je endprintax0
    sub cx, si
printin0s:
    mov dl, '0'
    int 21h
    loop printin0s
endprintax0:
	pop bp
	ret
endp
proc print
    mov ah, 9h
    int 21h
    mov ah, 2 ; new line
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h
    ret
endp
proc powfunc
    xor dx, dx
    xor ax, ax
    xor bx, bx
	xor di, di ; dx
    mov cx, [num2]
    dec cx  ; to fix
    mov ax, [num1]
	mov si, ax
    mov bx, [num1]
doPow:
	mov ax, di
    mul bx
	mov di, ax
	mov ax, si
	mul bx
	mov si, ax
	add di, dx
    loop doPow
	mov ax, si
	mov dx, di
	call printdd
    ret
endp
start:
    mov ax, @data
    mov ds, ax
; --------------------------
; Your code here
; --------------------------
    mov dx, offset WelcomeMSG
    call print
    mov dx, offset WelcomeMSG2
    call print
    call newline
cont:
    call newline
    ; get num 1
    ;==========
    call inpdw
	cmp bp, 69h
	jne notexit1
	jmp myExit
notexit1:
    mov ax, [numinpdw]
    mov [num1], ax
    cmp [opr], 's'
    jne notSqrtOpr
    jmp handler
notSqrtOpr:
    cmp [opr], '!'
    jne notFactOpr
    jmp handler
notFactOpr:
    ; get num 2
    ;==========
    call inpdw
	cmp bp, 69h
	jne notexit2
	jmp myExit
notexit2:
    mov ax, [numinpdw]
    mov [num2], ax
    cmp di, 1
    jne needeqerr
    jmp handler
needeqerr:
    call newline
    mov dx, offset needeqerrmsg
    call print
    jmp cont
facErr:
    call newline
    mov dx, offset facerrmsg
    call print
    jmp cont
factorial:
    cmp [num1], 0
    jne fanNotZero
    mov dl, '='
    call printChar
    mov ax, 1
    call printAX
    jmp cont
fanNotZero:
    ; print =
    mov [temp], ax
    mov dl, '='
    call printChar
    mov ax, [temp]
    ;
    cmp ax, 9
    jb facbelow9
    call newline
    mov dx, offset bigmsg
    call print
    jmp cont
    ;
facbelow9:
    cmp ax, 2
    ja facabove2
    mov dl, al
    add dl, '0'
    call printChar
    jmp cont
facabove2:
    xor ah, ah
    xor cx, cx
    call fac
    call printdd
    jmp cont
num1err:
    call newline
    mov dx, offset n1err
    call print
    jmp cont
num2err:
    call newline
    mov dx, offset n2err
    call print
    jmp cont
notSignERR:
    call newline
    mov dx, offset signERR
    call print
    jmp cont
; addtion
;========
addition:
    xor dx, 0
    mov ax, [num1]
    add ax, [num2]
    cmp ax, [num1]
    ja additionSucceded
    cmp ax, [num2]
    ja additionSucceded
    call newline
    mov dx, offset bigmsg
    call print
    jmp cont
additionSucceded:
    call printAX
    jmp cont
; multiplication
;===============
mult:
    mov ax, [num1]
    mul [num2]
    call printdd
    jmp cont
; sqrt
;=========
doSqrt:
    call sqrt
    push ax
    mov dl, '='
    call printChar
    pop ax
    call printAX
    jmp cont
; handler
;========
handler: ; handles where to go
    cmp [opr], '+'  ;dw
    je addition
    cmp [opr], 'x'  ;dw
    je mult
    cmp [opr], '-'  ;dw
    je subt
    cmp [opr], '/'  ;dw
    je division
    cmp [opr], '^'  ;dw
    je Power
    cmp [opr], 's'  ;dw
    je doSqrt
    cmp [opr], '!'  ;dw
    jne handlererr
    jmp factorial
handlererr:
    jmp notSignERR
; Power
; =====
power:
    call powfunc
    jmp cont
; subtraction
;============
subt:
    mov ax, [num1]
    sub ax, [num2]
    cmp ax, 0
    jl subminus
    cmp ax, [num1]
    ja toolowsub
    call printAX
    jmp cont
subminus:
    push ax
    mov dl, '-'
    call printChar
    pop ax
    neg ax
    call printAX
    jmp cont
toolowsub:
    call newline
    mov dx, offset bigmsg
    call print
    jmp cont
; division
;=========
division:
    xor dx, dx
    cmp [num2], 0
    je Div0ERR
    mov ax, [num1]
    div [num2]  ; ax-result, dx-mod
    mov [modd], dx
    call printAX
    cmp dx, 0
    jne addMod
    jmp cont
Div0ERR:
    call newline
    mov dx, offset d0err
    call print
    jmp cont
addMod:
    mov dl, '('
    call printChar
    mov ax, [modd]
    call printAX
    mov dl, ')'
    call printChar
    jmp cont
; exitin the code
;================
myExit:
exit:
    mov ax, 4C00h
    int 21h
END start
