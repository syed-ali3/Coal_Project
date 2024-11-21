[org 0x100]
PA_POS: dw 230
PB_POS: dw 3750
BALL_POS: dw 3600
sizeofPaddles: dw 10

;to print black use 0x0720  or to print white use 0x7720


jmp start






; clear screen function ---------------------
clrscr:
    push ax
    push di
    push es
    push cx
    mov ax,0xb800
    mov es,ax
    mov di,0
    mov cx,2000
    mov ax,0x0720
    rep stosw
    pop cx
    pop es
    pop di
    pop ax
    ret
;Loads the startig game screen ---------------
initializeGame:
    call clrscr
    ; intializing player A Paddle
    mov ax,0XB800
    mov es,ax
    mov di,[PA_POS]
    mov ax,0x7720
    mov cx,[sizeofPaddles]
    rep stosw
    ; intializing player B Paddle
    mov ax,0XB800
    mov es,ax
    mov di,[PB_POS]
    mov ax,0x7720
    mov cx,[sizeofPaddles]
    rep stosw  
    ;initializing ball
    mov si,[BALL_POS]
    mov word[es:si],0x072A
    RET




start:
    
    call initializeGame

    mov ax,0x4c00
    int 0x21