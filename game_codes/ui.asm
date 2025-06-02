; Filename: ui.asm
; Description: Kullanıcı arayüzü çıktıları ve girdi istemleri.

default rel

; Ortak sabitleri ve verileri dahil et
%include "constants.inc"
%include "game_data.inc"

; Harici fonksiyon bildirimleri
extern printf

; Global tanımlamalar
global display_menu_prompt
global display_miss_msg
global display_player_hit_msg
global display_enemy_hit_msg
global display_player_win_msg
global display_player_lose_msg

section .text

display_menu_prompt:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32 ; Shadow space

    lea     rcx, [menu_prompt_color]
    call    printf
    lea     rcx, [menu_prompt_text]
    call    printf
    lea     rcx, [menu_prompt_reset]
    call    printf

    add     rsp, 32
    pop     rbp
    ret

display_miss_msg:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32 ; Shadow space

    lea     rcx, [miss_msg]
    call    printf

    add     rsp, 32
    pop     rbp
    ret

; display_player_hit_msg
; RCX: damage (int)
; RDX: enemy_health (int)
display_player_hit_msg:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32 ; Shadow space

    ; printf(player_hit_msg, damage, enemy_health)
    lea     rcx, [player_hit_msg]
    mov     edx, dword [rbp + 48] ; damage (yığından)
    mov     r8d, dword [rbp + 56] ; enemy_health (yığından)
    call    printf

    add     rsp, 32
    pop     rbp
    ret

; display_enemy_hit_msg
; RCX: damage (int)
; RDX: player_health (int)
display_enemy_hit_msg:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32 ; Shadow space

    ; printf(enemy_hit_msg, damage, player_health)
    lea     rcx, [enemy_hit_msg]
    mov     edx, dword [rbp + 48] ; damage (yığından)
    mov     r8d, dword [rbp + 56] ; player_health (yığından)
    call    printf

    add     rsp, 32
    pop     rbp
    ret

display_player_win_msg:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32 ; Shadow space

    lea     rcx, [player_win_msg]
    call    printf

    add     rsp, 32
    pop     rbp
    ret

display_player_lose_msg:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32 ; Shadow space

    lea     rcx, [player_lose_msg]
    call    printf

    add     rsp, 32
    pop     rbp
    ret