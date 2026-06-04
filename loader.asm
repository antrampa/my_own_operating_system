[BITS 16]
[ORG 0x7E00]

start:
    mov [DriveId], dl
    
    ;Welcome Message
    mov ah, 0x13        ; function 13h = write string
    mov al, 1
    mov bx, 0xc
    ;mov dh, 0
    ;mov dl, 5
    mov dx, 0x0000 ; ; row 0, col 5
    mov bp, WelcomeMessage
    mov cx, WelcomeMessageLen
    int 0x10            ; call BIOS video service

    mov eax, 0x80000000 ; ask: "what's the highest extended leaf you support?"
    cpuid
    cmp eax, 0x80000001 ; do you support at least leaf 0x80000001?
    jb NotSupport

    mov eax, 0x80000001 ; ask: "what are your extended feature flags?"
    cpuid               ; edx/ecx filled with feature bits
    test edx, (1<<29)   ; bit 29 = Long Mode (64-bit support)
    jz NotSupport

    test edx, (1<<26)   ; bit 26 = 1GB pages support
    jz NotSupport


    mov ah, 0x13        ; function 13h = write string
    mov al, 1
    mov bx, 0xa
    ;xor dx, dx ; row 0, col 0
    mov dx, 0x0100      ; row 1, col 0
    mov bp, Message
    mov cx, MessageLen
    int 0x10            ; call BIOS video service

NotSupport:
End:
    hlt
    jmp End

DriveId:            db 0
WelcomeMessage:     db "!!! Welcome to our Custom OS !!!"
WelcomeMessageLen:  equ $-WelcomeMessage 
Message:            db "Long mode is supported"
MessageLen:         equ $-Message






