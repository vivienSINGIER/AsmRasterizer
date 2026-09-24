
.const 
EPS  REAL4 0.000001                                                                                                                                                                                                               
ZERO REAL4 0.0                                                                                                                                                                                                                    
ONE  REAL4 1.0                                                                                                                                                                                                                    
NEG1 REAL4 -1.0 

.code

VectAdd PROC
    addps xmm0, xmm1
    ret
VectAdd ENDP

VectSub PROC
    subps xmm0, xmm1
    ret
VectSub ENDP

Cross PROC
    movaps xmm2, xmm0
    shufps xmm2, xmm2, 0C9h
    movaps xmm3, xmm1
    shufps xmm3, xmm3, 0C9h
    
    mulps xmm0, xmm3
    mulps xmm2, xmm1
    subps xmm0, xmm2

    shufps xmm0, xmm0, 0C9h
    ret
Cross ENDP

Dot PROC
    dpps xmm0, xmm1, 71h
    ret
Dot ENDP

Abs PROC 
    mov   eax, 7FFFFFFFh
    movd  xmm1, eax
    andps xmm0, xmm1
    ret
Abs ENDP

Inv PROC
    mov    eax, 3f800000h
    movd   xmm1, eax
    divss  xmm1, xmm0
    movaps xmm0, xmm1
    ret
Inv ENDP

Intersect PROC
    sub rsp, 32 + 16 * 7 + 8
    movaps [rsp + 32],  xmm6                                                                                                                                                                                                      
    movaps [rsp + 48],  xmm7                                                                                                                                                                                                      
    movaps [rsp + 64],  xmm8                                                                                                                                                                                                      
    movaps [rsp + 80],  xmm9                                                                                                                                                                                                      
    movaps [rsp + 96],  xmm10                                                                                                                                                                                                     
    movaps [rsp + 112], xmm11                                                                                                                                                                                                     
    movaps [rsp + 128], xmm12

    movaps xmm6, XMMWORD PTR [rcx]      ;Vertex A
    movaps xmm7, XMMWORD PTR [rcx + 16] ;Vertex B
    movaps xmm8, XMMWORD PTR [rcx + 32] ;Vertex C

    movaps xmm9,  XMMWORD PTR [rdx]      ;Ray orgin
    movaps xmm10, XMMWORD PTR [rdx + 16] ;Ray dir
    
    movaps xmm0, xmm7
    movaps xmm1, xmm6
    call VectSub
    movaps xmm7, xmm0 ; e1 = v1 - v0 

    movaps xmm0, xmm8
    movaps xmm1, xmm6
    call VectSub
    movaps xmm8, xmm0 ; e2 = v2 - v0

    movaps xmm0, xmm10
    movaps xmm1, xmm8
    call Cross
    movaps xmm12, xmm0 ; p = cross(dir, e2)

    movaps xmm0, xmm7
    movaps xmm1, xmm12
    call Dot
    movaps xmm11, xmm0 ; det = dot(e1, p)
    
    comiss xmm11, EPS
    jb   miss ; ray is parallel to the triangle

    movaps xmm0, xmm11
    call Inv
    movaps xmm11, xmm0 ; inv = 1 / det

    movaps xmm0, xmm9
    movaps xmm1, xmm6
    call VectSub
    movaps xmm6, xmm0 ; s = origin - v0

    movaps xmm0, xmm6
    movaps xmm1, xmm12
    call Dot
    movaps xmm12, xmm0
    mulps  xmm12, xmm11 ; u = dot(s, p) * inv 

    comiss xmm12, ZERO
    jb     miss
    comiss xmm12, ONE
    ja     miss

    movaps xmm0, xmm6
    movaps xmm1, xmm7
    call Cross
    movaps xmm6, xmm0 ; q = cross(s, e1)

    movaps xmm0, xmm10
    movaps xmm1, xmm6
    call Dot
    movaps xmm7, xmm0
    mulps xmm7, xmm11 ; v = dot(dir, q) * inv

    comiss xmm7, ZERO
    jb     miss
    movaps xmm0, xmm12
    addss  xmm0, xmm7
    comiss xmm0, ONE
    ja     miss ; if v < 0 or u + v > 1: return MISS

    movaps xmm0, xmm8
    movaps xmm1, xmm6
    call Dot
    mulps xmm0, xmm11 ; t = dot(e2, q) * inv

    comiss xmm0, EPS ; t                                                                                                                                                                 
    jbe    miss

    jmp done

miss:
    movss xmm0, NEG1

done:
    movaps xmm6,  [rsp + 32]                                                                                                                                               
    movaps xmm7,  [rsp + 48]                                                                                                                                                                                                      
    movaps xmm8,  [rsp + 64]                                                                                                                                                                                                      
    movaps xmm9,  [rsp + 80]                                                                                                                                                                                                      
    movaps xmm10, [rsp + 96]                                                                                                                                                                                                      
    movaps xmm11, [rsp + 112]                                                                                                                                                                                                     
    movaps xmm12, [rsp + 128]
    add rsp, 32 + 16 * 7 + 8
    ret
Intersect ENDP

END