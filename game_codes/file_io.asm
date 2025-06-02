; Filename: file_io.asm
; Description: Dosya işlemleri (loglama).

default rel

; Ortak sabitleri ve verileri dahil et
%include "constants.inc"
%include "game_data.inc" ; Log format string'leri buradan geliyor

; Harici fonksiyon bildirimleri
extern fprintf

; Global tanımlamalar
global log_player_attack_event
global log_player_miss_event
global log_enemy_attack_event
global log_enemy_miss_event
global log_game_win_event
global log_game_lose_event

section .text

; log_player_attack_event
; RCX: file_ptr (QWORD)
; RDX: move_count (INT)
; R8: damage (INT)
; R9: enemy_health_after_dmg (INT)
log_player_attack_event:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32 ; Shadow space

    ; Düzeltme: 32-bit değeri 32-bit'lik yığın konumuna taşıyoruz.
    mov     dword [rsp + 32], r9d ; 5. arg (enemy_health_after_dmg) yığına
    
    mov     r9d, r8d              ; 4. arg (damage)
    mov     r8d, edx              ; 3. arg (move_count)
    mov     rdx, log_player_attack ; 2. arg (format string)

    call    fprintf

    add     rsp, 32
    pop     rbp
    ret

; log_player_miss_event
; RCX: file_ptr (QWORD)
; RDX: move_count (INT)
log_player_miss_event:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32 ; Shadow space

    mov     r8d, edx              ; 3. arg (move_count)
    mov     rdx, log_player_miss ; 2. arg (format string)

    call    fprintf

    add     rsp, 32
    pop     rbp
    ret

; log_enemy_attack_event
; RCX: file_ptr (QWORD)
; RDX: move_count (INT)
; R8: damage (INT)
; R9: player_health_after_dmg (INT)
log_enemy_attack_event:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32 ; Shadow space

    ; Düzeltme: 32-bit değeri 32-bit'lik yığın konumuna taşıyoruz.
    mov     dword [rsp + 32], r9d ; 5. arg (player_health_after_dmg) yığına
    
    mov     r9d, r8d              ; 4. arg (damage)
    mov     r8d, edx              ; 3. arg (move_count)
    mov     rdx, log_enemy_attack ; 2. arg (format string)

    call    fprintf

    add     rsp, 32
    pop     rbp
    ret

; log_enemy_miss_event
; RCX: file_ptr (QWORD)
; RDX: move_count (INT)
log_enemy_miss_event:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32 ; Shadow space

    mov     r8d, edx              ; 3. arg (move_count)
    mov     rdx, log_enemy_miss ; 2. arg (format string)

    call    fprintf

    add     rsp, 32
    pop     rbp
    ret

; log_game_win_event
; RCX: file_ptr (QWORD)
; RDX: move_count (INT)
log_game_win_event:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32 ; Shadow space

    mov     r8d, edx              ; 3. arg (move_count)
    mov     rdx, log_player_win ; format string

    call    fprintf

    add     rsp, 32
    pop     rbp
    ret

; log_game_lose_event
; RCX: file_ptr (QWORD)
; RDX: move_count (INT)
log_game_lose_event:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32 ; Shadow space

    mov     r8d, edx              ; 3. arg (move_count)
    mov     rdx, log_player_lose ; format string

    call    fprintf

    add     rsp, 32
    pop     rbp
    ret