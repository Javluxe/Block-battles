.model small
.stack 100h

.data

    ; grids
    playerGrid  db 25 dup(0)
    enemyGrid   db 25 dup(0)

    ; placement variables 
    pRow        db 0
    pCol        db 0
    pIdx        db 0
    bCount      db 1

    ; draw variables 
    dRow        db 0
    dCol        db 0
    dIdx        db 0
    dCell       db 0
    dSRow       db 0
    dSCol       db 0

    ; computer AI variables
    cRow        db 0
    cCol        db 0
    cIdx        db 0
    cPhase      db 0

    ; hit counters
    playerHits  db 0
    compHits    db 0

    ; grid who to draw (0=player,1=enemy)
    drawWho     db 0

    ; grid positions for placement screen
    PGRID_ROW   equ 5
    PGRID_COL   equ 4

    ; grid positions for game screen
    PGRID_ROW2  equ 7
    PGRID_COL2  equ 3
    EGRID_ROW2  equ 7
    EGRID_COL2  equ 42

    ; colours
    COL_WATER   equ 1Bh
    COL_BLOCK   equ 1Ch
    COL_HIT     equ 1Ch
    COL_MISS    equ 1Fh
    COL_LABEL   equ 1Eh
    COL_HEADER  equ 1Bh

    menuTitle   db '     B L O C K   B A T T L E S    $'
    menuSub     db '      A Grid-Based Strategy Game   $'
    menuBorder  db ' ===================================$'
    menuOpt1    db '         [1]  Play Game            $'
    menuOpt2    db '         [2]  Instructions         $'
    menuOpt3    db '         [3]  Quit                 $'
    menuPrompt  db '       Enter choice (1/2/3):       $'
    menuBad     db '       Invalid! Press 1, 2 or 3.  $'
    insTitle    db '      I N S T R U C T I O N S     $'
    ins1        db '  HOW TO PLAY:                     $'
    ins2        db '  - You and computer have 5x5 grid $'
    ins3        db '  - Place 3 blocks on your grid    $'
    ins4        db '  - Take turns firing coordinates  $'
    ins5        db '  - Enter row (1-5) then col (1-5) $'
    ins6        db '  SYMBOLS:                         $'
    ins7        db '  [~] Water   [B] Your Block       $'
    ins8        db '  [X] Hit!    [O] Miss              $'
    ins9        db '  GOAL: Destroy all 3 enemy blocks!$'
    insBack     db '  Press any key to return...       $'
    insBorder   db ' ===================================$'
    
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
    statLine    db ' =========================================$'

    ; module 4 strings
    yourLabel2  db '   YOUR GRID   $'
    enemyLabel2 db '  ENEMY GRID   $'
    colNumbers2 db ' 1 2 3 4 5     $'
    statLine2   db ' ================================================$'
    fireRow     db ' YOUR TURN - Row (1-5): $'
    fireCol     db ' Col (1-5): $'
    msgHit      db ' *** HIT! You struck an enemy block! ***        $'
    msgMiss     db ' ... Miss! Nothing there.                       $'
    msgCompHit  db ' *** Computer HIT your block! ***               $'
    msgCompMiss db ' ... Computer missed!                           $'
    msgAlready  db ' Already fired there! Try again.                $'
    pressComp   db ' Press any key for computer turn...             $'
    pressCont   db ' Press any key to continue...                   $'
    blank       db '                                                 $'
    blank2      db '                                   $'

    msgWin      db ' YOU WIN!                                        $'
    msgLose     db ' GAME OVER!                                      $'
    msgReplay   db ' Press any key...                                $'

    ; win screen 
    winTitle    db '       * * *  Y O U   W I N  * * *      $'
    winMsg1     db '   All 3 enemy blocks destroyed!         $'
    winMsg2     db '   Congratulations! You are the winner!  $'

    ; lose screen 
    loseTitle   db '       * *  G A M E   O V E R  * *      $'
    loseMsg1    db '   Computer destroyed all your blocks!   $'
    loseMsg2    db '   Better luck next time!                $'

    ; end screen
    endOpt1     db '        [1]  Play Again                  $'
    endOpt2     db '        [2]  Return to Main Menu         $'
    endOpt3     db '        [3]  Quit                        $'
    endPrompt   db '      Enter choice (1/2/3):              $'
    endBorder   db ' ========================================$'

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

