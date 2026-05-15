.model small
.stack 100h

.data
    
    playerGrid  db 25 dup(0)
    enemyGrid   db 25 dup(0)

   
    curRow      db 0        
    curCol      db 0        
    cellVal     db 0        
    gridType    db 0        
    screenRow   db 0        
    screenCol   db 0        

    PGRID_ROW   equ 6       
    PGRID_COL   equ 4       
    EGRID_ROW   equ 6       
    EGRID_COL   equ 44      

    
    ; blue background = 10h
    COL_WATER   equ 1Bh      
    COL_BLOCK   equ 1Eh     
    COL_HIT     equ 1Ch     
    COL_MISS    equ 1Fh     
    COL_LABEL   equ 1Eh     


    yourLabel   db '  YOUR GRID  $'
    enemyLabel  db '  ENEMY GRID $'
    colNumbers  db ' 1 2 3 4 5   $'
    statusLine  db ' =========================================$'
    turnMsg     db ' YOUR TURN - Enter row then col (1 to 5)  $'
    newline     db 13, 10, '$'

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


PRINT_COLORED_REGION MACRO r1, c1, r2, c2, color
    mov ah, 06h
    mov al, 0
    mov bh, color
    mov ch, r1
    mov cl, c1
    mov dh, r2
    mov dl, c2
    int 10h
ENDM

drawCell PROC
    push ax
    push bx
    push cx

    mov al, cellVal     ; get cell value

    ; if enemy grid and cell=block, show water (hide block)
    cmp gridType, 1
    jne notEnemyCell
    cmp al, 1
    jne notEnemyCell
    mov al, 0           ; show as water
    notEnemyCell:

    ; draw based on value
    cmp al, 0
    je  drawWater
    cmp al, 1
    je  drawBlock
    cmp al, 2
    je  drawHit
    ; else miss
    drawMiss:
        mov ah, 09h
        mov al, 'O'
        mov bh, 0
        mov bl, COL_MISS
        mov cx, 1
        int 10h
        jmp cellDone
    drawWater:
        mov ah, 09h
        mov al, '~'
        mov bh, 0
        mov bl, COL_WATER
        mov cx, 1
        int 10h
        jmp cellDone
    drawBlock:
        mov ah, 09h
        mov al, 'B'
        mov bh, 0
        mov bl, COL_BLOCK
        mov cx, 1
        int 10h
        jmp cellDone
    drawHit:
        mov ah, 09h
        mov al, 'X'
        mov bh, 0
        mov bl, COL_HIT
        mov cx, 1
        int 10h

    cellDone:
    pop cx
    pop bx
    pop ax
    ret
drawCell ENDP


drawLabels PROC
    push ax
    push bx
    push dx

    ; YOUR GRID label in yellow
    PRINT_COLORED_REGION 3, PGRID_COL, 3, PGRID_COL+13, COL_LABEL
    SET_CURSOR 3, PGRID_COL
    mov ah, 09h
    lea dx, yourLabel
    int 21h

    ; ENEMY GRID label in yellow
    PRINT_COLORED_REGION 3, EGRID_COL, 3, EGRID_COL+13, COL_LABEL
    SET_CURSOR 3, EGRID_COL
    mov ah, 09h
    lea dx, enemyLabel
    int 21h

    ; Column numbers under player grid
    PRINT_COLORED_REGION 4, PGRID_COL, 4, PGRID_COL+13, COL_HEADER
    SET_CURSOR 4, PGRID_COL
    mov ah, 09h
    lea dx, colNumbers
    int 21h

    ; Column numbers under enemy grid
    PRINT_COLORED_REGION 4, EGRID_COL, 4, EGRID_COL+13, COL_HEADER
    SET_CURSOR 4, EGRID_COL
    mov ah, 09h
    lea dx, colNumbers
    int 21h

    ; Status bar at bottom
    SET_CURSOR 20, 0
    mov ah, 09h
    lea dx, statusLine
    int 21h

    SET_CURSOR 21, 0
    mov ah, 09h
    lea dx, turnMsg
    int 21h

    pop dx
    pop bx
    pop ax
    ret
