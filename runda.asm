;; Krzysztof Gogolewski
;; 291538
;; programowanie w asemblerze, zad. 2

section .data
print:
  db `SUM = %d, CELL = %d, i = %d, m = %d,r = %d\n`,0
three:
  dd 3, 3, 3, 3
TRUE:
  dd 1, 1, 1, 1

section .text
  global runda
  %define _SZER (SZEROKOSC + 4)
  %define _DLUG (WYSOKOSC + 1)

runda: 

    push rbp
    mov rbp, rsp
    mov r13, rsi                    ;; r13 tablica z nowymi wartosciami
    mov r15, rdi                    ;; r15 aktualna plansza   

    movdqu xmm3, [three]            ;; wektor [3,3,3,3] do podejmowania decyzji
    movdqu xmm5, [TRUE]             ;; wektor [1,1,1,1] do podejmowania decyzji
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; pętla zewnętrzna po wierszach
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    mov r12, 1                      ;; i = 1
out_loop:
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; pętla wewnetrzna po kolumnach
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    mov rbx, 4                      ;; j = 1
in_loop:
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; jednocześnie dla czterech komórek
    ;; obliczamy sumę na polach sąsiednich
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    pxor xmm0, xmm0

    mov r9, qword [r15 + r12 * 8 - 8]  
    movdqu xmm0, [r9 + rbx * 4 - 4]
    
    movaps xmm1, [r9 + rbx * 4]
    paddq xmm0, xmm1

    movdqu xmm1, [r9 + rbx * 4 + 4]
    paddq xmm0, xmm1
  
    mov r9, qword [r15 + r12 * 8]
    movdqu xmm1, [r9 + rbx * 4 - 4] 
    paddq xmm0, xmm1
    
    movaps xmm2, [r9 + rbx * 4]     ;; aktualnie obliczane komórki do xmm2

    movdqu xmm1, [r9 + rbx * 4 + 4] 
    paddq xmm0, xmm1
 
    mov r9, qword [r15 + r12 * 8 + 8]  
    movdqu xmm1, [r9 + rbx * 4 - 4]
    paddq xmm0, xmm1

    movaps xmm1, [r9 + rbx * 4]
    paddq xmm0, xmm1

    movdqu xmm1, [r9 + rbx * 4 + 4]
    paddq xmm0, xmm1
 
    movdqu xmm4, xmm0

    ;;;;;;;;;;;;;;;;;;;;;;
    ;; podjecie decyzji
    ;;;;;;;;;;;;;;;;;;;;;;
    pcmpeqd xmm0, xmm3  ;; (A) suma == 3 
    paddq xmm4, xmm2    ;; suma += pole
    pcmpeqd xmm4, xmm3  ;; (B) suma == 3
    por xmm0, xmm4      ;; (A) or (B)
    pand xmm0, xmm5     ;; wynik: tylko pierwszy bit

    ;;;;;;;;;;;;;;;;;;;;;;
    ;; zapisanie wyniku
    ;;;;;;;;;;;;;;;;;;;;;;
    mov r9, qword [r13 + r12 * 8]
    movaps [r9 + rbx * 4], xmm0
  
    add rbx, 4           ;; j += 4
cond_in:
    cmp rbx, _SZER
    jl in_loop

    inc r12
cond_out:
    
    cmp r12, _DLUG
    jl out_loop
    
    pop rbp
    ret