getKey PROC
inputLoop:
    mov ah, 01h
    int 21h

    cmp al, 13
    je  inputLoop

    cmp al, '1'
    jl  badInput
    cmp al, '5'
    jg  badInput

    sub al, '1'
    ret

badInput:
    SET_CURSOR 17, 2
    mov ah, 09h
    lea dx, msgBad
    int 21h
    jmp inputLoop
getKey ENDP

drawPlayerGrid PROC
    push ax
    push bx
    push cx
    push dx
    push si

    mov ah, 06h
    mov al, 0
    mov bh, 1Eh
    mov ch, 3
    mov cl, PGRID_COL
    mov dh, 3
    mov dl, PGRID_COL+13
    int 10h
    SET_CURSOR 3, PGRID_COL
    mov ah, 09h
    lea dx, yourLabel
    int 21h

    mov ah, 06h
    mov al, 0
    mov bh, 1Bh
    mov ch, 4
    mov cl, PGRID_COL
    mov dh, 4
    mov dl, PGRID_COL+13
    int 10h
    SET_CURSOR 4, PGRID_COL
    mov ah, 09h
    lea dx, colNumbers
    int 21h

    lea si, playerGrid
    mov dRow, 0

rowLoop:
    cmp dRow, 5
    je  gridDone

    mov al, dRow
    add al, PGRID_ROW
    mov dSRow, al
    mov ah, 02h
    mov bh, 0
    mov dh, dSRow
    mov dl, PGRID_COL-2
    int 10h
    mov ah, 09h
    mov al, dRow
    add al, '1'
    mov bh, 0
    mov bl, 1Bh
    mov cx, 1
    int 10h

    mov dCol, 0

colLoop:
    cmp dCol, 5
    je  nextRow

    mov al, dRow
    mov bl, 5
    mul bl
    add al, dCol
    mov dIdx, al

    xor bx, bx
    mov bl, dIdx
    mov al, [si+bx]
    mov dCell, al

    mov al, dRow
    add al, PGRID_ROW
    mov dSRow, al
    mov al, dCol
    shl al, 1
    add al, PGRID_COL
    mov dSCol, al

    mov ah, 02h
    mov bh, 0
    mov dh, dSRow
    mov dl, dSCol
    int 10h

    mov al, dCell
    cmp al, 0
    je  drawWater
    cmp al, 1
    je  drawBlock
    cmp al, 2
    je  drawHit

drawMiss:
    mov ah, 09h
    mov al, 'O'
    mov bh, 0
    mov bl, 1Fh
    mov cx, 1
    int 10h
    jmp nextCol

drawWater:
    mov ah, 09h
    mov al, '~'
    mov bh, 0
    mov bl, 1Bh
    mov cx, 1
    int 10h
    jmp nextCol

drawBlock:
    mov ah, 09h
    mov al, 'B'
    mov bh, 0
    mov bl, 1Ch
    mov cx, 1
    int 10h
    jmp nextCol

drawHit:
    mov ah, 09h
    mov al, 'X'
    mov bh, 0
    mov bl, 1Ch
    mov cx, 1
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

placeBlocks PROC
    push ax
    push bx
    push cx
    push dx
    push si

    mov bCount, 1

nextBlock:
    cmp bCount, 4
    je  doneBlocks

