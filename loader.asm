[BITS 16]
[ORG 0x7E00]


start:
    ;Welcome Message
    mov ah, 0x13
    mov al, 1
    mov bx, 0xc
    ;mov dh, 0
    ;mov dl, 5
    mov dx, 0x0000 ; ; row 0, col 5
    mov bp, WelcomeMessage
    mov cx, WelcomeMessageLen
    int 0x10

    mov ah, 0x13
    mov al, 1
    mov bx, 0xa
    ;xor dx, dx ; row 0, col 0
    mov dx, 0x0100 ; ; row 1, col 0
    mov bp, Message
    mov cx, MessageLen
    int 0x10
End:
    hlt
    jmp End

WelcomeMessage:     db "!!! Welcome to our Custom OS !!!"
WelcomeMessageLen:  equ $-WelcomeMessage 
Message:    db "Loader starts"
MessageLen: equ $-Message






