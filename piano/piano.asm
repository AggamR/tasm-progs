IDEAL
MODEL small
STACK 100h
DATASEG
	filename db 'piano.bmp',0
	filehandle dw ?
	Header db 54 dup (0)
	Palette db 256*4 dup (0)
	ScrLine db 320 dup (0)
	ErrorMsg db 'Error', 13, 10 ,'$'
    startX dw 0
    endX dw 320
    startY dw 0
    endY dw 200
    var1 dw 0
    var2 dw 0
    oldPalette db 256*3 dup(?)
CODESEG 
;====
; PICS FUNCS
proc OpenFile
	; Open file
	mov ah, 3Dh
	xor al, al
	mov dx, offset filename
	int 21h
	jc openerror
	mov [filehandle], ax
	ret
openerror :
	mov dx, offset ErrorMsg
	mov ah, 9h
	int 21h
	ret
endp 
proc ReadHeader
	; Read BMP file header, 54 bytes
	mov ah,3fh
	mov bx, [filehandle]
	mov cx,54
	mov dx, offset Header
	int 21h
	ret
endp ReadHeader
proc ReadPalette
	; Read BMP file color palette, 256 colors * 4 bytes (400h)
	mov ah, 3fh
	mov cx, 400h
	mov dx, offset Palette
	int 21h
	ret
endp 
proc CopyPal
	; Copy the colors palette to the video memory
	; The number of the first color should be sent to port 3C8h
	; The palette is sent to port 3C9h
	mov si, offset Palette
	mov cx, 256
	mov dx, 3C8h
	mov al, 0
	; Copy starting color to port 3C8h
	out dx, al
	; Copy palette itself to port 3C9h
	inc dx
PalLoop:
	; Note: Colors in a BMP file are saved as BGR values rather than RGB .
	mov al,[si+2] ; Get red value .
	shr al,2 ; Max. is 255, but video palette maximal
	; value is 63. Therefore dividing by 4.
	out dx,al ; Send it .
	mov al,[si+1] ; Get green value .
	shr al,2
	out dx,al ; Send it .
	mov al,[si] ; Get blue value .
	shr al,2
	out dx,al ; Send it .
	add si,4 ; Point to next color .
	; (There is a null chr. after every color.)
	loop PalLoop
	ret
endp 
proc CopyBitmap
	; BMP graphics are saved upside-down .
	; Read the graphic line by line (200 lines in VGA format),
	; displaying the lines from bottom to top.
	mov ax, 0A000h
	mov es, ax
	mov cx,200
	PrintBMPLoop :
	push cx
	; di = cx*320, point to the correct screen line
	mov di,cx
	shl cx,6
	shl di,8
	add di,cx
	; Read one line
	mov ah,3fh
	mov cx,320
	mov dx,offset ScrLine
	int 21h
	; Copy one line into video memory
	cld ; Clear direction flag, for movsb
	mov cx,320
	mov si,offset ScrLine
	rep movsb ; Copy line to the screen
	;rep movsb is same as the following code :
	;mov es:di, ds:si
	;inc si
	;inc di
	;dec cx
	;loop until cx=0
	pop cx
	loop PrintBMPLoop
	ret
endp 
;====
proc sleep  ; recives loop time and 2nd loop time (change 2nd time - better resulst)
	pop [var1]
	pop cx  ; loop time
	pop si  ; 2nd loop time
bause:
	xor di, di
loob:
	inc di
	cmp di, si
	jb loob
	loop bause
	; endproc
	push [var1]
	ret
endp
proc playsound  ; recives freq
	pop [var2]
	; open speaker
    in al, 61h
    or al, 00000011b
    out 61h, al
    ; send control word to change frequency
    mov al, 0B6h
    out 43h, al
    pop ax  ; get freq
    out 42h, al  ; Sending lower byte
    mov al, ah
    out 42h, al  ; Sending upper byte
    ; sleep
    push 10000
	push 20  ; adjust this - better
	call sleep
    ; close the speaker
    in al, 61h
    and al, 11111100b
    out 61h, al
	;endproc
	push [var2]
	ret
endp
proc drawPixel
    mov bh, 0h
    ;mov al, al
    mov ah, 0ch
    int 10h
    ret
endp
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
endp
proc mouseClicked   ; cx-x, dx-y
    cmp dx, 121
    jb goodYLvl
    jmp quitMouseClicked
