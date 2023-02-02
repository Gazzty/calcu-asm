.8086
.model small
.stack 100h
.data
	;General text
	msg db "CALCU", 24h
	team db "2 a la N team  UNSAM", 24h

	;Screen 1 text
	startText1 db "Presione ENTER para jugar",0dh, 0ah, 24h
	startText2 db "o ESC para salir", 24h
	empty db "                         ", 24h
	
	;Screen 2 text
	acertijoMsg1 db "Resuelva 3 acertijos", 24h
	acertijoMsg2 db "y podra superar el desafio...", 24h
	heart db 03h,24h
	emptyHeart db " ",24h

	;WinScreen text
	win1 db "Superaste la prueba!", 24h
	win2 db "Sos un maestro de las mates", 24h
	;LoseScreen text
	lose1 db "Fallaste...", 24h
	lose2 db "Repetis el cuatri...", 24h

	;Loading screen
	dot db 04h, 04h, 04h, 24h
	emptyDot db "   ", 24h
	emptyAll db "", 24h
	;CreditScreen
	credit db "Creditos:",0ah, 24h
	c1	db "		Gustavo Muinos",0ah, 24h
	c2	db "		Agustin Gutierrez",0ah, 24h
	c3	db "		Emiliano Ferreti",0ah, 24h
	c4	db "		Sebastian Agostini",0ah, 24h

	;VARIABLES PARA CALCULO
	;Variables de texto
    salto db 0dh, 0ah, 24h
    paren1 db "(", 24h
    paren2 db ")", 24h

    ;Variables numericas
    num1 dw 0
    num2 dw 0
    num3 dw 0
    num1A db 255 dup(24h)
    num2A db 255 dup(24h)
    num3A db 255 dup(24h)
    op db " ",24h
	op2 db " ", 24h
    playerRes db 255 dup(24h)
    sign db 0
    playerSign db 0
    resR dw 0
    resA db "00000", 24h
    prevRNG dw 0
	life db 3
	jugadas db 0
	jugadasA db 255 dup(24h)
	totalJugadas db "3", 24h
	
.code
;PUBLICS
public pantallaCarga
public pantalla1
public pantalla2
public winScreen
public loseScreen
public delay
public creditfin
;IMPORTS
extrn len:proc
extrn lectura:proc

;PRINT MACRO
print macro param
	mov ah, 09h
	lea dx, param	
	call DS_DATOS	
	int 21h
	call DS_VIDEO
endm

;Print text function
;Se pasa la variable por STACK
;Columna por DL y fila por DH
;Pantalla por bh
;23 filas, 118 columnas
printText proc
	push bp
	mov bp, sp
	push ax
	push bx
	push si
	mov si, ss:[bp + 4]		;variable a imprimir

	xor ax, ax
		mov ah, 02h
		int 10h
		print [si] 

	pop si
	pop bx
	pop ax
	pop bp
	ret 2
printText endp

;Print letter by letter like RPG games
;Se pasa la variable por STACK
;Columna por DL y fila por DH
;Pantalla por bh
;23 filas, 118 columnas
printLetter proc
	push bp
	mov bp, sp
	push ax
	push bx
	push si
	mov si, ss:[bp + 4]		;variable a imprimir

	xor ax, ax
		mov ah, 02h
		int 10h
		call DS_DATOS ;Cambia de DS al lugar de las variables
	
		printLet:
		cmp byte ptr [si], 24h
		je finPrintLet
		mov ah, 02h
		mov dx, [si]
		int 21h
		;Delay between letters
		mov cx, 1200
		call delay
		;Incrementa counter, y columna
		inc si
		inc dl
		jmp printLet

	finPrintLet:
	call DS_VIDEO ;Cambio de DS a memoria de video

	pop si
	pop bx
	pop ax
	pop bp
	ret 2
printLetter endp

;DELAY FUNC 
;Se pasa parametro por cx
delay proc   
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	xor ax, ax
	xor bx, bx
    mov ax,cx
    ret2:
		dec ax
		jz finRet
		mov bx, cx
		ret1:
			dec bx
		jnz ret1
	jmp ret2                
    finRet:

	pop cx
    pop bx
	pop ax
	pop bp
	ret
