%include 'yasmmac.inc'

org 100h

section .text
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
start:
macPutString 'Kajus Kutelis 1 kursas 2 grupe','$'
macNewLine

mov di, [skaitymoFailas]
mov bx, 82h
call getFileName
getFileName:
fileName:
mov dl, [es:bx]
inc bx
cmp dl, ' '
jbe quit
mov skaitymoFailas[di], dl
inc di
jmp fileName
quit:
mov byte skaitymoFailas[di], 0
;open up a file for reading
mov dx, skaitymoFailas
call procFOpenForReading
jc failedToOpen ; print and error if file failed to open
mov dx, buffer
mov cx,50000
call procFRead

macPutString 'Ivesk rasomo failo varda', crlf, '$'
mov al, 254                  ; ilgiausia eilute
mov dx, outPutFile      ;
call procGetStr
macNewLine

mov dx, outPutFile
call procFCreateOrTruncate
jc failedToOpen
mov dx,outPutFile
call procFOpenForWriting
mov [handle], bx


mov dx, buffer
mov di, 0

header:
mov dh,[buffer+di]
mov al,dh
mov bx,[handle]
cmp dh,10
je reset
mov dh,10
mov [buffer+di], dh
inc di
jmp header

reset:
xor ax, ax
xor bx, bx
xor dx, dx

startloop:
mov dl, [buffer+di]
cmp dl, 0
je finish
cmp dl, 10
je eilpabaiga
cmp dl, ';'
jne nekab
inc dh
cmp dh, 05
je suma
nekab:
inc di
inc al
cmp ah, 02
jnl startloop
cmp dl, ' '
je tarpas
cmp dl, ';'
je kabliataskis
jmp startloop

kabliataskis:
inc ah
cmp al, 05
jne kazkas
xor al, al
inc bx
jmp startloop

tarpas:
cmp al, 05
jne kazkas
xor al, al
inc bx
jmp startloop

kazkas:
xor al, al
jmp startloop

eilpabaiga:
inc di
xor ax, ax
xor dx, dx
jmp startloop

suma:
inc di
push ax
push bx
push dx
cmp [buffer+di], byte '-'
jne teigiami
lea dx, [buffer+di]
call procParseInt16
neg ax
mov dl, 0ah
mul dl
mul dl
mov cx, ax
add di, 03
lea dx, [buffer+di]
call procParseInt16
add cx, ax
neg cx
jmp praleist

teigiami:
lea dx, [buffer+di]
call procParseInt16
mov dl, 0ah
mul dl
mul dl
mov cx, ax
add di, 02
lea dx, [buffer+di]
call procParseInt16
add cx, ax

praleist:
add [sudetis], cx
int 3

pop dx
pop bx
pop ax
jmp startloop

finish:
xor si, si
mov ax, bx
mov dx, atsakymas
call procInt16ToStr
mov bx, [handle]

spausdintiRezultata:
mov al, [atsakymas + si]
cmp al, 00
je spausum
call procFPutChar
inc si
jmp spausdintiRezultata

spausum:
mov al, 0Ah
call procFPutChar
mov al, 0Dh
call procFPutChar
mov ax, [sudetis]
mov dx, naujasuma
call procInt16ToStr
xor di, di

spausdintsuma:
mov al, [naujasuma+di]
cmp al, 00
je pabaiga
cmp [naujasuma+di+1], byte 00
je nerakablelio
cmp [naujasuma+di+2], byte 00
jne nerakablelio
cmp di, 00
jne nenulis
mov al, '0'
call procFPutChar
nenulis:
mov al, ','
call procFPutChar
mov al, [naujasuma+di]
nerakablelio:
call procFPutChar
inc di
jmp spausdintsuma

pabaiga:
call procFClose
exit

failedToOpen:
macPutString 'Klaida atidarant arba kuriant faila', crlf, '$'
exit

%include 'yasmlib.asm'

 section .DATA
sudetis:
times 8 db 00
naujasuma:
times 8 db 00
atsakymas:
db 00, 00, 00, 00, 00
skaitymoFailas:
times 254 dw 00
buffer:
times 10000 dw 0
bufferDupe:
times 10000 dw 100
bufferDigits:
times 100 dw 0
outPutFile:
times 254 dw 00
handle:
times 100 db 00

section .bss
