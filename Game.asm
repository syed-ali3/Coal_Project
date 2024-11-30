[org 0x100]
jmp start
old_timer dd 0
old_kb dd 0

PA_POS: dw 0
PB_POS: dw 0
BALL_POS: dw 0
sizeofPaddles: dw 10 ; const
ScoreA: dw 0
ScoreB: dw 0
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
    
    ;4 Conditions
    call RC_CHECK
    Call LC_CHECK
    cmp word[cs:ballVertical],0
    je Up_Movement
    down_Movement:
     ;CHECKING THAT IF theres a paddle on the next pos of ball
        mov si,[cs:BALL_POS]
        cmp si,3680
        jle MOVE_NEXT_POS
        add si,160
        cmp word[es:si],0x7720
        je playerBcollision
        inc word [ScoreA]
        call initializeGame
        jmp MOVE_NEXT_POS


; M O V I N G  --  U P W A R D  ----------------------------------------------------------------------------------
; 3 CONDITIONS TO HANDLE COLLISION (LEFT-MOST COLUMN ,RIGHTMOST-COLUMN  PADDLEOCCURS)
; 4th condition if opponent cannot stop the ball
    Up_Movement:
        
        ;CHECKING THAT IF theres a paddle on the next pos of ball
        mov si,[cs:BALL_POS]
        cmp si,320
        jge MOVE_NEXT_POS
        add si,-160
        cmp word[es:si],0x7720
        je playerAcollision
        inc word [ScoreB]
        call initializeGame
        jmp MOVE_NEXT_POS


      

        ;IF no collision then we can move the ball
        jmp MOVE_NEXT_POS

        playerAcollision:
            mov word[cs:ballVertical],1
            mov ax,[cs:BallDirection]
            cmp ax,-158
            jne changeTo158
            mov word[cs:BallDirection],162
            jmp MOVE_NEXT_POS
            changeTo158:mov word[cs:BallDirection],158
            jmp MOVE_NEXT_POS

       playerBcollision:
            mov word[cs:ballVertical],0
            mov ax,[cs:BallDirection]
            cmp ax,158
            jne changeTo_158
            mov word[cs:BallDirection],-162
            jmp MOVE_NEXT_POS
            changeTo_158:mov word[cs:BallDirection],-158
            

        ; Movement section of the ball from current to next position
        MOVE_NEXT_POS: 
            ; clearing current position
            mov si,[cs:BALL_POS]
            mov word[es:si],0x0720

            ;updating current pos of ball
            mov ax,[cs:BallDirection]
            ADD [cs:BALL_POS],ax

            ; placing ball on updated position
            mov si,[cs:BALL_POS]
            mov word[es:si],0x072A
    popa
    RET

;CHECKING THAT IF ITS PRESENT ON RIGHT-MOST COLUMN
    RC_CHECK:
        mov ax,[cs:BALL_POS]
        mov bl,160
        xor dx,dx
        div bl
        cmp ah,158
        je isOnRC
        ret
        isOnRC:
        cmp word[cs:BallDirection],-158
        jne convertTo158
        mov word[cs:BallDirection],-162
        ret
        convertTo158:mov word[cs:BallDirection],158
        ret
        ;CHECKING THAT IF ITS PRESENT ON LEFT-MOST COLUMN
    LC_CHECK:
        mov ax,[cs:BALL_POS]
        mov bl,160
        xor dx,dx
        div bl
        cmp ah,0
        je isOnLC
        ret
        isOnLC:
        cmp word[cs:BallDirection],-162
        jne convertTo162
        mov word[cs:BallDirection],-158
        ret
        convertTo162:
        mov word[cs:BallDirection],162
        ret







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
    mov word[PB_POS],3910
    
    ; for future movement
    cmp word[ballVertical],0
    je skip
    mov word[ballVertical],1
    mov word[BallDirection],162
    mov word[BALL_POS],230
    jmp next
    skip: mov word[ballVertical],0
    mov word[BallDirection],-158
    mov word[BALL_POS],3760
   next: call clrscr
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
    ; printing Player A score
    push word 160
    push word[ScoreA]
    call printScore

    ; printing player B score
    push word 160*23
    push word[ScoreB]
    call printScore
    popa
    pop bp
    RET