delay endp

INI_VIDEO proc
push ax
 mov ax, 13h
 int 10h
 mov ax, 0A000h
 mov ds, ax
 pop ax
 ret

INI_VIDEO endp

END_VIDEO PROC
push ax
 mov ax, 3h
 int 10h
 mov ax, @data
 mov ds, ax
 pop ax
 ret

END_VIDEO endp

pintar_pixel macro i, j, color
    push ax
    push bx
    push di
    xor ax, ax
    xor bx, bx
    xor di, di
    mov ax, 320d
    mov bx, i
    mul bx
    add ax, j
    mov di, ax
    mov byte ptr [di], color
    pop di
    pop bx
    pop ax
endm

pintar_marco macro izq, der, arr, aba, color
		LOCAL ciclo1, ciclo2
		push si
		xor si, si
		mov si, izq
		ciclo1:
			pintar_pixel arr, si, color
			pintar_pixel aba, si, color
			inc si
			cmp si, der
		jne ciclo1

		xor si, si
		mov si, arr
		ciclo2:
			pintar_pixel si, der, color
			pintar_pixel si, izq, color
			inc si
			cmp si, aba
		jne ciclo2
		pop si
endm

	;Cambia DS a donde tenemos las variables 
	DS_DATOS proc
		push ax
		mov ax, @data
		mov ds,ax
		pop ax
		ret
	DS_DATOS endp

	;Cambia DS a memoria de video
	DS_VIDEO proc
		push ax
		mov ax, 0A000h
		mov ds, ax
		pop ax
		ret
	DS_VIDEO endp

pantallaCarga proc
push bp
mov bp, sp
push ax
push bx
push cx
push dx
push si
push di

xor ax, ax
xor bx, bx
xor cx, cx
xor dx, dx
xor si, si
xor di, di

;Inicia la pantalla con el video y su contenido
    call INI_VIDEO

	;Inicio pantalla de carga
	;*-TEMPLATE-*
    ;Pinta el marco
    pintar_marco 20d, 299d, 20d, 180d, 10d
	;*-END TEMPLATE-*
	xor di, di
	;prints dots
	printDot:
	mov dh, 13d
	mov dl, 59d
	mov bh, 04h
	lea bx, dot
	push bx
	call printLetter

	mov cx, 15
	call delay

	mov dh, 13d
	mov dl, 59d
	mov bh, 04h
	lea bx, emptyDot
	push bx
	call printLetter

	mov cx, 100
	call delay

	inc di
	cmp di, 3
	jbe printDot

	call END_VIDEO
pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp
ret
pantallaCarga endp

pantalla1 proc
push bp
mov bp, sp
push bx
push cx
push dx
push si
push di

xor ax, ax
xor bx, bx
xor cx, cx
xor dx, dx
xor si, si
xor di, di

;PANTALLA 1
    call INI_VIDEO
	;IMPRIME TEXTO EN PANTALLA
		mov dh, 1d
		mov dl, 57d
		mov bh, 00h
		lea bx, msg
		push bx
		call printText

    ;Pinta el marco
    pintar_marco 20d, 299d, 20d, 180d, 10d

	;IMPRIME nombre del equipo
		mov dh, 23d
		mov dl, 106d
		mov bh, 00h
		lea bx, team
		push bx
		call printText

	;La espera es para el flashing effect
	espera:
	;Delay para la frecuencia del flash
	mov cx, 3000
	call delay
	;TEXTO DE INICIO
	mov dh, 8d
	mov dl, 8d
	mov bh, 00h
	lea bx, startText1
	push bx
	call printText
	;Imprime el 2do renglon
	mov dh, 10d
	mov dl, 11d
	mov bh, 00h
	lea bx, startText2
	push bx
	call printText
	
	;Delay para la frecuencia del flash
	mov cx, 5000
	call delay

	;FLASHING EFFECT
	mov dh, 8d
	mov dl, 8d
	mov bh, 00h
	lea bx, empty
	push bx
	call printText
	;2do renglon
	mov dh, 10d
	mov dl, 11d
	mov bh, 00h
	lea bx, empty
	push bx
	call printText

	;Espera
	mov ah, 01h
	int 16h
	jnz casiFin
	jmp espera

	casiFin:
	mov AH, 0
	int 16h
	cmp al, 0dh
	je juega
	cmp al, 1Bh
	je finJuego
	jmp espera

	finJuego:
		mov al, 1
		jmp finPantalla1
	juega:
		mov al, 0
		mov cx, 1809d
		mov bx, 30d
		call play
		mov cx, 2415d
		mov bx, 40d
		call play

	finPantalla1:
	call DS_VIDEO 	;Cambio de DS a memoria de video
	call END_VIDEO

