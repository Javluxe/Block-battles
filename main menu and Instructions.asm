.model small
.stack 100h

; Colour byte = background * 16 + foreground
; 0=Black 1=Blue 2=Green 3=Cyan 4=Red 5=Magenta
; 6=Brown 7=White 9=Lt.Blue 10=Lt.Green 11=Lt.Cyan
; 12=Lt.Red 14=Yellow 15=Bright White

.data

    ; -- Main Menu Strings ----------------------------------
    title1      db '  ____  _            _      ', 13, 10, '$'
    title2      db ' | __ )| | ___   ___| | __  ', 13, 10, '$'
    title3      db ' |  _ \| |/ _ \ / __| |/ /  ', 13, 10, '$'
    title4      db ' | |_) | | (_) | (__|   <   ', 13, 10, '$'
    title5      db ' |____/|_|\___/ \___|_|\_\  ', 13, 10, '$'
    title6      db '  ____        _   _   _les  ', 13, 10, '$'
    titleLine   db ' ================================', 13, 10, '$'

    menuTitle   db '       B L O C K   B A T T L E S      ', '$'
    menuSub     db '    A Grid-Based Strategy Game         ', '$'
    menuOpt1    db '         [1]  Play Game                ', '$'
    menuOpt2    db '         [2]  Instructions             ', '$'
    menuOpt3    db '         [3]  Quit                     ', '$'
    menuPrompt  db '      Enter your choice: ', '$'
    menuBorder  db ' ======================================', '$'

  
    insTitle    db '         I N S T R U C T I O N S      ', '$'
    ins1        db '  HOW TO PLAY:                         ', '$'
    ins2        db '  - Each player has a 5x5 grid         ', '$'
    ins3        db '  - You place 3 blocks on your grid    ', '$'
    ins4        db '  - Computer places 3 hidden blocks    ', '$'
    ins5        db '  - Take turns firing at enemy grid    ', '$'
    ins6        db '  - Enter row (1-5) then col (1-5)     ', '$'
    ins7        db '  SYMBOLS:                             ', '$'
    ins8        db '  [~] = Water (empty)                  ', '$'
    ins9        db '  [B] = Your Block                     ', '$'
    ins10       db '  [X] = Hit!                           ', '$'
    ins11       db '  [O] = Miss                           ', '$'
    ins12       db '  GOAL: Sink all 3 enemy blocks first! ', '$'
    insBack     db '    Press any key to return...         ', '$'

  
    newline     db 13, 10, '$'
    invalidMsg  db '  Invalid choice! Try again.', 13, 10, '$'

.code


SET_CURSOR MACRO row, col
    mov ah, 02h        
    mov bh, 0           ; page 0
    mov dh, row         ; row
    mov dl, col         ; column
    int 10h
ENDM

PRINT_STR MACRO stringLabel
    mov ah, 09h
    lea dx, stringLabel
    int 21h
ENDM


SET_COLOR MACRO color
    mov ah, 09h         
    mov al, ' '         
    mov bh, 0           ; page 0
    mov bl, color       ; colour attribute
    mov cx, 1          
    int 10h
ENDM


HIDE_CURSOR MACRO
    mov ah, 01h
    mov ch, 20h
    int 10h
ENDM

printColored PROC
    push ax
    push bx
    push cx
    push dx

    ; Set cursor position
    mov ah, 02h
    mov bh, 0
    int 10h

    ; Print each character with colour
    mov ah, 09h
    lea dx, [si]
    int 21h

    pop dx
    pop cx
    pop bx
    pop ax
    ret
printColored ENDP


drawBox PROC
    push ax
    push bx
    push cx
    push dx

    ; Top border
    SET_CURSOR 3, 15
    mov ah, 09h
    lea dx, menuBorder
    int 21h

    ; Bottom border
    SET_CURSOR 13, 15
    mov ah, 09h
    lea dx, menuBorder
    int 21h

    pop dx
    pop cx
    pop bx
    pop ax
    ret
drawBox ENDP


showMenu PROC
    push ax
    push bx
    push cx
    push dx

    CLEAR_SCREEN
    HIDE_CURSOR

   
    mov ah, 02h         ; set cursor
    mov bh, 0
    mov dh, 4           ; row 4
    mov dl, 15          ; col 15
    int 10h

    ; Print each title letter with yellow attribute
    mov cx, 38          ; length of title
    mov bl, 14          ; yellow colour
    mov al, 'B'
    titleLoop1:
        mov ah, 09h
        mov bh, 0
        int 10h
        SET_CURSOR 4, 15
        mov ah, 09h
        lea dx, menuTitle
        int 21h
    jmp doneTitle

    doneTitle:
  
    mov ah, 06h
    mov al, 0
    mov bh, 1Eh         ; yellow on blue
    mov ch, 4
    mov cl, 15
    mov dh, 4
    mov dl, 53
    int 10h

    SET_CURSOR 4, 15
    mov ah, 09h
    lea dx, menuTitle
    int 21h


    SET_CURSOR 6, 15
    mov ah, 06h
    mov al, 0
    mov bh, 1Bh         ; cyan on blue
    mov ch, 6
    mov cl, 15
    mov dh, 6
    mov dl, 53
    int 10h

    SET_CURSOR 6, 15
    mov ah, 09h
    lea dx, menuSub
    int 21h

    SET_CURSOR 8, 15
    mov ah, 09h
    lea dx, menuBorder
    int 21h


    SET_CURSOR 9, 15
    mov ah, 06h
    mov al, 0
    mov bh, 1Ah         ; green on blue
    mov ch, 9
    mov cl, 15
    mov dh, 9
    mov dl, 53
    int 10h

    SET_CURSOR 9, 15
    mov ah, 09h
    lea dx, menuOpt1
    int 21h


    SET_CURSOR 10, 15
    mov ah, 06h
    mov al, 0
    mov bh, 1Eh         ; yellow on blue
    mov ch, 10
    mov cl, 15
    mov dh, 10
    mov dl, 53
    int 10h

    SET_CURSOR 10, 15
    mov ah, 09h
    lea dx, menuOpt2
    int 21h

  
    SET_CURSOR 11, 15
    mov ah, 06h
    mov al, 0
    mov bh, 1Ch         ; red on blue
    mov ch, 11
    mov cl, 15
    mov dh, 11
    mov dl, 53
    int 10h

    SET_CURSOR 11, 15
    mov ah, 09h
    lea dx, menuOpt3
    int 21h

    
    SET_CURSOR 12, 15
    mov ah, 09h
    lea dx, menuBorder
    int 21h

   
    SET_CURSOR 14, 15
    mov ah, 09h
    lea dx, menuPrompt
    int 21h

    pop dx
    pop cx
    pop bx
    pop ax
    ret