retryPlacement:
    SET_CURSOR 17, 2
    mov ah, 09h
    lea dx, blank2
    int 21h

    SET_CURSOR 13, 2
    mov ah, 09h
    lea dx, msgBlock
    int 21h
    mov ah, 09h
    mov al, bCount
    add al, '0'
    mov bh, 0
    mov bl, 1Eh
    mov cx, 1
    int 10h
    SET_CURSOR 13, 18
    mov ah, 09h
    lea dx, msgOf3
    int 21h

    SET_CURSOR 15, 2
    mov ah, 09h
    lea dx, askRow
    int 21h
    SHOW_CURSOR
    call getKey
    mov pRow, al

    SET_CURSOR 16, 2
    mov ah, 09h
    lea dx, askCol
    int 21h
    SHOW_CURSOR
    call getKey
    mov pCol, al

    mov al, pRow
    mov bl, 5
    mul bl
    add al, pCol
    mov pIdx, al

    lea si, playerGrid
    xor bx, bx
    mov bl, pIdx
    mov al, [si+bx]

    cmp al, 0
    jne duplicateBlock

    mov byte ptr [si+bx], 1

    mov al, pRow
    add al, PGRID_ROW
    mov dSRow, al
    mov al, pCol
    shl al, 1
    add al, PGRID_COL
    mov dSCol, al
    mov ah, 02h
    mov bh, 0
    mov dh, dSRow
    mov dl, dSCol
    int 10h
    mov ah, 09h
    mov al, 'B'
    mov bh, 0
    mov bl, 1Ch
    mov cx, 1
    int 10h

    SET_CURSOR 17, 2
    mov ah, 09h
    lea dx, msgOK
    int 21h

    HIDE_CURSOR
    call drawPlayerGrid

    SET_CURSOR 15, 2
    mov ah, 09h
    lea dx, blank2
    int 21h
    SET_CURSOR 16, 2
    mov ah, 09h
    lea dx, blank2
    int 21h

    inc bCount
    jmp nextBlock

duplicateBlock:
    SET_CURSOR 17, 2
    mov ah, 09h
    lea dx, msgDupe
    int 21h
    jmp retryPlacement

doneBlocks:
    HIDE_CURSOR
    SET_CURSOR 19, 2
    mov ah, 09h
    lea dx, msgDone
    int 21h
    mov ah, 00h
    int 16h

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
placeBlocks ENDP

