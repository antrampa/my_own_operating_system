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

    ; Print Load Mode Message
    mov ah, 0x13        ; function 13h = write string
    mov al, 1
    mov bx, 0xa
    ;xor dx, dx ; row 0, col 0
    mov dx, 0x0100      ; row 1, col 0
    mov bp, Message
    mov cx, MessageLen
    int 0x10            ; call BIOS video service

LoadKernel:
    mov si, ReadPacket
    mov word[si], 0x10
    mov word[si+2], 100 
    mov word[si+4], 0
    mov word[si+6], 0x1000 
    ; Logic address: 0:0x1000 = 0*16 + 0x1000 = 0x1000
    ; address lo and address hi (0000 0001)
    mov dword[si + 8], 6
    mov dword[si + 0xC], 0 ; 0xc == 12
    mov dl, [DriveId]
    mov ah, 0x42 ; function for disk extension service
    int 0x13 ; interupt 
    jc ReadError; if it fails then carry flag is set and then jump

    ; Print KernelMessage
    mov ah, 0x13        ; function 13h = write string
    mov al, 1
    mov bx, 0xd
    ;xor dx, dx ; row 0, col 0
    mov dx, 0x0200      ; row 2, col 0
    mov bp, KernelMessage
    mov cx, KernelMessageLen
    int 0x10            ; call BIOS video service

ReadError:
NotSupport:
End:
    hlt
    jmp End

DriveId:            db 0
WelcomeMessage:     db "!!! Welcome to our Custom OS !!!"
WelcomeMessageLen:  equ $-WelcomeMessage 
Message:            db "Long mode is supported"
MessageLen:         equ $-Message
KernelMessage:      db "Kernel is loaded"
KernelMessageLen:   equ $-KernelMessage
ReadPacket:         times 16 db 0






