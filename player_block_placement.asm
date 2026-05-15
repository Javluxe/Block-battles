; =========================================
; Player Block Placement Code (EMU8086)
; Extracted from Block Battles Project
; =========================================

placeBlocks PROC
    push ax
    push bx
    push dx
    push si

    mov bCount, 1

nextBlock:
    cmp bCount, 4
    je  doneBlocks

retryPlacement:

    ; Input Row
    call getKey
    mov pRow, al

    ; Input Column
    call getKey
    mov pCol, al

    ; Convert row/col to array index
    mov al, pRow
    mov bl, 5
    mul bl
    add al, pCol
    mov pIdx, al

    ; Check if block already exists
    lea si, playerGrid
    xor bx, bx
    mov bl, pIdx
    mov al, [si+bx]

    cmp al, 0
    jne duplicateBlock

    ; Place block
    mov byte ptr [si+bx], 1

    ; Display block on screen
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

    ; Print 'B'
    mov ah, 09h
    mov al, 'B'
    mov bh, 0
    mov bl, 1Ch
    mov cx, 1
    int 10h

    inc bCount
    jmp nextBlock

duplicateBlock:
    jmp retryPlacement

doneBlocks:
    pop si
    pop dx
    pop bx
    pop ax
    ret

placeBlocks ENDP