showMenu ENDP


showInstructions PROC
    push ax
    push bx
    push cx
    push dx

    CLEAR_SCREEN
    HIDE_CURSOR

  
    mov ah, 06h
    mov al, 0
    mov bh, 1Eh         ; yellow on blue
    mov ch, 2
    mov cl, 12
    mov dh, 2
    mov dl, 67
    int 10h

    SET_CURSOR 2, 12
    mov ah, 09h
    lea dx, insTitle
    int 21h

    SET_CURSOR 3, 12
    mov ah, 09h
    lea dx, menuBorder
    int 21h

   
    SET_CURSOR 4, 12
    mov ah, 06h
    mov al, 0
    mov bh, 1Bh
    mov ch, 4
    mov cl, 12
    mov dh, 4
    mov dl, 67
    int 10h

    SET_CURSOR 4, 12
    mov ah, 09h
    lea dx, ins1
    int 21h

    
    SET_CURSOR 5, 12
    mov ah, 09h
    lea dx, ins2
    int 21h

    SET_CURSOR 6, 12
    mov ah, 09h
    lea dx, ins3
    int 21h

    SET_CURSOR 7, 12
    mov ah, 09h
    lea dx, ins4
    int 21h

    SET_CURSOR 8, 12
    mov ah, 09h
    lea dx, ins5
    int 21h

    SET_CURSOR 9, 12
    mov ah, 09h
    lea dx, ins6
    int 21h

    SET_CURSOR 11, 12
    mov ah, 06h
    mov al, 0
    mov bh, 1Bh
    mov ch, 11
    mov cl, 12
    mov dh, 11
    mov dl, 67
    int 10h

    SET_CURSOR 11, 12
    mov ah, 09h
    lea dx, ins7
    int 21h

    SET_CURSOR 12, 12
    mov ah, 09h
    lea dx, ins8
    int 21h

    SET_CURSOR 13, 12
    mov ah, 06h         ; yellow block
    mov al, 0
    mov bh, 1Eh
    mov ch, 13
    mov cl, 12
    mov dh, 13
    mov dl, 67
    int 10h

    SET_CURSOR 13, 12
    mov ah, 09h
    lea dx, ins9
    int 21h

    SET_CURSOR 14, 12
    mov ah, 06h         ; red hit
    mov al, 0
    mov bh, 1Ch
    mov ch, 14
    mov cl, 12
    mov dh, 14
    mov dl, 67
    int 10h

    SET_CURSOR 14, 12
    mov ah, 09h
    lea dx, ins10
    int 21h

    SET_CURSOR 15, 12
    mov ah, 09h
    lea dx, ins11
    int 21h

    SET_CURSOR 17, 12
    mov ah, 06h
    mov al, 0
    mov bh, 1Ah
    mov ch, 17
    mov cl, 12
    mov dh, 17
    mov dl, 67
    int 10h

    SET_CURSOR 17, 12
    mov ah, 09h
    lea dx, ins12
    int 21h

  
    SET_CURSOR 18, 12
    mov ah, 09h
    lea dx, menuBorder
    int 21h


    SET_CURSOR 20, 12
    mov ah, 09h
    lea dx, insBack
    int 21h

    ; Wait for any key
    mov ah, 00h
    int 16h

    pop dx
    pop cx
    pop bx
    pop ax
    ret
showInstructions ENDP


main PROC
    ; Setup data segment
    mov ax, @data
    mov ds, ax

menuLoop:
    ; Show the main menu
    call showMenu

    ; Get player choice using INT 21h
    mov ah, 01h         ; read single character
    int 21h
    ; AL now holds the ASCII of pressed key

   
    cmp al, '1'
    je  startGame       ; Jump to game (Module 2+)

    cmp al, '2'
    je  goInstructions  ; Jump to instructions

    cmp al, '3'
    je  quitGame        ; Quit

    ; Invalid input  show message and loop back
    SET_CURSOR 16, 15
    mov ah, 09h
    lea dx, invalidMsg
    int 21h
    jmp menuLoop

goInstructions:
    call showInstructions
    jmp menuLoop        ; Return to menu after instructions

startGame:
   
    CLEAR_SCREEN
    SET_CURSOR 10, 20
    mov ah, 09h
    lea dx, menuTitle   ; Temp  will be replaced by game screen
    int 21h
    jmp menuLoop       

quitGame:
    ; Restore normal screen and exit
    mov ah, 06h
    mov al, 0
    mov bh, 07h         ; normal white on black
    mov ch, 0
    mov cl, 0
    mov dh, 24
    mov dl, 79
    int 10h
    SET_CURSOR 0, 0

    ; Exit to DOS
    mov ah, 4Ch
    mov al, 0
    int 21h

main ENDP
END main