drawGameGrid PROC
    push ax
    push bx
    push cx
    push dx
    push si

    cmp drawWho, 0
    jne dgg_enemy

    lea si, playerGrid
    mov ah, 06h
    mov al, 0
    mov bh, COL_LABEL
    mov ch, 5
    mov cl, PGRID_COL2
    mov dh, 5
    mov dl, PGRID_COL2+14
    int 10h
    SET_CURSOR 5, PGRID_COL2
    mov ah, 09h
    lea dx, yourLabel2
    int 21h
    mov ah, 06h
    mov al, 0
    mov bh, COL_HEADER
    mov ch, 6
    mov cl, PGRID_COL2
    mov dh, 6
    mov dl, PGRID_COL2+14
    int 10h
    SET_CURSOR 6, PGRID_COL2
    mov ah, 09h
    lea dx, colNumbers2
    int 21h
    jmp dgg_cells

    dgg_enemy:
    lea si, enemyGrid
    mov ah, 06h
    mov al, 0
    mov bh, COL_LABEL
    mov ch, 5
    mov cl, EGRID_COL2
    mov dh, 5
    mov dl, EGRID_COL2+14
    int 10h
    SET_CURSOR 5, EGRID_COL2
    mov ah, 09h
    lea dx, enemyLabel2
    int 21h
    mov ah, 06h
    mov al, 0
    mov bh, COL_HEADER
    mov ch, 6
    mov cl, EGRID_COL2
    mov dh, 6
    mov dl, EGRID_COL2+14
    int 10h
    SET_CURSOR 6, EGRID_COL2
    mov ah, 09h
    lea dx, colNumbers2
    int 21h

    dgg_cells:
    mov dRow, 0

    dgg_rl:
        cmp dRow, 5
        je  dgg_done

        mov al, dRow
        cmp drawWho, 0
        jne dgg_er
        add al, PGRID_ROW2
        mov dSRow, al
        mov dh, dSRow
        mov dl, PGRID_COL2-2
        jmp dgg_rn
        dgg_er:
        add al, EGRID_ROW2
        mov dSRow, al
        mov dh, dSRow
        mov dl, EGRID_COL2-2
        dgg_rn:
        mov ah, 02h
        mov bh, 0
        int 10h
        mov ah, 09h
        mov al, dRow
        add al, '1'
        mov bh, 0
        mov bl, COL_HEADER
        mov cx, 1
        int 10h

        mov dCol, 0

        dgg_cl:
            cmp dCol, 5
            je  dgg_nr

            ; index = row*5+col using mul 
            mov al, dRow
            mov bl, 5
            mul bl
            add al, dCol
            mov dIdx, al

            xor bx, bx
            mov bl, dIdx
            mov al, [si+bx]
            mov dCell, al

            ; hide enemy blocks
            cmp drawWho, 1
            jne dgg_nh
            cmp dCell, 1
            jne dgg_nh
            mov dCell, 0
            dgg_nh:

            mov al, dRow
            cmp drawWho, 0
            jne dgg_ep
            add al, PGRID_ROW2
            mov dSRow, al
            mov al, dCol
            shl al, 1
            add al, PGRID_COL2
            mov dSCol, al
            jmp dgg_sc
            dgg_ep:
            add al, EGRID_ROW2
            mov dSRow, al
            mov al, dCol
            shl al, 1
            add al, EGRID_COL2
            mov dSCol, al

            dgg_sc:
            mov ah, 02h
            mov bh, 0
            mov dh, dSRow
            mov dl, dSCol
            int 10h

            mov al, dCell
            cmp al, 1
            je  dgg_b
            cmp al, 2
            je  dgg_h
            cmp al, 3
            je  dgg_m
            mov ah, 09h
            mov al, '~'
            mov bh, 0
            mov bl, COL_WATER
            mov cx, 1
            int 10h
            jmp dgg_d
            dgg_b:
                mov ah, 09h
                mov al, 'B'
                mov bh, 0
                mov bl, COL_BLOCK
                mov cx, 1
                int 10h
                jmp dgg_d
            dgg_h:
                mov ah, 09h
                mov al, 'X'
                mov bh, 0
                mov bl, COL_HIT
                mov cx, 1
                int 10h
                jmp dgg_d
            dgg_m:
                mov ah, 09h
                mov al, 'O'
                mov bh, 0
                mov bl, COL_MISS
                mov cx, 1
                int 10h
            dgg_d:

            inc dCol
            jmp dgg_cl

        dgg_nr:
        inc dRow
        jmp dgg_rl

    dgg_done:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
drawGameGrid ENDP

drawBothGrids PROC
    push ax
    HIDE_CURSOR
    mov drawWho, 0
    call drawGameGrid
    mov drawWho, 1
    call drawGameGrid
    pop ax
    ret
drawBothGrids ENDP

getGameKey PROC
    ggk_loop:
        mov ah, 01h
        int 21h
        cmp al, 13
        je  ggk_loop
        cmp al, '1'
        jl  ggk_bad
        cmp al, '5'
        jg  ggk_bad
        sub al, '1'
        ret
        ggk_bad:
            SET_CURSOR 23, 0
            mov ah, 09h
            lea dx, msgBad
            int 21h
            jmp ggk_loop
getGameKey ENDP

