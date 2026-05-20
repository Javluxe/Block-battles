.model small
.stack 100h

.data
    playerGrid  db 25 dup(0)

    pRow        db 0
    pCol        db 0
    pIdx        db 0

    dRow        db 0
    dCol        db 0
    dIdx        db 0
    dCell       db 0
    dSRow       db 0
    dSCol       db 0

    bCount      db 1

    PGRID_ROW   equ 5
    PGRID_COL   equ 4

    yourLabel   db '    YOUR GRID  $'
    colNumbers  db '  1 2 3 4 5   $'
    placeTitle  db '   PLACE YOUR BLOCKS ON THE GRID   $'
    askRow      db ' Enter row (1-5): $'
    askCol      db ' Enter col (1-5): $'
    msgBlock    db ' Placing block $'
    msgOf3      db ' of 3          $'
    msgBad      db ' Invalid! Use 1-5.                 $'
    msgDupe     db ' Already used! Pick another.       $'
    msgOK       db ' Block placed!                     $'
    msgDone     db ' All 3 placed! Press any key...    $'
    blank       db '                                   $'
    statLine    db ' =========================================$'

.code

SET_CURSOR MACRO r, c
    mov ah, 02h
    mov bh, 0
    mov dh, r
    mov dl, c
    int 10h
ENDM

CLEAR_SCREEN MACRO
    mov ah, 06h
    mov al, 0
    mov bh, 17h
    mov ch, 0
    mov cl, 0
    mov dh, 24
    mov dl, 79
    int 10h
    SET_CURSOR 0,0
ENDM

HIDE_CURSOR MACRO
    mov ah, 01h
    mov ch, 20h
    int 10h
ENDM

SHOW_CURSOR MACRO
    mov ah, 01h
    mov ch, 06h
    mov cl, 07h
    int 10h
ENDM

drawPlayerGrid PROC
    push ax
    push bx
    push cx
    push dx
    push si
    
    mov ah,06h
    mov al,0
    mov bh,1Eh
    mov ch,3
    mov cl,PGRID_COL
    mov dh,3
    mov dl,PGRID_COL+13
    int 10h

    SET_CURSOR 3,PGRID_COL
    mov ah,09h
    lea dx,yourLabel
    int 21h

    mov ah,06h
    mov al,0
    mov bh,1Bh
    mov ch,4
    mov cl,PGRID_COL
    mov dh,4
    mov dl,PGRID_COL+13
    int 10h

    SET_CURSOR 4,PGRID_COL
    mov ah,09h
    lea dx,colNumbers
    int 21h

    lea si,playerGrid
    mov dRow,0

rowLoop:
    cmp dRow,5
    je gridDone

    mov al,dRow
    add al,PGRID_ROW
    mov dSRow,al

    mov ah,02h
    mov bh,0
    mov dh,dSRow
    mov dl,PGRID_COL-2
    int 10h

    mov ah,09h
    mov al,dRow
    add al,'1'
    mov bh,0
    mov bl,1Bh
    mov cx,1
    int 10h

    mov dCol,0

colLoop:
    cmp dCol,5
    je nextRow

    mov al,dRow
    mov bl,5
    mul bl
    add al,dCol
    mov dIdx,al

    xor bx,bx
    mov bl,dIdx
    mov al,[si+bx]
    mov dCell,al

    ; Screen row
    mov al,dRow
    add al,PGRID_ROW
    mov dSRow,al

    mov al,dCol
    shl al,1
    add al,PGRID_COL
    mov dSCol,al

    
    mov ah,02h
    mov bh,0
    mov dh,dSRow
    mov dl,dSCol
    int 10h

    mov al,dCell
    cmp al,0
    je drawWater
    cmp al,1
    je drawBlock
    cmp al,2
    je drawHit

drawMiss:
    mov ah,09h
    mov al,'O'
    mov bh,0
    mov bl,1Fh
    mov cx,1
    int 10h
    jmp nextCol

drawWater:
    mov ah,09h
    mov al,'~'
    mov bh,0
    mov bl,1Bh
    mov cx,1
    int 10h
    jmp nextCol

