.model small
.stack 100h

.data

    
    playerGrid  db 25 dup(0)    

    
    blocksLeft  db 3            
    inputRow    db 0            
    inputCol    db 0          
    gridIndex   db 0            

   
    COL_WATER   equ 1Bh
    COL_BLOCK   equ 1Eh
    COL_HIT     equ 1Ch
    COL_MISS    equ 1Fh
    COL_LABEL   equ 1Eh
    COL_HEADER  equ 1Bh
    COL_MSG     equ 1Ah         

  
    PGRID_ROW   equ 5
    PGRID_COL   equ 4

   
    placeTitle  db '   PLACE YOUR BLOCKS ON THE GRID   $'
    placeInstr  db ' Enter row (1-5): $'
    placeInstr2 db ' Enter col (1-5): $'
    block1msg   db ' Placing block 1 of 3$'
    block2msg   db ' Placing block 2 of 3$'
    block3msg   db ' Placing block 3 of 3$'
    errorRange  db ' Invalid! Enter a number 1-5. Try again.$'
    errorDupe   db ' Already placed there! Try again.$'
    successMsg  db ' Block placed! $'
    doneMsg     db ' All blocks placed! Press any key...$'
    yourLabel   db '    YOUR GRID  $'
    colNumbers  db '  1 2 3 4 5   $'
    newline     db 13, 10, '$'
    statusLine  db ' =========================================$'

    curRow      db 0
    curCol      db 0
    cellVal     db 0
    gridType    db 0
    screenRow   db 0
    screenCol   db 0

.code

SET_CURSOR MACRO row, col
    mov ah, 02h
    mov bh, 0
    mov dh, row
    mov dl, col
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
    SET_CURSOR 0, 0
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

drawCell PROC
    push ax
    push bx
    push cx

    mov al, cellVal

    cmp gridType, 1
    jne skipHide
    cmp al, 1
    jne skipHide
    mov al, 0
    skipHide:

    cmp al, 0
    je  dWater
    cmp al, 1
    je  dBlock
    cmp al, 2
    je  dHit
    ; miss
    mov ah, 09h
    mov al, 'O'
    mov bh, 0
    mov bl, COL_MISS
    mov cx, 1
    int 10h
    jmp dCellDone
    dWater:
        mov ah, 09h
        mov al, '~'
        mov bh, 0
        mov bl, COL_WATER
        mov cx, 1
        int 10h
        jmp dCellDone
    dBlock:
        mov ah, 09h
        mov al, 'B'
        mov bh, 0
        mov bl, COL_BLOCK
        mov cx, 1
        int 10h
        jmp dCellDone
    dHit:
        mov ah, 09h
        mov al, 'X'
        mov bh, 0
        mov bl, COL_HIT
        mov cx, 1
        int 10h
    dCellDone:
    pop cx
    pop bx
    pop ax
    ret
drawCell ENDP

drawPlayerGrid PROC
    push ax
    push bx
    push cx
    push dx
    push si

    mov ah, 06h
    mov al, 0
    mov bh, COL_LABEL
    mov ch, 3
    mov cl, PGRID_COL
    mov dh, 3
    mov dl, PGRID_COL + 13
    int 10h

    SET_CURSOR 3, PGRID_COL
    mov ah, 09h
    lea dx, yourLabel
    int 21h

    mov ah, 06h
    mov al, 0
    mov bh, COL_HEADER
    mov ch, 4
    mov cl, PGRID_COL
    mov dh, 4
    mov dl, PGRID_COL + 13
    int 10h

    SET_CURSOR 4, PGRID_COL
    mov ah, 09h
    lea dx, colNumbers
    int 21h
    
    lea si, playerGrid
    mov gridType, 0
    mov curRow, 0

    pRowLoop:
        cmp curRow, 5
        je  pGridDone

        mov al, curRow
        add al, PGRID_ROW
        mov screenRow, al
        mov dh, screenRow
        mov dl, PGRID_COL - 2
        mov ah, 02h
        mov bh, 0
        int 10h

        mov ah, 09h
        mov al, curRow
        add al, '1'
        mov bh, 0
        mov bl, COL_HEADER
        mov cx, 1
        int 10h

        mov curCol, 0

        pColLoop:
            cmp curCol, 5
            je  pNextRow

            mov al, curRow
            mov ah, 0
            mov bl, 5
            mul bl
            mov bl, 0
            mov bl, curCol
            add ax, bx

            mov bx, ax
            mov al, [si+bx]
            mov cellVal, al

            mov al, curRow
            add al, PGRID_ROW
            mov screenRow, al

            mov al, curCol
            shl al, 1
            add al, PGRID_COL
            mov screenCol, al

            mov ah, 02h
            mov bh, 0
            mov dh, screenRow
            mov dl, screenCol
            int 10h

            call drawCell

            inc curCol
            jmp pColLoop

        pNextRow:
        inc curRow
        jmp pRowLoop

    pGridDone:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