playerTurn PROC
    push ax
    push bx
    push dx
    push si

    pt_retry:
    SET_CURSOR 20, 0
    mov ah, 09h
    lea dx, blank
    int 21h
    SET_CURSOR 21, 0
    mov ah, 09h
    lea dx, blank
    int 21h

    ; row on line 20
    SET_CURSOR 20, 0
    mov ah, 09h
    lea dx, fireRow
    int 21h
    SHOW_CURSOR
    call getGameKey
    mov pRow, al

    ; col on line 21
    SET_CURSOR 21, 0
    mov ah, 09h
    lea dx, fireCol
    int 21h
    SHOW_CURSOR
    call getGameKey
    mov pCol, al

    HIDE_CURSOR

    mov al, pRow
    mov bl, 5
    mul bl
    add al, pCol
    mov pIdx, al

    ; read enemyGrid cell
    lea si, enemyGrid
    xor bx, bx
    mov bl, pIdx
    mov al, [si+bx]

    ; already fired?
    cmp al, 2
    je  pt_already
    cmp al, 3
    je  pt_already

    ; hit or miss?
    cmp al, 1
    jne pt_miss

    ; HIT
    mov byte ptr [si+bx], 2
    inc playerHits
    mov drawWho, 1
    call drawGameGrid
    SET_CURSOR 20, 0
    mov ah, 09h
    lea dx, msgHit
    int 21h
    jmp pt_wait

    pt_miss:
    mov byte ptr [si+bx], 3
    mov drawWho, 1
    call drawGameGrid
    SET_CURSOR 20, 0
    mov ah, 09h
    lea dx, msgMiss
    int 21h
    jmp pt_wait

    pt_already:
    SET_CURSOR 20, 0
    mov ah, 09h
    lea dx, msgAlready
    int 21h
    mov ah, 00h
    int 16h
    jmp pt_retry

    pt_wait:
    SET_CURSOR 21, 0
    mov ah, 09h
    lea dx, pressComp
    int 21h
    mov ah, 00h
    int 16h
    SET_CURSOR 20, 0
    mov ah, 09h
    lea dx, blank
    int 21h
    SET_CURSOR 21, 0
    mov ah, 09h
    lea dx, blank
    int 21h

    pop si
    pop dx
    pop bx
    pop ax
    ret
playerTurn ENDP

computerTurn PROC
    push ax
    push bx
    push dx
    push si

    ct_find:
        cmp cRow, 5
        jne ct_chk
        cmp cPhase, 1
        je  ct_end
        mov cPhase, 1
        mov cRow, 0
        mov cCol, 0

        ct_chk:
        mov al, cRow
        add al, cCol
        and al, 01h
        cmp al, cPhase
        jne ct_skip

        ; index using same mul 
        mov al, cRow
        mov bl, 5
        mul bl
        add al, cCol
        mov cIdx, al

        lea si, playerGrid
        xor bx, bx
        mov bl, cIdx
        mov al, [si+bx]

        cmp al, 2
        je  ct_skip
        cmp al, 3
        je  ct_skip

        cmp al, 1
        jne ct_cmiss

        ; computer HIT
        mov byte ptr [si+bx], 2
        inc compHits
        mov drawWho, 0
        call drawGameGrid
        SET_CURSOR 20, 0
        mov ah, 09h
        lea dx, msgCompHit
        int 21h
        jmp ct_adv

        ct_cmiss:
        mov byte ptr [si+bx], 3
        mov drawWho, 0
        call drawGameGrid
        SET_CURSOR 20, 0
        mov ah, 09h
        lea dx, msgCompMiss
        int 21h

        ct_adv:
        inc cCol
        cmp cCol, 5
        jne ct_end
        mov cCol, 0
        inc cRow
        jmp ct_end

        ct_skip:
        inc cCol
        cmp cCol, 5
        jne ct_find
        mov cCol, 0
        inc cRow
        jmp ct_find

    ct_end:
    SET_CURSOR 21, 0
    mov ah, 09h
    lea dx, pressCont
    int 21h
    mov ah, 00h
    int 16h
    SET_CURSOR 20, 0
    mov ah, 09h
    lea dx, blank
    int 21h
    SET_CURSOR 21, 0
    mov ah, 09h
    lea dx, blank
    int 21h

    pop si
    pop dx
    pop bx
    pop ax
    ret
computerTurn ENDP

setupComputer PROC
    push bx
    push si
    lea si, enemyGrid
    mov bx, 2
    mov byte ptr [si+bx], 1
    mov bx, 14
    mov byte ptr [si+bx], 1
    mov bx, 21
    mov byte ptr [si+bx], 1
    pop si
    pop bx
    ret
setupComputer ENDP

