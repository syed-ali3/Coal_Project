[org 0x100]
jmp start
PA_POS: dw 0
PB_POS: dw 0
BALL_POS: dw 0
sizeofPaddles: dw 10 ; const
ScoreA: dw 0
scoreB: dw 0
BallDirection: dw 0 ;diagonal direction
ballnextPos:dw 0    ;balls up/down direction

scorestr: db 'Score :'


; our timer interupt------------------------
MY_TIMER_ISR:
    push ax
    call movBall




    mov al 0x20
    mov 0x20,al
    pop ax
    iret

movBall:









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
    push bp 
    mov bp,sp
    pusha

    mov word[PA_POS],70
    mov word[PB_POS],3750
    mov word[BALL_POS],3600
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

    popa
    pop bp
    RET


start:
    
    call initializeGame
   labe: jmp labe
    mov ax,0x4c00
    int 0x21