[org 0x100]
jmp start
PA_POS: dw 0
PB_POS: dw 0
BALL_POS: dw 0
sizeofPaddles: dw 10 ; const
ScoreA: dw 0
scoreB: dw 0
BallDirection: dw 0 ;diagonal direction
ballVertical:dw 0    ;balls up/down direction  0 means ball is moving upward - 1 means ball is moving downward
tickcount dw 0

scorestr: db 'Score :'


; our timer interupt------------------------
MY_TIMER_ISR:
    push ax
    inc word[cs:tickcount]
    cmp word[cs:tickcount],4
    jne returning
    mov word[cs:tickcount],0
    call movBall




    returning:mov al,0x20
    out 0x20,al
    pop ax
    iret

movBall:
    pusha
    ; setting setup for printing on screen
    mov ax,0xb800
    mov es,ax
    xor ax,ax
    ;4 Conditions
    
    cmp word[cs:ballVertical],0
    je Up_Movement




; M O V I N G  --  U P W A R D  ----------------------------------------------------------------------------------
; 3 CONDITIONS TO HANDLE COLLISION (LEFT-MOST COLUMN ,RIGHTMOST-COLUMN  PADDLEOCCURS)
Up_Movement:
    xor ax,ax
   ;CHECKING THAT IF ITS PRESENT ON RIGHT-MOST COLUMN
    mov ax,[cs:BALL_POS]
    mov bl,160
    xor dx,dx
    div bl
    cmp ah,159
    je rightmostCOL
    ;CHECKING THAT IF ITS PRESENT ON LEFT-MOST COLUMN
    mov ax,[cs:BALL_POS]
    mov bl,160
    xor dx,dx
    div bl
    cmp ah,0
    je LeftmostCOL
    ;CHECKING THAT IF theres a paddle on the next pos of ball
    mov si,[cs:BALL_POS]
    sub si,[cs:BallDirection]
    cmp word[es:si],0x7720
    je PaddleCollisionOccurs

    ;IF no collision then we can move the ball
    jmp MOVEMENT_1

    rightmostCOL:
        mov word[cs:BallDirection],162
        jmp backtoInt

    LeftmostCOL:
        mov word[cs:BallDirection],158
        jmp backtoInt

    PaddleCollisionOccurs:
        mov word[cs:ballVertical],1
        xor ax,ax
        mov ax,[cs:BallDirection]
        cmp ax,158
        je changeTo162
        mov word[cs:BallDirection],158
        jmp backtoInt
        changeTo162:mov word[cs:BallDirection],162
        jmp backtoInt
    
    ; Movement section of the ball from current to next position
    MOVEMENT_1: 
        ; clearing current position
        mov si,[cs:BALL_POS]
        mov word[es:si],0x0720

        ;updating current pos of ball
        mov ax,[cs:BallDirection]
        sub [cs:BALL_POS],ax

        ; placing ball on updated position
        mov si,[cs:BALL_POS]
        mov word[es:si],0x072A

   
    backtoInt:popa
    RET








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
    ; for future movement
    mov word[ballVertical],0
    mov word[BallDirection],158

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
    mov ax,0
    mov es,ax
    cli
    mov word[es:8*4],MY_TIMER_ISR
    mov word[es:8*4+2],cs
    sti


   labe: jmp labe
    mov ax,0x4c00
    int 0x21