drawBlock:
    mov ah,09h
    mov al,'B'
    mov bh,0
    mov bl,1Ch
    mov cx,1
    int 10h
    jmp nextCol

drawHit:
    mov ah,09h
    mov al,'X'
    mov bh,0
    mov bl,1Ch
    mov cx,1
    int 10h

nextCol:
    inc dCol
    jmp colLoop

nextRow:
    inc dRow
    jmp rowLoop

gridDone:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
drawPlayerGrid ENDP

getKey PROC
inputLoop:
    mov ah,01h
    int 21h

    cmp al,13
    je inputLoop

    cmp al,'1'
    jl badInput
    cmp al,'5'
    jg badInput

    sub al,'1'
    ret

badInput:
    SET_CURSOR 17,2
    mov ah,09h
    lea dx,msgBad
    int 21h
    jmp inputLoop
getKey ENDP

placeBlocks PROC
    push ax
    push bx
    push cx
    push dx
    push si

    mov bCount,1

nextBlock:
    cmp bCount,4
    je doneBlocks

retryPlacement:
    
    SET_CURSOR 17,2
    mov ah,09h
    lea dx,blank
    int 21h

    SET_CURSOR 13,2
    mov ah,09h
    lea dx,msgBlock
    int 21h

    mov ah,09h
    mov al,bCount
    add al,'0'
    mov bh,0
    mov bl,1Eh
    mov cx,1
    int 10h

    SET_CURSOR 13,18
    mov ah,09h
    lea dx,msgOf3
    int 21h

    SET_CURSOR 15,2
    mov ah,09h
    lea dx,askRow
    int 21h
    SHOW_CURSOR
    call getKey
    mov pRow,al

    SET_CURSOR 16,2
    mov ah,09h
    lea dx,askCol
    int 21h
    SHOW_CURSOR
    call getKey
    mov pCol,al

    mov al,pRow
    mov bl,5
    mul bl
    add al,pCol
    mov pIdx,al

    lea si,playerGrid
    xor bx,bx
    mov bl,pIdx
    mov al,[si+bx]

    cmp al,0
    jne duplicateBlock

    mov byte ptr [si+bx],1

    mov al,pRow
    add al,PGRID_ROW
    mov dSRow,al

    mov al,pCol
    shl al,1
    add al,PGRID_COL
    mov dSCol,al

    mov ah,02h
    mov bh,0
    mov dh,dSRow
    mov dl,dSCol
    int 10h

    mov ah,09h
    mov al,'B'
    mov bh,0
    mov bl,1Ch
    mov cx,1
    int 10h

    SET_CURSOR 17,2
    mov ah,09h
    lea dx,msgOK
    int 21h

    HIDE_CURSOR
    call drawPlayerGrid

    SET_CURSOR 15,2
    mov ah,09h
    lea dx,blank
    int 21h

    SET_CURSOR 16,2
    mov ah,09h
    lea dx,blank
    int 21h

    inc bCount
    jmp nextBlock

duplicateBlock:
    SET_CURSOR 17,2
    mov ah,09h
    lea dx,msgDupe
    int 21h
    jmp retryPlacement

doneBlocks:
    HIDE_CURSOR
    SET_CURSOR 19,2
    mov ah,09h
    lea dx,msgDone
    int 21h

    mov ah,00h
    int 16h

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
placeBlocks ENDP

main PROC
    mov ax,@data
    mov ds,ax

    CLEAR_SCREEN
    HIDE_CURSOR

    mov ah,06h
    mov al,0
    mov bh,1Eh
    mov ch,1
    mov cl,10
    mov dh,1
    mov dl,55
    int 10h

    SET_CURSOR 1,10
    mov ah,09h
    lea dx,placeTitle
    int 21h

    SET_CURSOR 20,0
    mov ah,09h
    lea dx,statLine
    int 21h

    call drawPlayerGrid
    call placeBlocks

    mov ah,4Ch
    mov al,0
    int 21h
main ENDP

END main