MY_KB_ISR:
    push ax

    in al,0x60
    cmp word[ballVertical],0
    je PA_movement
    PB_movement:
        cmp al,0x4d
        jne checkBLeft
        call move_B_Right
        jmp endISR
        checkBLeft:cmp al,0x4b
        jne endISR
        call move_B_Left
        jmp endISR


    PA_movement:
        cmp al,0x20
        jne checkLeft
        call move_A_Right
        jmp endISR
        checkLeft: cmp al,0x1E
        jne endISR
        call move_A_Left


    endISR:
    mov al,0x20
    out 0x20,al
    pop ax
    iret


;moving Player A Rightward ----------
move_A_Right:
    pusha
    push cs
    pop ds
    mov ax,[sizeofPaddles]
    shl ax,1
    add ax,[PA_POS]
    cmp ax,160
    je endAR 
    mov ax,0xb800
    mov es,ax
    mov di,[PA_POS]
    mov word[es:di],0x0720
    add word[PA_POS],2
    add di,[sizeofPaddles]
    add di,[sizeofPaddles]
    mov word[es:di],0x7720
    endAR: popa
    ret
;moving Player A Leftward ----------
move_A_Left: 
    pusha
    push cs
    pop ds
    mov ax,[PA_POS]
    cmp ax,0
    jl endAL 
    mov ax,0xb800
    mov es,ax
    mov di,[sizeofPaddles]
    shl di,1
    add di,[PA_POS]
    mov word[es:di],0x0720
    sub word[PA_POS],2
    sub di,[sizeofPaddles]
    sub di,[sizeofPaddles]
    mov word[es:di],0x7720
    endAL: popa
    ret

move_B_Left:
    pusha
    push cs
    pop ds
    mov ax,[PB_POS]
    cmp ax,3840
    jl endBL 
    mov ax,0xb800
    mov es,ax
    mov di,[sizeofPaddles]
    shl di,1
    add di,[PB_POS]
    mov word[es:di],0x0720
    sub word[PB_POS],2
    sub di,[sizeofPaddles]
    sub di,[sizeofPaddles]
    mov word[es:di],0x7720
    endBL: popa
    ret

;moving Player B Rightward ----------
move_B_Right:
    pusha
    push cs
    pop ds
    mov ax,[sizeofPaddles]
    shl ax,1
    add ax,[PB_POS]
    cmp ax,4000
    je endBR 
    mov ax,0xb800
    mov es,ax
    mov di,[PB_POS]
    mov word[es:di],0x0720
    add word[PB_POS],2
    add di,[sizeofPaddles]
    add di,[sizeofPaddles]
    mov word[es:di],0x7720
    endBR: popa
    ret

printScore:
    push bp
    mov bp,sp
    push cs
    pop ds
    push word 0xb800
    pop es
    mov si,scorestr
    mov di,[bp+6]
    mov cx,7
    myloop:movsb
    inc di
    loop myloop
    mov al,[bp+4]
    add al,'0'
    mov byte[es:di],al
    pop bp
    ret 4


start:
    
    call initializeGame
    mov ax,0
    mov es,ax
    ;storing old timer isr
    mov ax,[es:8*4]
    mov [old_timer],ax
    mov ax,[es:8*4+2]
    mov [old_timer+2],ax
    ;storing old keyboard isr
    mov ax,[es:9*4]
    mov [old_kb],ax
    mov ax,[es:9*4+2]
    mov [old_kb+2],ax

    cli
    mov word[es:8*4],MY_TIMER_ISR
    mov word[es:8*4+2],cs
    mov word[es:9*4],MY_KB_ISR
    mov word[es:9*4+2],cs
    sti


labe: 
   
    cli
    cmp word[ScoreA],5
    je playerAwins
    cmp word[ScoreB],5
    je playerBwins
    sti
    jmp labe

playerAwins:


jmp end
playerBwins:


end:    
    
    call clrscr
    mov ax,[old_timer]
    mov word[es:8*4],ax
    mov ax,[old_timer+2]
    mov word[es:8*4+2],ax
    mov ax,[old_kb]
    mov word[es:9*4],ax
    mov ax,[old_kb+2]
    mov word[es:9*4+2],ax
    sti
    mov ax,0x4c00
    int 0x21

 
