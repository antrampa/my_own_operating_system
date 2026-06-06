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

GetMemInfoStart:
    mov eax, 0xE820         ; BIOS function (Query System Address Map) memory map (INT 0x15, EAX=0xE820 interface)
    mov edx, 0x534D4150
    mov ecx, 20             ; Requests 20 bytes per memory entry
    mov edi, 0x9000         ; Points EDI to where the BIOS should write the memory entry
    xor ebx, ebx            ; ebx = 0 -> start from the first entry
    int 0x15                ; memory map (INT 0x15, EAX=0xE820 interface)
    jc NotSupport

GetMemInfo:
    add edi, 10
    mov eax, 0xE820
    mov edx, 0x534D4150
    mov ecx, 20
    int 0x15
    jc GetMemDone

    test ebx, ebx
    jnz GetMemInfo


; Print GetMemDone
GetMemDone:
    mov ah, 0x13        ; function 13h = write string
    mov al, 1
    mov bx, 0xa
    ;xor dx, dx ; row 0, col 0
    mov dx, 0x0300      ; row 3, col 0
    mov bp, MemDoneMessage
    mov cx, MemDoneMessageLen
    int 0x10           

TestA20Line:
    mov ax, 0xFFFF
    mov es, ax
    mov word[ds:0x7C00], 0xA200     ; 0 : 0x7C00 = 0x16 + 0x7C00 = 0x7C00
    mov word[es:0X7C10], 0XA200     ; 0xFFFF : 0x7C10 = 0xFFFF x 16 + 0x7C10 = 0x107C00 -> A20 line is Enable otherwise is Disabled 
    jne SetA20LineDone         
    ; A second test to be sure
    mov word[0x7C00], 0xB200
    cmp word[es:0x7C10], 0XB200
    je End                          ; A-20 Line is disabled. Maximum memory support = 1MB :(

SetA20LineDone:
    xor ax, ax      ; Init values ax = es = 0;
    mov es, ax

    mov ah, 0x13        ; function 13h = write string
    mov al, 1
    mov bx, 0xd
    mov dx, 0x0400      ; row 4, col 0
    mov bp, A20LineMessage
    mov cx, A20LineMessageLen
    int 0x10    

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
MemDoneMessage:     db "Get Memeory info done"
MemDoneMessageLen:  equ $-MemDoneMessage
A20LineMessage:     db "A-20 Line is enable"
A20LineMessageLen:  equ $-A20LineMessage
ReadPacket:         times 16 db 0