pop di
pop si
pop dx
pop cx
pop bx
pop bp
ret
pantalla1 endp

pantalla2 proc
push bp
mov bp, sp
push ax
push bx
push cx
push dx
push si
push di

call INI_VIDEO

	pintar_marco 20d, 299d, 20d, 180d, 10d

	call DS_DATOS
	mov dh, 1d
	mov dl, 57d
	mov bh, 01h
	lea bx, msg
	push bx
	call printText
	call DS_VIDEO
    ;Pinta el marco
    pintar_marco 20d, 299d, 20d, 180d, 10d
	;IMPRIME nombre del equipo
	call DS_DATOS
	mov dh, 23d
	mov dl, 106d
	mov bh, 01h
	lea bx, team
	push bx
	call printText
	call DS_VIDEO
	;*-END TEMPLATE-*

	;IMPRIME TEXTO ACERTIJO	
	mov dh,	5d
	mov dl, 50d
	mov bh, 01h
	lea bx, acertijoMsg1
	push bx
	call printText
	mov dh, 7d
	mov dl, 05d
	mov bh, 01h
	lea bx, acertijoMsg2
	push bx
	call printText

	;SE IMPRIME LA OPERACIÓN
	mov dh, 11d
	mov dl, 52d
	mov bh, 01h
	lea bx, emptyDot
	push bx
	call printText
	;parentesis 1
	lea bx, paren1
	push bx
	call DS_DATOS
	call printText
	call DS_VIDEO
	;primer numero
	lea bx, num1A
	push bx
	call DS_DATOS
	call printNum
	call DS_VIDEO
	;primer operando
	lea bx, op
	push bx
	call DS_DATOS
	call printText
	call DS_VIDEO
	;Segundo numero
	lea bx, num2A
	push bx
	call DS_DATOS
	call printNum
	call DS_VIDEO
	;Parentesis 2
	lea bx, paren2
	push bx
	call DS_DATOS
	call printText
	call DS_VIDEO
	;Operando 2
	lea bx, op2
	push bx
	call DS_DATOS
	call printText
	call DS_VIDEO
	;Numero 3
	lea bx, num3A
	push bx
	call DS_DATOS
	call printNum
	call DS_VIDEO

	;LIFE BOX
	pintar_marco 184d, 234d, 367d, 384d, 1d
	;Heart drawing 1
	mov dh, 21
	mov dl, 112
	mov bh, 01h
	lea bx, heart
	push bx
	call printText
	call DS_DATOS
	cmp life, 1
	je endLife
	call DS_VIDEO
	;Heart drawing 2
	mov dh, 21
	mov dl, 114
	mov bh, 01h
	lea bx, heart
	push bx
	call printText
	call DS_DATOS
	cmp life, 2
	je endLife
	call DS_VIDEO
	;Heart drawing 3
	mov dh, 21
	mov dl, 116
	mov bh, 01h
	lea bx, heart
	push bx
	call printText
	endLife:

	;Soluciona error de la caja
	;(por algun motivo...)
	call DS_DATOS
	lea bx, emptyAll
	push bx
	mov dh, 1d
	mov dl, 1d
	mov bh, 01h
	call printText
	call DS_VIDEO

	;118 filas y 23 columnas
	;INPUT BOX
	;izq, der, arr, aba, color
	pintar_marco 70d, 255d, 115d, 135d, 5d
	mov dh, 15d
	mov dl, 54d
	mov bh, 01h
	lea bx, emptyDot
	push bx
	call printText
	lea bx, playerRes
	push bx
	call DS_DATOS
	call lectura
	mov playerSign, ch
	call DS_VIDEO
	
	;Borra corazones para que no aparezcan cuando pierde vidas
	mov dh, 21
	mov dl, 112
	mov bh, 01h
	lea bx, emptyHeart
	push bx
	call printText
	mov dh, 21
	mov dl, 114
	mov bh, 01h
	lea bx, emptyHeart
	push bx
	call printText
	mov dh, 21
	mov dl, 116
	mov bh, 01h
	lea bx, emptyHeart
	push bx
	call printText

	call END_VIDEO
pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp
ret
pantalla2 endp

winScreen proc
push bp
mov bp, sp
push ax
push bx
push cx
push dx
push si
push di

call INI_VIDEO

mov dh, 1d
	mov dl, 57d
	mov bh, 02h
	lea bx, msg
	push bx
	call printText
    ;Pinta el marco
    pintar_marco 20d, 299d, 20d, 180d, 10d
	;IMPRIME nombre del equipo
	mov dh, 23d
	mov dl, 106d
	mov bh, 02h
	lea bx, team
	push bx
	call printText
	;*-END TEMPLATE-*

	;Prints letter by letter to make RPG style text
	mov dh, 7d
	mov dl, 8d
	mov bh, 02h
	lea bx, win1
	push bx
	call printLetter
	mov dh, 15d
	mov dl, 7d
	mov bh, 02h
	lea bx, win2
	push bx
	call printLetter

	;wait input
	mov ah, 08h
	int 21h

    call END_VIDEO
pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp
ret
winScreen endp

loseScreen proc
push bp
mov bp, sp
push ax
push bx
push cx
push dx
push si
push di

call INI_VIDEO

mov dh, 1d
	mov dl, 57d
	mov bh, 02h
	lea bx, msg
	push bx
	call printText
    ;Pinta el marco
    pintar_marco 20d, 299d, 20d, 180d, 10d
	;IMPRIME nombre del equipo
	mov dh, 23d
	mov dl, 106d
	mov bh, 02h
	lea bx, team
	push bx
	call printText
	;*-END TEMPLATE-*

	;Prints letter by letter to make RPG style text
	mov dh, 7d
	mov dl, 8d
	mov bh, 02h
	lea bx, lose1
	push bx
	call printLetter
	mov dh, 15d
	mov dl, 7d
	mov bh, 02h
	lea bx, lose2
	push bx
	call printLetter

	;wait input
	mov ah, 08h
	int 21h

	;*------------------------*
	;*-----FIN PANTALLA 3-----*
	;*------------------------*
    ;Termina
	mov cx, 2500
	call delay
    call END_VIDEO
pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp
ret
loseScreen endp
;...................................
creditfin proc
push bp
mov bp, sp
push ax
push bx
push cx
push dx
push si
push di

call INI_VIDEO

	mov dh, 1d
	mov dl, 57d
	mov bh, 02h
	lea bx, msg
	push bx
	call printText
    ;Pinta el marco
    ;pintar_marco 20d, 299d, 20d, 180d, 10d
	;IMPRIME nombre del equipo
	mov dh, 23d
	mov dl, 106d
	mov bh, 02h
	lea bx, team
	push bx
	call printText
	;-END TEMPLATE-

	;Prints letter by letter to make RPG style text
	mov dh, 7d
	mov dl, 8d
	mov bh, 02h
	lea bx, credit
	push bx
	call printLetter
	
	mov dh, 8d
	mov dl, 7d
	mov bh, 02h
	lea bx, c1
	push bx
	call printLetter
	
	mov dh, 9d
	mov dl, 9d
	mov bh, 02h
	lea bx, c2
	push bx
	call printLetter
	
	mov dh, 10d
	mov dl, 11d
	mov bh, 02h
	lea bx, c3
	push bx
	call printLetter
	
	mov dh, 11d
	mov dl, 13d
	mov bh, 02h
	lea bx, c4
	push bx
	call printLetter

	;wait input
	mov ah, 08h
	int 21h
	
	call delay
    call END_VIDEO
pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp
ret
creditfin endp

;IMPORTS
extrn lectura:proc
extrn rta:proc
extrn atr:proc
extrn printNum:proc
extrn random8:proc
extrn randomOp:proc
extrn generateOp:proc
extrn multNum:proc
extrn limpiaString:proc
extrn play:proc

main proc
    mov ax, @data
	mov ds, ax

    call pantallaCarga
	allAgain:
	call pantalla1
	mov life, 3
	mov jugadas, 0
	push bx
	lea bx, acertijoMsg1
	mov byte ptr[bx + 9], 33h
	pop bx

	cmp al, 1
	je finalProx
	jmp playAgain
	finalProx:
	jmp final

	playAgain:

	call DS_DATOS
	;Genera numeros aleatorios a calcular
	;Falta agregar loop para infinitas operaciones
	;deja el sign en +
	mov sign, 0
	;num1
	mov di, prevRNG
	call random8
	mov prevRNG, di
	mov num1, ax
	;num2
	mov cx, 10
	call delay
	xor cx, cx
	mov di, prevRNG
	call random8
	mov prevRNG, di
	mov num2, ax

	;PRIMER OPERACIÓN
	mov bl, sign
	push bx
	lea bx, num1
	push bx
	lea bx, num2
	push bx
	call generateOp
	mov op, dl
	mov resR, bx
	mov sign, dh

	;Create ASCII from numbers to print
	lea bx, num1A
	push bx
	lea bx, num1
	push bx
	call rta
	lea bx, num2A
	push bx
	lea bx, num2
	push bx
	call rta

	;generar tercer operando
	mov cx, 30
	call delay
	xor cx, cx
	mov di, prevRNG
	call random8
	mov prevRNG, di
	mov num3, ax

	;SEGUNDA OPERACIÓN
	mov bl, sign
	push bx
	lea bx, resR
	push bx
	lea bx, num3
	push bx
	call generateOp
	mov op2, dl
	mov resR, bx
	mov sign, dh
	
	cmp sign, 1
	je pasaje
	jmp finPasaje
	pasaje:
	mov ax, resR
	mov dx, 0ffffh
	mul dx
	xor dx, dx
	mov resR, ax
	finPasaje:
	;Numeros ASCII para la segunda op
	lea bx, num3A
	push bx
	lea bx, num3
	push bx
	call rta

	;Imprime pantalla con la pregunta
	call DS_VIDEO
	call pantalla2
	call DS_DATOS

	;Compara resultados
	;Reg player input to compare with real result
        lea bx, playerRes
        push bx
        call atr

        ;Compare results
        cmp di, resR
        je compSign

    pierde:
		sub life, 1
		;call flashR
		;lose sound
			mov cx, 20000
			mov bx, 80
			call play
		;Se fija si le quedan vidas
		cmp life, 0
		ja pA
		jmp pierdeDefinitivo
		pA:
		jmp playAgain
		pierdeDefinitivo:
        ;LOSE SCREEN
        call loseScreen
        jmp sigueJugando
    compSign:
        mov al, sign
        cmp al, playerSign
        je gana
    posible0:
        cmp resR, 0
        jne pierde
    gana:
		add jugadas, 1
		;rta jugadas
		lea bx, jugadasA
		push bx
		lea bx, jugadas
		push bx
		call rta
		;win sound
			mov cx, 2415
			mov bx, 40
			call play
			mov cx, 1809
			mov bx, 30
			call play
		push bx
		lea bx, acertijoMsg1
		sub byte ptr[bx + 9], 1
		pop bx
		cmp jugadas, 3
		je ganaDefinitivo
		jmp playAgain
		ganaDefinitivo:
		;GANA
        call winScreen 
	sigueJugando:

	jmp allAgain

	final:

	call creditfin
	mov ax, 4C00h
    int 21h

main endp
end main

