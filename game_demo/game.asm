IDEAL
MODEL small
STACK 100h
DATASEG
    startX dw 0
    endX dw 320
    startY dw 0
    endY dw 200
    ;
	charx dw 11
	chary dw 11
	;
	movx db 0
	movy db 0
CODESEG
proc prepPixelRead
	mov ah, 0Dh
	xor bh, bh
	mov cx, [charx]
	mov dx, [chary]
endp prepPixelRead

proc getKey  ; returns in al ascii of capital letter of key pressed
	xor ah, ah
	int 16h
	xor ah, ah
	mov di, ax
	cmp di, 27
	jne notexitgetkey
	jmp exit
notexitgetkey:
	cmp di, 96
	jg isLowerGK
	ret
isLowerGK:
	sub di, 32
	ret
endp getKey

proc drawPixel
    mov bh, 0h
    mov ah, 0ch
    int 10h
    ret
endp drawPixel

proc drawRec  ; give it X,Y for start and X,Y for end end of rec.
    mov dx, [startY]
loopCol:
    cmp dx, [endY]
    je leaveColLoop
    mov cx, [startX]
loopRow:
    ; start row loop
    cmp cx, [endX]
    je leaveRowLoop
    ; DX has Y of pixel to draw | CX has X
    call drawPixel
    inc cx
    jmp loopRow
leaveRowLoop:
    ; endproc
    inc dx
    jmp loopCol
leaveColLoop:
    ret
endp drawRec

proc movPlayer  ; by movx, movy
	xor ax, ax
	cmp [movx], 1 
	je movx1
	ja movxSub1
	jmp endmovx
	movx1:
	mov cx, [charx]
	mov dx, [chary]
	call drawPixel
	mov al, 2
	inc cx
	inc [charx]
	call drawPixel
	jmp endmovx
	movxSub1:
	mov cx, [charx]
	mov dx, [chary]
	call drawPixel
	mov al, 2
	dec cx
	dec [charx]
	call drawPixel
	jmp endmovx
	endmovx:
	xor ax, ax
	cmp [movy], 1
	je movy1
	ja movySub1
	ret
	movy1:
	mov cx, [charx]
	mov dx, [chary]
	call drawPixel
	mov al, 2
	inc dx
	inc [chary]
	call drawPixel
	ret
	movySub1:
	mov cx, [charx]
	mov dx, [chary]
	call drawPixel
	mov al, 2
	dec dx
	dec [chary]
	call drawPixel
	ret
endp movPlayer
; ===========================
start:
    mov ax, @data
    mov ds, ax
    ; CODE
    ; Graphic mode
    mov ax, 13h
    int 10h
	; draw map
	mov al, 1 ; blue
	mov [endX], 320
	mov [endY], 10
	call drawRec
	mov [endX], 10
	mov [endY], 200
	call drawRec
	mov [startX], 310
	mov [endX], 320
	call drawRec
	mov [startX], 10
	mov [startY], 190
	mov [endY], 200
	call drawRec
	; draw player
	mov cx, [charx]
	mov dx, [chary]
	mov al, 2 ; green
	call drawPixel
mainLoop:
	; check if key presses, leave prog if esc pressed
	call getKey
	; prep for reading pixel
	mov ah, 0Dh
	xor bh, bh
	mov cx, [charx]
	mov dx, [chary]
	;
	cmp di, 'W'
	je wPressed
	cmp di, 'S'
	je sPressed
	cmp di, 'A'
	je aPressed
	cmp di, 'D'
	je dPressed
	; end main loop
	jmp mainLoop
wPressed:
	dec dx
	int 10h
	cmp al, 1  ; blue - color of wall
	je mainLoop
	mov [movx], 0
	mov [movy], 2 ; meaning reverse
	call movPlayer
	jmp mainLoop
sPressed:
	inc dx
	int 10h
	cmp al, 1
	je mainLoop
	mov [movx], 0
	mov [movy], 1
	call movPlayer
	jmp mainLoop
aPressed:
	dec cx
	int 10h
	cmp al, 1
	je mainLoop
	mov [movx], 2
	mov [movy], 0
	call movPlayer
	jmp mainLoop
dPressed:
	inc cx
	int 10h
	cmp al, 1
	je mainLoop
	mov [movx], 1
	mov [movy], 0
	call movPlayer
	jmp mainLoop
exit:
    ; Return to text mode (monke)
    mov ah, 0
    mov al, 2
    int 10h
    mov ax, 4c00h
    int 21h
END start