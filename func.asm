.8086
.model small
.stack 100h
.data

.code
public lectura
public atr
public rta
public len
public buscar
public isLet
public isnum
public printNum
public random8
public random16
public randomOp
public generateOp
public multNum
public limpiaString
public play

;IMPORT
extrn delay:proc

;CAJA DE LECTURA DE NUMEROS!!!
;Variable por stack y se devuelve en la variable el input
;Devuelve por ch el signo ingresado (0=+//1=-)
	lectura proc
		push bp
		mov bp, sp
		mov si, ss:[bp + 4]
		push bx
		push ax
		;limpio string
		push si
		call limpiaString
		;el si lo popea la funcion
		xor cx, cx
		xor bx, bx
		lect:
			;lectura sin eco
			mov ah, 08h
			int 21h
			;compara "-"
			cmp al, 2Dh
			je sign
			;compara enter
			cmp al, 0dh
			je endlect
			cmp al, 08h
			je rest
			cmp bx, 5
			je lect
			call isNum
			cmp dl, 0
			je lect
			eco:
			mov ah, 02h
			mov dl, al
			int 21h
			mov [si + bx], al
			inc bx
			jmp lect
		sign:
			cmp bx, 0
			jne lect
			cmp cl, 1
			je lect
			mov ah, 02h
			mov dl, 2Dh
			int 21h
			mov ch, 1
			mov cl, 1
			jmp lect

		rest:
			cmp bx, 0
			je limpiaSign
			mov byte ptr [si + bx], 24h
			mov ah, 02h
			mov dl, al
			int 21h
			mov dl, 20h
			int 21h
			mov dl, 08h
			int 21h
			dec bx
			jmp lect
		limpiaSign:
			cmp cl, 0
			je lect
			mov ah, 02h
			mov dl, 08h
			int 21h
			mov dl, 20h
			int 21h
			mov dl, 08h
			int 21h
			mov cl, 0
			mov ch, 0
			jmp lect
		endlect:
			cmp bx, 0
			je lect

		lea bx, [si]
		push bx
		call len

		cmp dl, 0
		jne isN0
		jmp is0
		isN0:
		cmp dl, 1
		je is1
		cmp dl, 2
		je is2
		cmp dl, 3
		je is3
		cmp dl, 4
		je is4
		;is5
		jmp fin

		is4:
		mov al, [si + 3]
		mov [si + 4], al
		mov al, [si + 2]
		mov [si + 3], al
		mov al, [si + 1]
		mov [si + 2], al
		mov al, [si]
		mov [si + 1], al
		mov byte ptr [si], 30h
		jmp fin

		is3:
		;Save number
		mov al, [si + 2]
		mov [si + 4], al
		mov al, [si + 1]
		mov [si + 3], al
		mov al, [si]
		mov [si + 2], al
		mov byte ptr [si + 1], 30h
		mov byte ptr [si], 30h
		jmp fin

		is2:
		mov al, [si + 1]
		mov [si + 4], al
		mov al, [si]
		mov [si + 3], al
		mov byte ptr [si + 2], 30h
		mov byte ptr [si + 1], 30h
		mov byte ptr [si], 30h
		jmp fin

		is1:
		mov al, [si]
		mov [si + 4], al
		mov byte ptr [si + 3], 30h
		mov byte ptr [si + 2], 30h
		mov byte ptr [si + 1], 30h
		mov byte ptr [si], 30h
		jmp fin

		is0:
		mov byte ptr [si], 30h
		mov byte ptr [si + 1], 30h
		mov byte ptr [si + 2], 30h
		mov byte ptr [si + 3], 30h
		mov byte ptr [si + 4], 30h

		jmp fin

		fin:

		pop ax
		pop bx
		pop bp
		ret 2
	lectura endp

;ASCII TO REG
;Devuelve el REG por DI
atr proc
		push bp
		mov bp, sp
		push si
		push ax
		push cx

		mov si, ss:[bp + 4]

		;UNIDAD
		xor ax, ax
		mov al, [si + 4]
		sub ax, 30h
		mov di, ax
		
		;DECENA
		xor ah, ah
		mov al, [si + 3]
		sub ax, 30h
		mov cx, 10
		mul cx
		add di, ax

		;CENTENA
		xor ah, ah
		mov al, [si + 2]
		sub ax, 30h
		mov cx, 100
		mul cx
		add di, ax

		;MILENIO
		xor ah, ah
		mov al, [si + 1]
		sub ax, 30h
		mov cx, 1000
		mul cx
		add di, ax

		;MIL MILENIO
		xor ah, ah
		mov al, [si]
		sub ax, 30h
		mov cx, 10000
		mul cx
		add di, ax

		pop cx
		pop ax
		pop si
		pop bp
		ret 2
	atr endp

;REG TO ASCII
;Se ingresa primero el ASCII y luego el REG por STACK
	rta proc
		push bp
		mov bp, sp
		push ax
		push cx
		push si
		push di
		push dx

		xor si, si
		xor di, di

		mov si, ss:[bp + 4]		;REG
		mov di, ss:[bp + 6] 	;ASCII

		mov ax, [si]
		add di, 4
		mov cx, 5
		mov bx, 10
		divide:
		 xor dx, dx
		 div bx
		 add dl, 30h
		 mov [di], dl
		 dec di
		loop divide

		pop dx
		pop di
		pop si
		pop cx
		pop ax
		pop bp
		ret 4
	rta endp

;.LENGHT
;Parametro por stack devuelve el counter por DL en REG
    len proc
        push bp
        mov bp, sp
        push si
        push bx

        mov si, ss:[bp + 4]

        xor dl, dl
        xor bx, bx
        scan:
            cmp byte ptr [si + bx], 24h
            je endScan
            add dl, 1
            inc bx
            jmp scan
        endScan:

        pop bx
        pop si
        pop bp
        ret 2
    len endp

;CONTAR UN CARACTER EN UN STRING
;TEXTO POR STACK
;CARACTER A BUSCAR POR DL
;POR CL DEVUELVE LA CANTIDAD
    buscar proc
		push bp
		mov bp, sp

		mov si, ss:[bp + 4]

		xor bx, bx
		busca:
			cmp byte ptr [si + bx], 24h
			je endBusca
			cmp [si + bx], dl	;Se manda el caracter a comparar por dl
			je add1
		incbx:
			inc bx
			jmp busca

		add1:
			add cl, 1
			jmp incbx
		endBusca:

		pop bp
		ret 2
	buscar endp

;MAYUS MINUS
;se pasa por AL el caracter a buscar
;DL se devuelve 0 para noLetra, 1 para mayus y 2 para minus
    isLet proc
		push bp
		mov bp, sp
		push ax

		cmp al, 7Ah
		ja noLet
		cmp al, 41h
		jb noLet
		cmp al, 41h
		jae casiMayus

		noLet:
			mov dl, 0
			jmp endIsLet

		casiMayus:
			cmp al, 5Ah
			jbe mayus
			cmp al, 61h
			jae minus
			jmp noLet
		mayus:
			mov dl, 1
			jmp endIsLet
		minus:
			mov dl, 2
		endIsLet:
		
		pop ax
		pop bp
		ret
	isLet endp

;CHECK IF NUMBER
    isNum proc
		push bp
		mov bp, sp
		;RECIVE DATO POR AL
		;DEVUELVE en DL 1 si es numero 0 si no

		cmp al, 30h
		jb notNum
		cmp al, 39h
		ja notNum
		
		mov dl, 1
		jmp finNum

		notNum:
			mov dl, 0
		finNum:

		pop bp
		ret
	isNum endp

;escribe un string de numeros ignorando los ceros a la izquierda
;recibe por stack el offset del string
	printNum proc
		push bp
		mov bp, sp
		push ax
		push si
		push dx

		mov si, ss:[bp + 4]
		mov al, 0

	escritura:
		mov dl, [si]
		cmp dl, 30h
		ja primerNum
		sigue1:
		cmp dl, 30h
		je esCero
		sigue2:
		mov ah, 02h
		int 21h
		ceroIzq:
		inc si
		cmp byte ptr [si], 24h
		je fuera
		jmp escritura

	primerNum:
		mov al, 1
		jmp sigue1

	esCero:
		cmp al, 0
		je ceroIzq
		jmp sigue2

	fuera:
		cmp al, 0
		je todo0
		jmp termina

	todo0:
		mov dl, 30h
		mov ah, 02h
		int 21h

	termina:

		pop dx
		pop si
		pop ax
		pop bp
		ret 2
	printNum endp


;Devuelve random num por AX de 8 bits
random8 proc
	push bp
	mov bp, sp

		mov ah, 00h
        int 1Ah
        mov ax, dx
        mov si, 15
        int 81h
        mov al, ah
        xor ah, ah
		mov di, ax

	pop bp
	ret
random8 endp

random16 proc
	push bp
	mov bp, sp

		mov ah, 00h
        int 1Ah
        mov ax, dx
        mov si, 3
        int 81h
        mov al, ah
        xor ah, ah
		mov di, ax

	pop bp
	ret
random16 endp


randomOp proc
	push ax
	push di
	push si

	call random8
	cmp ax, 3Fh
	jbe suma
	cmp ax, 7Fh
	jbe resta
	cmp ax, 0CFh
	jbe multi
	
	;cmp ax, FF		Siempre
	;mov cl, "/"
	;jmp finRandomOp

	suma:
	mov cl, "+"
	jmp finRandomOp

	resta:
	mov cl, "-"
	jmp finRandomOp

	multi:
	mov cl, "*"
	jmp finRandomOp

	finRandomOp:
	pop si
	pop di
	pop ax

	ret
randomOp endp

;Se ingresan 2 variables y el signo de la primera por stack, hace una operación aleatoria entre ellas
;Devuelve resultado por BX
;Devuelve operación por DL
;Devuelve signo del resultado por DH  (1=-//0=+)
generateOp proc
	push bp
	mov bp, sp
	push cx
	push ax
	push si
	push di

	mov bx, ss:[bp + 8]		;signo del primer numero
	mov si, ss:[bp + 6]		;primer numero
	mov di, ss:[bp + 4]		;segundo numero

	 	;Genera operacion aleatoria
        ;AGREGAR DIVISIÓN
        call randomOp
		mov dl, cl
		xor dh, dh
		push dx		;mando operación a stack
        cmp cl, "+"
        je sumaGeneratedOp
        cmp cl, "-"
        je restaGeneratedOp
        cmp cl, "*"
        je multGeneratedOp

        sumaGeneratedOp:
        mov ax, word ptr[si]
        add ax, word ptr[di]
        js esNeg
       	pop dx
        jmp endOp

        restaGeneratedOp:
        mov ax, word ptr[si]
        sub ax, word ptr[di]
        js esNeg
        pop dx
        jmp endOp

        ;Multiplica numeros de 3 digitos
        multGeneratedOp:
        mov ax, [di]
        call multNum
        mov [di], ax
        mov cx, [si]
        mul cx
        cmp bx, 1
        je esNeg
        pop dx
		jmp endOp

		esNeg:
		pop dx
		mov dh, 1

        endOp:
        mov bx, ax

    pop di
    pop si
	pop ax
	pop cx
	pop bp
	ret 6
generateOp endp

multNum proc
	push bp
	mov bp, sp

	cmp ax, 35d
	jbe cero
	cmp ax, 90d
	jbe uno
	cmp ax, 145d
	jbe dos
	cmp ax, 200d
	jbe cinco
	cmp ax, 255d
	jbe diez

	cero:
	mov ax, 0
	jmp endNum
	uno:
	mov ax, 1
	jmp endNum
	dos:
	mov ax, 2
	jmp endNum
	cinco:
	mov ax, 5
	diez:
	mov ax, 10
	jmp endNum

	endNum:
	pop bp
	ret
multNum endp

limpiaString proc
	push bp
	mov bp, sp
	push bx

	mov bx, ss:[bp + 4]

	limpia:
	cmp byte ptr [bx], 24h
	je finLimpia
	mov byte ptr [bx], 24h
	inc bx
	jmp limpia
	finLimpia:

	pop bx
	pop bp
	ret 2
limpiaString endp

play proc

play:
    push ax
    push cx
    push bx
    mov     ax, cx

    out     42h, al
    mov     al, ah
    out     42h, al
    in      al, 61h

    or      al, 00000011b
    out     61h, al

    pause1:
        mov cx, 65535

    pause2:
        dec cx
        jne pause2
        dec bx
        jne pause1

        in  al, 61h
        and al, 11111100b
        out 61h, al
        
    pop bx
    pop cx
    pop ax

    ret
play endp

winSound proc
winSound endp

;END PROGRAMA
end