goodYLvl:
    cmp cx, 5
    jb notClickA
    cmp cx, 70
    ja notClickA
    mov [startX], 5
    mov [endX], 35
    mov al, 69  ; nice
    call drawRec
    push 3520
	call playsound
    mov al, 24
    call drawRec
    jmp quitMouseClicked
notClickA:
    cmp cx, 90
    jb notClickB
    cmp cx, 150
    ja notClickB
    mov [startX], 45
    mov [endX], 75
    mov al, 69  ; nice
    call drawRec
    push 3135
	call playsound
    mov al, 24
    call drawRec
    jmp quitMouseClicked
notClickB:
    cmp cx, 170
    jb notClickC
    cmp cx, 230
    ja notClickC
    mov [startX], 85
    mov [endX], 115
    mov al, 69  ; nice
    call drawRec
    push 2793
	call playsound
    mov al, 24
    call drawRec
    jmp quitMouseClicked
notClickC:
    cmp cx, 250
    jb notClickD
    cmp cx, 310
    ja notClickD
    mov [startX], 125
    mov [endX], 155
    mov al, 69  ; nice
    call drawRec
    push 2637
	call playsound
    mov al, 24
    call drawRec
    jmp quitMouseClicked
notClickD:
    cmp cx, 330
    jb notClickE
    cmp cx, 390
    ja notClickE
    mov [startX], 165
    mov [endX], 195
    mov al, 69  ; nice
    call drawRec
    push 2349
	call playsound
    mov al, 24
    call drawRec
    jmp quitMouseClicked
notClickE:
    cmp cx, 400
    jb notClickF
    cmp cx, 460
    ja notClickF
    mov [startX], 205
    mov [endX], 235
    mov al, 69  ; nice
    call drawRec
    push 2093
	call playsound
    mov al, 24
    call drawRec
    jmp quitMouseClicked
notClickF:
    cmp cx, 480
    jb notClickG
    cmp cx, 540
    ja notClickG
    mov [startX], 245
    mov [endX], 275
    mov al, 69  ; nice
    call drawRec
    push 1975
	call playsound
    mov al, 24
    call drawRec
    jmp quitMouseClicked
notClickG:
    cmp cx, 560
    jb notClickH
    cmp cx, 620
    ja notClickH
    mov [startX], 285
    mov [endX], 315
    mov al, 69  ; nice
    call drawRec
    push 1760
	call playsound
    mov al, 24
    call drawRec
notClickH:
quitMouseClicked:
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
;WORD Buffer Segment
;WORD Buffer  Offset
;DF = Direction of saving
start:
    mov ax, @data
    mov ds, ax
    ; CODE
    ; Graphic mode
    mov ax, 13h
    int 10h
    ; Save old palette
    mov ax, 1017h
    mov bx, 0
    mov cx, 256
    mov dx, ds
    mov es, dx
    mov dx, offset oldPalette
    int 10h
    ; BMP
	call OpenFile
	call ReadHeader
	call ReadPalette
	call CopyPal
	call CopyBitmap 
	; Wait for key press
	mov ah,1
	int 21h
    mov al, 124
    ; Restore old palette
    mov ax, 1012h
    mov bx, 0
    mov cx, 256
    mov dx, ds
    mov es, dx
    mov dx, offset oldPalette
    int 10h
    ; backgroud
    mov ah, 0B6h
    mov bh, 00h
    mov bl, 0
    int 10h
    ;
    call drawRec
    ; Mouse:
    mov ax,0h
    int 33h
    mov ax,1h
    int 33h
; draw piano
drawPiano:
    mov al, 24  ; set color
    ;X:
    mov bx, 8
    mov [startX], 5
    mov [endX], 35
    mov [startY], 0
    mov [endY], 120
drawPianoLoop:
    call drawRec
    add [startX], 40
    add [endX], 40
    cmp bx, 0
    dec bx
    jne drawPianoLoop
mainLoop:
    mov ax,3h
    int 33h
    and bl, 00000011b 
    ; mouse
    cmp bx, 01b  ; left-click
    jne noClick
    call mouseClicked  ; func to when mouse has been clicked - so play sound
    jmp drawPiano
noClick:
    ;ESC
    mov ah, 1
    int 16h
    jz mainLoop
    mov ah, 0
    int 16h
    cmp ah, 1h
    je returnTextMode
    jmp mainLoop
returnTextMode:
    ; Return to text mode (monke)
    mov ah, 0
    mov al, 2
    int 10h
exit:
    mov ax, 4c00h
    int 21h
END start