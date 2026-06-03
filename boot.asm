[BITS 16]
[ORG 0x7c00]

start:
    xor ax,ax
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov sp,0x7c00

; PrintWelcomeMessage:
;     mov ah,0x13
;     mov al,1
;     mov bx,0xa
;     xor dx,dx
;     mov bp, WelcomeMessage
;     mov cx, WelcomeMessageLen
;     int 0x10

TestDiskExtension:
    mov [DriveId], dl
    mov ah, 0x41
    mov bx, 0x55aa
    int 0x13
    jc NotSupport
    cmp bx, 0xaa55
    jne NotSupport

LoadLoader:
    ;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; offset    field
    ;   0       size
    ;   2       number of sectors
    ;   4       offset
    ;   6       segment
    ;   8       address lo
    ;  12       address hi 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov si, ReadPacket
    mov word[si], 0x10
    mov word[si+2], 5 ; 5 sectors space for the loader
    ; offsent and segment
    mov word[si+4], 0x7E00
    mov word[si+6], 0 
    ; Logic address: 0:0x7e00 = 0*16 + 0x7e00 = 0x7e00
    ; address lo and address hi (0000 0001)
    mov dword[si + 8], 1
    mov dword[si + 0xC], 0 ; 0xc == 12
    mov dl, [DriveId]
    mov ah, 0x42 ; function for disk extension service
    ; With all parameter sets we interupt the CPU
    int 0x13 ; interupt 
    jc ReadError; if it fails then carry flag is set and then jump

    ;load the loader file
    mov dl, [DriveId]
    jmp 0x7E00


ReadError:
NotSupport:
    mov ah,0x13
    mov al,1
    mov bx,0xa
    xor dx,dx
    mov bp, Message
    mov cx, MessageLen
    int 0x10

End:
    hlt
    jmp End

DriveId:    db 0
WelcomeMessage:     db "Hello and Welcome"
WelcomeMessageLen:  equ $-WelcomeMessage
Message:    db "We have error in boot process"
MessageLen: equ $-Message
ReadPacket: times 16 db 0

times (0x1be-($-$$)) db 0

    db 80h
    db 0,2,0
    db 0f0h
    db 0ffh,0ffh,0ffh
    dd 1
    dd (20*16*63-1)

    times (16*3) db 0

    db 0x55
    db 0xaa