drawPlayerGrid ENDP

getValidInput PROC
    push bx
    push dx

    getAgain:
        SHOW_CURSOR
        mov ah, 01h        
        int 21h

        mov ah, 09h
        lea dx, newline
        int 21h

        cmp al, '1'
        jl  badInput        
        cmp al, '5'
        jg  badInput       
        jmp goodInput

        badInput:
           
            mov ah, 09h
            lea dx, errorRange
            int 21h
            mov ah, 09h
            lea dx, newline
            int 21h
            jmp getAgain

    goodInput:
        sub al, '1'        

    pop dx
    pop bx
    ret
getValidInput ENDP

placeBlocks PROC
    push ax
    push bx
    push cx
    push dx

    mov cx, 3               

    placeLoop:
       
        SET_CURSOR 14, 2
        mov ah, 09h

        cmp cx, 3
        je  showMsg1
        cmp cx, 2
        je  showMsg2
        
        lea dx, block3msg
        jmp printBlockMsg
        showMsg1:
            lea dx, block1msg
            jmp printBlockMsg
        showMsg2:
            lea dx, block2msg
        printBlockMsg:
        int 21h

        SET_CURSOR 15, 2
        mov ah, 09h
        lea dx, placeInstr
        int 21h

        call getValidInput
        mov inputRow, al    

        SET_CURSOR 16, 2
        mov ah, 09h
        lea dx, placeInstr2
        int 21h

        call getValidInput
        mov inputCol, al    
        mov al, inputRow
        mov ah, 0
        mov bl, 5
        mul bl             
        mov bl, 0
        mov bl, inputCol
        add ax, bx         
        mov gridIndex, al   

        mov bx, 0
        mov bl, gridIndex
        lea si, playerGrid
        mov al, [si+bx]    

        cmp al, 1           
        jne placeIt         

        SET_CURSOR 17, 2
        mov ah, 09h
        lea dx, errorDupe
        int 21h
        jmp placeLoop     

       
        placeIt:
        mov bx, 0
        mov bl, gridIndex
        lea si, playerGrid
        mov byte ptr [si+bx], 1     

        SET_CURSOR 17, 2
        mov ah, 09h
        lea dx, successMsg
        int 21h

        HIDE_CURSOR
        call drawPlayerGrid
        SHOW_CURSOR

        SET_CURSOR 15, 2
        mov ah, 09h
        lea dx, placeInstr
        int 21h

        loop placeLoop     

    SET_CURSOR 18, 2
    mov ah, 09h
    lea dx, doneMsg
    int 21h

    mov ah, 00h
    int 16h

    pop dx
    pop cx
    pop bx
    pop ax
    ret
placeBlocks ENDP


main PROC
    mov ax, @data
    mov ds, ax

    CLEAR_SCREEN
    HIDE_CURSOR

    mov ah, 06h
    mov al, 0
    mov bh, 1Eh
    mov ch, 1
    mov cl, 10
    mov dh, 1
    mov dl, 50
    int 10h

    SET_CURSOR 1, 10
    mov ah, 09h
    lea dx, placeTitle
    int 21h

    SET_CURSOR 20, 0
    mov ah, 09h
    lea dx, statusLine
    int 21h

    call drawPlayerGrid

    call placeBlocks

    ; Exit
    mov ah, 4Ch
    mov al, 0
    int 21h

main ENDP
END main