drawLabels ENDP


drawGrid PROC
    push ax
    push bx
    push cx
    push dx
    push si

    mov curRow, 0           ; start at row 0

   
    rowLoop:
        cmp curRow, 5
        je  gridDone        ; all 5 rows drawn, exit

        ; Print row number label on left
        ; screen row = base + curRow
        mov al, curRow
        cmp gridType, 0
        jne enemyRowLabel
        add al, PGRID_ROW   ; player grid screen row
        jmp setRowLabel
        enemyRowLabel:
        add al, EGRID_ROW   ; enemy grid screen row
        setRowLabel:
        mov screenRow, al

        ; Set cursor for row label
        mov dh, screenRow
        cmp gridType, 0
        jne enemyLabelCol
        mov dl, PGRID_COL - 2   ; 2 cols left of grid
        jmp printRowNum
        enemyLabelCol:
        mov dl, EGRID_COL - 2
        printRowNum:
        mov ah, 02h
        mov bh, 0
        int 10h

       
        mov ah, 09h
        mov al, curRow
        add al, '1'         ; convert 0..4 to '1'..'5'
        mov bh, 0
        mov bl, COL_HEADER
        mov cx, 1
        int 10h

        mov curCol, 0       ; reset col for each row

        
        colLoop:
            cmp curCol, 5
            je  nextRow     ; all 5 cols drawn, next row

            ; index = curRow * 5 + curCol
            mov al, curRow
            mov ah, 0
            mov bl, 5
            mul bl          ; ax = curRow * 5  (Lab 3 MUL)
            mov bl, 0
            mov bl, curCol
            add ax, bx      ; ax = curRow*5 + curCol

           
            mov bx, ax
            mov al, [si+bx] ; al = grid[index]
            mov cellVal, al ; save for drawCell

            
            ; screenRow = baseRow + curRow
            mov al, curRow
            cmp gridType, 0
            jne enemyScreenRow
            add al, PGRID_ROW
            jmp setScreenRow
            enemyScreenRow:
            add al, EGRID_ROW
            setScreenRow:
            mov screenRow, al

            ; screenCol = baseCol + curCol * 2
            mov al, curCol
            shl al, 1           ; col * 2 (spacing)
            cmp gridType, 0
            jne enemyScreenCol
            add al, PGRID_COL
            jmp setScreenCol
            enemyScreenCol:
            add al, EGRID_COL
            setScreenCol:
            mov screenCol, al

            ; Set cursor to cell position
            mov ah, 02h
            mov bh, 0
            mov dh, screenRow
            mov dl, screenCol
            int 10h

            ; Draw the cell
            call drawCell

            inc curCol
            jmp colLoop     ; next column

        nextRow:
        inc curRow
        jmp rowLoop         ; next row

    gridDone:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
drawGrid ENDP

drawBothGrids PROC
    push ax
    push bx
    push si

    CLEAR_SCREEN
    HIDE_CURSOR

    ; Draw labels and headers
    call drawLabels

    ; Draw player grid
    lea si, playerGrid
    mov gridType, 0
    call drawGrid

    ; Draw enemy grid
    lea si, enemyGrid
    mov gridType, 1
    call drawGrid

    pop si
    pop bx
    pop ax
    ret
drawBothGrids ENDP

main PROC
    mov ax, @data
    mov ds, ax

    ; Player grid test values
    mov playerGrid[0],  1   ; (0,0) = Block
    mov playerGrid[13], 1   ; (2,3) = Block
    mov playerGrid[24], 1   ; (4,4) = Block
    mov playerGrid[6],  2   ; (1,1) = Hit
    mov playerGrid[11], 3   ; (2,1) = Miss

    ; Enemy grid test values (blocks hidden)
    mov enemyGrid[2],   1   ; hidden block
    mov enemyGrid[10],  2   ; Hit shown
    mov enemyGrid[17],  3   ; Miss shown

    ; Draw both grids
    call drawBothGrids

    ; Wait for key then exit
    mov ah, 00h
    int 16h

    mov ah, 4Ch
    mov al, 0
    int 21h

main ENDP
END main