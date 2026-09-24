option casemap:none

extrn GetStdHandle : PROC
extrn WriteConsoleA : PROC
extrn WriteFile : PROC
extrn GetAsyncKeyState : PROC
extrn Sleep : PROC
extrn Intersect : PROC

.data
refresh_cooldown equ 100

VK_ESCAPE equ 1Bh 
STD_OUTPUT_HANDLE equ -11

clsSeq  db 1Bh, "[2J", 1Bh, "[3J", 1Bh, "[H"
clsLen equ $ - clsSeq
                                                                                                                                                                                                                        
screenH equ 32   
screenW equ 64
rowLen equ screenW + 1

ALIGN 16                                                                                                                                                           
tri REAL4 -2.0, -2.0, 2.0, 0.0                                                                                                                                                                            
    REAL4  0.0,  2.0, 2.0, 0.0                                                                                                                                                                           
    REAL4  2.0, -2.0, 2.0, 0.0

ALIGN 16
ray REAL4 0.0, 0.0, -2.0, 0.0
    REAL4 0.0, 0.0,  1.0, 0.0
 
ZERO     REAL4 0.0
HALF     REAL4 0.5
ONE_F    REAL4 1.0S
PX_SCALE REAL4 0.03125
PY_SCALE REAL4 0.0625S
                       
screen LABEL BYTE
REPT screenH
    db screenW dup('.'), 0Ah
ENDM
screenLen equ rowLen * screenH               

.code

;void asm_print(const char* str, int64_t _length);
asm_print PROC
    push rbx
    push rsi
    sub rsp, 56
    mov rbx, rcx
    mov rsi, rdx

    mov ecx, STD_OUTPUT_HANDLE
    call GetStdHandle
    
    mov rcx, rax  ;arg1
    mov rdx, rbx  ;arg2
    mov r8d, esi  ;arg3
    lea r9,  [rsp + 40] ;arg4 - local variable pointer
    mov QWORD PTR [rsp + 32], 0 ;arg5
    call WriteFile

    add rsp, 56
    pop rsi
    pop rbx
    ret

asm_print ENDP

asm_clear PROC
    lea rcx, clsSeq
    mov edx, clsLen
    jmp asm_print
asm_clear ENDP

;int asm_is_key_down(int _keyCode)
asm_is_key_down PROC
    sub rsp, 40
    call GetAsyncKeyState
    shr eax, 15
    and eax, 1
    add rsp, 40
    ret
asm_is_key_down ENDP
  
Render PROC
    push rbx ; y
    push rsi ; x
    push rdi ; screen pointer 
    sub  rsp, 32

    lea rdi, screen
    xor ebx, ebx
h_loop:
    cvtsi2ss xmm0, ebx
    addss    xmm0, HALF
    mulss    xmm0, PY_SCALE
    movss    xmm1, ONE_F
    subss    xmm1, xmm0
    movss    DWORD PTR [ray + 20], xmm1

    xor esi, esi   
w_loop:
    cvtsi2ss xmm0, esi
    addss    xmm0, HALF
    mulss    xmm0, PX_SCALE
    subss    xmm0, ONE_F
    movss    DWORD PTR [ray + 16], xmm0

    lea rcx, tri
    lea rdx, ray
    call Intersect

    movss xmm1, ZERO
    mov   al, '.'
    comiss xmm0, xmm1
    jb store
    mov al, '#'
store:
    mov [rdi], al
    inc rdi

    inc esi
    cmp esi, screenW
    jl w_loop
    
    inc rdi
    inc ebx
    cmp ebx, screenH
    jl h_loop

    add rsp, 32
    pop rdi
    pop rsi
    pop rbx
    ret
Render ENDP

Draw PROC
    sub rsp, 40
    call asm_clear
    lea rcx, screen
    mov edx, screenLen
    call asm_print
    add rsp, 40
    ret
Draw ENDP
  
Run PROC   
    
run_loop:
    sub rsp, 40
    mov rcx, refresh_cooldown
    call Sleep
    call Render 
    call Draw
    mov rcx, VK_ESCAPE
    call asm_is_key_down    
    add rsp, 40

    cmp rax, 1
    jne run_loop
done:
    ret
Run ENDP

END