initGame PROC
    push ax
    push bx
    push cx
    push si

    lea si, playerGrid
    mov cx, 25
    mov bx, 0
    ig_p:
        mov byte ptr [si+bx], 0
        inc bx
        loop ig_p

    lea si, enemyGrid
    mov cx, 25
    mov bx, 0
    ig_e:
        mov byte ptr [si+bx], 0
        inc bx
        loop ig_e

    mov playerHits, 0
    mov compHits, 0
    mov cRow, 0
    mov cCol, 0
    mov cPhase, 0
    mov bCount, 1

    pop si
    pop cx
    pop bx
    pop ax
    ret
initGame ENDP

gameLoop PROC
    push ax
    push dx
    gl_loop:
        cmp playerHits, 3
        je  gl_done
        cmp compHits, 3
        je  gl_done
        call playerTurn
        cmp playerHits, 3
        je  gl_done
        call computerTurn
        jmp gl_loop
    gl_done:
    pop dx
    pop ax
    ret
gameLoop ENDP

showMenu PROC
    push ax
    push dx
    CLEAR_SCREEN
    HIDE_CURSOR

    mov ah, 06h
    mov al, 0
    mov bh, 1Eh
    mov ch, 3
    mov cl, 8
    mov dh, 3
    mov dl, 48
    int 10h
    SET_CURSOR 3, 8
    mov ah, 09h
    lea dx, menuTitle
    int 21h

    mov ah, 06h
    mov al, 0
    mov bh, 1Bh
    mov ch, 4
    mov cl, 8
    mov dh, 4
    mov dl, 48
    int 10h
    SET_CURSOR 4, 8
    mov ah, 09h
    lea dx, menuSub
    int 21h

    SET_CURSOR 6, 8
    mov ah, 09h
    lea dx, menuBorder
    int 21h

    mov ah, 06h
    mov al, 0
    mov bh, 1Ah
    mov ch, 7
    mov cl, 8
    mov dh, 7
    mov dl, 48
    int 10h
    SET_CURSOR 7, 8
    mov ah, 09h
    lea dx, menuOpt1
    int 21h

    mov ah, 06h
    mov al, 0
    mov bh, 1Eh
    mov ch, 8
    mov cl, 8
    mov dh, 8
    mov dl, 48
    int 10h
    SET_CURSOR 8, 8
    mov ah, 09h
    lea dx, menuOpt2
    int 21h

    mov ah, 06h
    mov al, 0
    mov bh, 1Ch
    mov ch, 9
    mov cl, 8
    mov dh, 9
    mov dl, 48
    int 10h
    SET_CURSOR 9, 8
    mov ah, 09h
    lea dx, menuOpt3
    int 21h

    SET_CURSOR 10, 8
    mov ah, 09h
    lea dx, menuBorder
    int 21h

    SET_CURSOR 12, 8
    mov ah, 09h
    lea dx, menuPrompt
    int 21h

    pop dx
    pop ax
    ret
showMenu ENDP

showInstructions PROC
    push ax
    push dx
    CLEAR_SCREEN
    HIDE_CURSOR

    mov ah, 06h
    mov al, 0
    mov bh, 1Eh
    mov ch, 2
    mov cl, 8
    mov dh, 2
    mov dl, 48
    int 10h
    SET_CURSOR 2, 8
    mov ah, 09h
    lea dx, insTitle
    int 21h

    SET_CURSOR 3, 8
    mov ah, 09h
    lea dx, insBorder
    int 21h
    SET_CURSOR 4, 8
    mov ah, 09h
    lea dx, ins1
    int 21h
    SET_CURSOR 5, 8
    mov ah, 09h
    lea dx, ins2
    int 21h
    SET_CURSOR 6, 8
    mov ah, 09h
    lea dx, ins3
    int 21h
    SET_CURSOR 7, 8
    mov ah, 09h
    lea dx, ins4
    int 21h
    SET_CURSOR 8, 8
    mov ah, 09h
    lea dx, ins5
    int 21h
    SET_CURSOR 10, 8
    mov ah, 09h
    lea dx, ins6
    int 21h
    SET_CURSOR 11, 8
    mov ah, 09h
    lea dx, ins7
    int 21h
    SET_CURSOR 12, 8
    mov ah, 09h
    lea dx, ins8
    int 21h

    mov ah, 06h
    mov al, 0
    mov bh, 1Ah
    mov ch, 14
    mov cl, 8
    mov dh, 14
    mov dl, 48
    int 10h
    SET_CURSOR 14, 8
    mov ah, 09h
    lea dx, ins9
    int 21h

    SET_CURSOR 15, 8
    mov ah, 09h
    lea dx, insBorder
    int 21h
    SET_CURSOR 17, 8
    mov ah, 09h
    lea dx, insBack
    int 21h

    mov ah, 00h
    int 16h

    pop dx
    pop ax
    ret
