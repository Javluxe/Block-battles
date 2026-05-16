
winnerTitle db '        Y O U   W I N !        $'
loserTitle  db '       G A M E   O V E R       $'
winnerBox1  db ' ======================================= $'
winnerBox2  db '   All enemy blocks destroyed!          $'
winnerBox3  db '   Returning to main menu...            $'

showWinnerScreen PROC
    push ax
    push dx

    CLEAR_SCREEN
    HIDE_CURSOR

    mov ah, 06h
    mov al, 0
    mov bh, 2Eh
    mov ch, 6
    mov cl, 15
    mov dh, 6
    mov dl, 55
    int 10h

    SET_CURSOR 6, 15
    mov ah, 09h
    lea dx, winnerTitle
    int 21h

    SET_CURSOR 8, 15
    mov ah, 09h
    lea dx, winnerBox1
    int 21h

    SET_CURSOR 10, 15
    mov ah, 09h
    lea dx, winnerBox2
    int 21h

    SET_CURSOR 12, 15
    mov ah, 09h
    lea dx, winnerBox1
    int 21h

    SET_CURSOR 14, 15
    mov ah, 09h
    lea dx, winnerBox3
    int 21h

    mov ah, 00h
    int 16h

    pop dx
    pop ax
    ret
showWinnerScreen ENDP

cmp playerHits, 3
je  playerWon

CLEAR_SCREEN
SET_CURSOR 20, 0
mov ah, 09h
lea dx, msgLose
int 21h
SET_CURSOR 21, 0
mov ah, 09h
lea dx, msgReplay
int 21h
mov ah, 00h
int 16h
jmp mainLoop

playerWon:
call showWinnerScreen
jmp mainLoop
