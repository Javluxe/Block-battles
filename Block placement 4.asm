.model small
.stack 100h

.data

    playerGrid  db 25 dup(0)

   
    inputRow    db 0
    inputCol    db 0
    gridIndex   db 0
    blockCount  db 0        

    
    curRow      db 0
    curCol      db 0
    cellVal     db 0
    screenRow   db 0
    screenCol   db 0

    
    COL_WATER   equ 1Bh
    COL_BLOCK   equ 1Eh
    COL_HIT     equ 1Ch
    COL_MISS    equ 1Fh
    COL_LABEL   equ 1Eh
    COL_HEADER  equ 1Bh

    PGRID_ROW   equ 5
    PGRID_COL   equ 4

    ; strings
    placeTitle  db '   PLACE YOUR BLOCKS ON THE GRID   $'
    placeInstr  db ' Enter row (1-5): $'
    placeInstr2 db ' Enter col (1-5): $'
    blockMsg    db ' Placing block $'
    ofThree     db ' of 3          $'
    errorRange  db ' Invalid! Enter 1-5. Try again.    $'
    errorDupe   db ' Already placed there! Try again.  $'
    successMsg  db ' Block placed!                     $'
    doneMsg     db ' All 3 blocks placed! Press any key...$'
    yourLabel   db '    YOUR GRID  $'
    colNumbers  db '  1 2 3 4 5   $'
    blankLine   db '                                   $'
    statusLine  db ' =========================================$'

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

calcIndex PROC
    push ax
    push bx

    mov al, inputRow    ; al = row (0-4)
    mov bl, al          ; bl = row
    add al, bl          ; al = row*2
    add al, bl          ; al = row*3
    add al, bl          ; al = row*4
    add al, bl          ; al = row*5
    add al, inputCol    ; al = row*5 + col
    mov gridIndex, al   ; save result

    pop bx
    pop ax
    ret
calcIndex ENDP

drawCell PROC
    push ax
    push bx
    push cx

    mov al, cellVal
    cmp al, 0
    je  dc_water
    cmp al, 1
    je  dc_block
    cmp al, 2
    je  dc_hit
    ; miss
    mov ah, 09h
    mov al, 'O'
    mov bh, 0
    mov bl, COL_MISS
    mov cx, 1
    int 10h
    jmp dc_done
    dc_water:
        mov ah, 09h
        mov al, '~'
        mov bh, 0
        mov bl, COL_WATER
        mov cx, 1
        int 10h
        jmp dc_done
    dc_block:
        mov ah, 09h
        mov al, 'B'
        mov bh, 0
        mov bl, COL_BLOCK
        mov cx, 1
        int 10h
        jmp dc_done
    dc_hit:
        mov ah, 09h
        mov al, 'X'
        mov bh, 0
        mov bl, COL_HIT
        mov cx, 1
        int 10h
    dc_done:
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

    ; YOUR GRID label
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

    ; column numbers
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
    mov curRow, 0

    dg_rowloop:
        cmp curRow, 5
        je  dg_done

       
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

        dg_colloop:
            cmp curCol, 5
            je  dg_nextrow

           
            mov al, curRow
            mov inputRow, al
            mov al, curCol
            mov inputCol, al
            call calcIndex      

       
            mov bx, 0
            mov bl, gridIndex
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
            jmp dg_colloop

        dg_nextrow:
        inc curRow
        jmp dg_rowloop

    dg_done:
   
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

    gv_read:
        mov ah, 01h
        int 21h

        cmp al, 13
        je  gv_read
        cmp al, 10
        je  gv_read

        cmp al, '1'
        jl  gv_bad
        cmp al, '5'
        jg  gv_bad
        jmp gv_good

        gv_bad:
            SET_CURSOR 17, 2
            mov ah, 09h
            lea dx, errorRange
            int 21h
            jmp gv_read
   

    pop dx
    pop bx
    ret
getValidInput ENDP

placeBlocks PROC
    push ax
    push bx
    push dx
    push si

    mov blockCount, 1       

    pb_loop:                                
        je  pb_alldone

        
        SET_CURSOR 13, 2
        mov ah, 09h
        lea dx, blockMsg
        int 21h
        
        mov ah, 09h
        mov al, blockCount
        add al, '0'        
        mov bh, 0
        mov bl, 1Eh
        mov cx, 1
        int 10h
        SET_CURSOR 13, 18
        mov ah, 09h
        lea dx, ofThree
        int 21h

       
        SET_CURSOR 15, 2
        mov ah, 09h
        lea dx, placeInstr
        int 21h
        SHOW_CURSOR
        call getValidInput
        mov inputRow, al    

       
        SET_CURSOR 16, 2
        mov ah, 09h
        lea dx, placeInstr2
        int 21h
        SHOW_CURSOR
        call getValidInput
        mov inputCol, al    

       
        call calcIndex      

        lea si, playerGrid
        mov bx, 0
        mov bl, gridIndex
        mov al, [si+bx]
        cmp al, 1
        jne pb_place

        SET_CURSOR 17, 2
        mov ah, 09h
        lea dx, errorDupe
        int 21h
        SET_CURSOR 15, 2
        mov ah, 09h
        lea dx, blankLine
        int 21h
        SET_CURSOR 16, 2
        mov ah, 09h
        lea dx, blankLine
        int 21h
        jmp pb_loop         

        pb_place:
    
        lea si, playerGrid
        mov bx, 0
        mov bl, gridIndex
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
        lea dx, blankLine
        int 21h
        SET_CURSOR 16, 2
        mov ah, 09h
        lea dx, blankLine
        int 21h

        ; next block
        inc blockCount
        jmp pb_loop

    pb_alldone:
    HIDE_CURSOR
    SET_CURSOR 19, 2
    mov ah, 09h
    lea dx, doneMsg
    int 21h
    mov ah, 00h
    int 16h

    pop si
    pop dx
    pop bx
    pop ax
    ret
placeBlocks ENDP

main PROC
    mov ax, @data
    mov ds, ax

    CLEAR_SCREEN
    HIDE_CURSOR

    ; title
    mov ah, 06h
    mov al, 0
    mov bh, 1Eh
    mov ch, 1
    mov cl, 10
    mov dh, 1
    mov dl, 55
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

    mov ah, 4Ch
    mov al, 0
    int 21h
main ENDP
END main