showInstructions ENDP

showWinScreen PROC
    push dx

    CLEAR_SCREEN
    HIDE_CURSOR

    ; green region for title
    mov ah, 06h
    mov al, 0
    mov bh, 1Ah         
    mov ch, 4
    mov cl, 8
    mov dh, 4
    mov dl, 55
    int 10h
    SET_CURSOR 4, 8
    mov ah, 09h
    lea dx, endBorder
    int 21h

    mov ah, 06h
    mov al, 0
    mov bh, 1Ah
    mov ch, 5
    mov cl, 8
    mov dh, 5
    mov dl, 55
    int 10h
    SET_CURSOR 5, 8
    mov ah, 09h
    lea dx, winTitle
    int 21h

    mov ah, 06h
    mov al, 0
    mov bh, 1Ah
    mov ch, 6
    mov cl, 8
    mov dh, 6
    mov dl, 55
    int 10h
    SET_CURSOR 6, 8
    mov ah, 09h
    lea dx, endBorder
    int 21h

    SET_CURSOR 8, 8
    mov ah, 09h
    lea dx, winMsg1
    int 21h

    SET_CURSOR 9, 8
    mov ah, 09h
    lea dx, winMsg2
    int 21h

    SET_CURSOR 11, 8
    mov ah, 09h
    lea dx, endBorder
    int 21h

    ; options
    mov ah, 06h
    mov al, 0
    mov bh, 1Ah         ; green = play again
    mov ch, 12
    mov cl, 8
    mov dh, 12
    mov dl, 55
    int 10h
    SET_CURSOR 12, 8
    mov ah, 09h
    lea dx, endOpt1
    int 21h

    mov ah, 06h
    mov al, 0
    mov bh, 1Eh        
    mov ch, 13
    mov cl, 8
    mov dh, 13
    mov dl, 55
    int 10h
    SET_CURSOR 13, 8
    mov ah, 09h
    lea dx, endOpt2
    int 21h

    mov ah, 06h
    mov al, 0
    mov bh, 1Ch         ; red = quit
    mov ch, 14
    mov cl, 8
    mov dh, 14
    mov dl, 55
    int 10h
    SET_CURSOR 14, 8
    mov ah, 09h
    lea dx, endOpt3
    int 21h

    SET_CURSOR 15, 8
    mov ah, 09h
    lea dx, endBorder
    int 21h

    SET_CURSOR 17, 8
    mov ah, 09h
    lea dx, endPrompt
    int 21h

    ; read choice
    SHOW_CURSOR
    ws_read:
        mov ah, 01h
        int 21h
        cmp al, 13
        je  ws_read
        cmp al, '1'
        je  ws_ok
        cmp al, '2'
        je  ws_ok
        cmp al, '3'
        je  ws_ok
        jmp ws_read
    ws_ok:

    pop dx
    ret
showWinScreen ENDP


showLoseScreen PROC
    push dx

    CLEAR_SCREEN
    HIDE_CURSOR

    mov ah, 06h
    mov al, 0
    mov bh, 1Ch         
    mov ch, 4
    mov cl, 8
    mov dh, 4
    mov dl, 55
    int 10h
    SET_CURSOR 4, 8
    mov ah, 09h
    lea dx, endBorder
    int 21h

    mov ah, 06h
    mov al, 0
    mov bh, 1Ch
    mov ch, 5
    mov cl, 8
    mov dh, 5
    mov dl, 55
    int 10h
    SET_CURSOR 5, 8
    mov ah, 09h
    lea dx, loseTitle
    int 21h

    mov ah, 06h
    mov al, 0
    mov bh, 1Ch
    mov ch, 6
    mov cl, 8
    mov dh, 6
    mov dl, 55
    int 10h
    SET_CURSOR 6, 8
    mov ah, 09h
    lea dx, endBorder
    int 21h

    SET_CURSOR 8, 8
    mov ah, 09h
    lea dx, loseMsg1
    int 21h

    SET_CURSOR 9, 8
    mov ah, 09h
    lea dx, loseMsg2
    int 21h

    SET_CURSOR 11, 8
    mov ah, 09h
    lea dx, endBorder
    int 21h

    ; options
    mov ah, 06h
    mov al, 0
    mov bh, 1Ah
    mov ch, 12
    mov cl, 8
    mov dh, 12
    mov dl, 55
    int 10h
    SET_CURSOR 12, 8
    mov ah, 09h
    lea dx, endOpt1
    int 21h

    mov ah, 06h
    mov al, 0
    mov bh, 1Eh
    mov ch, 13
    mov cl, 8
    mov dh, 13
    mov dl, 55
    int 10h
    SET_CURSOR 13, 8
    mov ah, 09h
    lea dx, endOpt2
    int 21h

    mov ah, 06h
    mov al, 0
    mov bh, 1Ch
    mov ch, 14
    mov cl, 8
    mov dh, 14
    mov dl, 55
    int 10h
    SET_CURSOR 14, 8
    mov ah, 09h
    lea dx, endOpt3
    int 21h

    SET_CURSOR 15, 8
    mov ah, 09h
    lea dx, endBorder
    int 21h

    SET_CURSOR 17, 8
    mov ah, 09h
    lea dx, endPrompt
    int 21h

    ; read choice
    SHOW_CURSOR
    ls_read:
        mov ah, 01h
        int 21h
        cmp al, 13
        je  ls_read
        cmp al, '1'
        je  ls_ok
        cmp al, '2'
        je  ls_ok
        cmp al, '3'
        je  ls_ok
        jmp ls_read
    ls_ok:

    pop dx
    ret
showLoseScreen ENDP


main PROC
    mov ax, @data
    mov ds, ax

    mainLoop:
        call showMenu
        SHOW_CURSOR

        menuRead:
        mov ah, 01h
        int 21h
        cmp al, 13
        je  menuRead
        cmp al, '1'
        je  startGame
        cmp al, '2'
        je  goInstructions
        cmp al, '3'
        je  quitGame

        SET_CURSOR 14, 8
        mov ah, 09h
        lea dx, menuBad
        int 21h
        jmp menuRead

    goInstructions:
        call showInstructions
        jmp mainLoop

    startGame:
        call initGame

        ; placement screen
        CLEAR_SCREEN
        HIDE_CURSOR
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
        lea dx, statLine
        int 21h
        call drawPlayerGrid
        call placeBlocks

        ; setup computer
        call setupComputer

        ; game screen
        CLEAR_SCREEN
        HIDE_CURSOR
        SET_CURSOR 19, 0
        mov ah, 09h
        lea dx, statLine2
        int 21h
        call drawBothGrids

        ; game loop
        call gameLoop

        ; show win or lose screen and handle choice
        cmp playerHits, 3
        je  doWinScreen
        call showLoseScreen
        jmp handleEndChoice
        doWinScreen:
        call showWinScreen

        handleEndChoice:
        ; al = '1' play again, '2' menu, '3' quit
        cmp al, '1'
        je  startGame       ; play again
        cmp al, '3'
        je  quitGame        ; quit
        jmp mainLoop        ; '2' = main menu

    quitGame:
        mov ah, 06h
        mov al, 0
        mov bh, 07h
        mov ch, 0
        mov cl, 0
        mov dh, 24
        mov dl, 79
        int 10h
        SET_CURSOR 0, 0
        mov ah, 4Ch
        mov al, 0
        int 21h

main ENDP
END main