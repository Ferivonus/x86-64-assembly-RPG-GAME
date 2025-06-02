; Filename: game_logic.asm
; Description: Oyun döngüsü ve tur yönetimi.

default rel

; Ortak sabitleri ve verileri dahil et
%include "constants.inc"
%include "game_data.inc" ; game_data.inc'i dahil ettik, bu etiketler artık global olarak erişilebilir

; Harici fonksiyon bildirimleri
extern printf
extern scanf

; ui.asm'den
extern display_menu_prompt
extern display_player_win_msg
extern display_player_lose_msg

; combat.asm'den
extern handle_player_attack_logic
extern handle_enemy_attack_logic

; file_io.asm'den
; log_player_win ve log_player_lose etiketleri game_data.inc'de tanımlı olduğu için BURADAN KALDIRILIYOR.
; extern log_player_win ; Bu satırı kaldırdık
; extern log_player_lose ; Bu satırı kaldırdık

; Global tanımlamalar
global game_loop_start

section .text

; game_loop_start
; RCX: file_ptr (QWORD)
; RDX: player_health adresi (QWORD)
; R8: enemy_health adresi (QWORD)
; R9: move_count adresi (QWORD)
game_loop_start:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32 ; Shadow space

    ; Parametreleri kaydet (yerel değişkenler gibi davranabilir)
    mov     qword [rbp + 48], rcx ; file_ptr
    mov     qword [rbp + 56], rdx ; player_health_ptr
    mov     qword [rbp + 64], r8  ; enemy_health_ptr
    mov     qword [rbp + 72], r9  ; move_count_ptr

.battle_loop:
    ; Oyuncu canı kontrol
    mov     r10, qword [rbp + 56] ; player_health_ptr
    mov     eax, dword [r10]      ; player_health
    test    eax, eax
    jle     .player_lose_game

    ; Düşman canı kontrol
    mov     r10, qword [rbp + 64] ; enemy_health_ptr
    mov     eax, dword [r10]      ; enemy_health
    test    eax, eax
    jle     .player_win_game

    ; Oyuncu menü istemini göster (ui.asm)
    call    display_menu_prompt

    ; Kullanıcıdan seçim al
    lea     rcx, [input_fmt]
    lea     rdx, [action_choice]
    call    scanf

    ; Hamleyi işle
    mov     eax, [action_choice]
    cmp     eax, 1
    je      .player_turn_basic
    cmp     eax, 2
    je      .player_turn_normal
    cmp     eax, 3
    je      .player_turn_strong
    jmp     .battle_loop ; Geçersiz giriş, tekrar sor

.player_turn_basic:
    ; RCX: file_ptr, RDX: player_health_ptr, R8: enemy_health_ptr, R9: move_count_ptr
    ; Yığındaki diğer parametreler: hit_chance, min_dmg, max_dmg (combat.asm için)
    push    basic_max_dmg
    push    basic_min_dmg
    push    basic_hit_chance
    call    handle_player_attack_logic
    add     rsp, 3*8 ; Yığına itilen 3 DWORD için alanı geri al (3*4 = 12 bayt, 8 bayt hizalama için 24 yapalım)
                     ; Aslında burada 3 DWORDS için 3*4 = 12 byte pop yapılmalı.
                     ; Ancak, Windows x64'te her yığın parametresi 8 bayta hizalanır.
                     ; Bu yüzden 3*8 = 24 bayt eklemeliyiz.
    jmp     .enemy_turn

.player_turn_normal:
    push    normal_max_dmg
    push    normal_min_dmg
    push    normal_hit_chance
    call    handle_player_attack_logic
    add     rsp, 3*8
    jmp     .enemy_turn

.player_turn_strong:
    ; Güçlü saldırının ek parametreleri var: min_pct, max_pct, min_flat_dmg
    push    strong_min_flat_dmg
    push    strong_max_pct
    push    strong_min_pct
    push    strong_hit_chance ; strong_hit_chance de itiliyor
    call    handle_player_attack_logic
    add     rsp, 4*8 ; 4 DWORD için 4*8 = 32 bayt
    jmp     .enemy_turn

.enemy_turn:
    ; Düşman canı kontrolü, eğer oyuncu düşmanı yendiyse tur atla
    mov     r10, qword [rbp + 64] ; enemy_health_ptr
    mov     eax, dword [r10]      ; enemy_health
    test    eax, eax
    jle     .player_win_game ; Düşman yenildi, oyuncu kazandı

    ; Düşman saldırısını işle
    ; RCX: file_ptr, RDX: player_health_ptr, R8: enemy_health_ptr, R9: move_count_ptr
    push    enemy_max_dmg
    push    enemy_min_dmg
    push    enemy_hit_chance
    call    handle_enemy_attack_logic
    add     rsp, 3*8
    jmp     .battle_loop

.player_win_game:
    ; Oyuncu kazandı mesajını göster (ui.asm)
    call    display_player_win_msg

    ; Oyuncu kazandı logunu yaz (file_io.asm)
    mov     rcx, qword [rbp + 48] ; file_ptr
    mov     rdx, qword [rbp + 72] ; move_count_ptr
    call    log_player_win ; Bu bir fonksiyonsa, extern olması gerekir. Eğer veri ise, direkt kullanılır.
    jmp     .game_end_logic

.player_lose_game:
    ; Oyuncu kaybetti mesajını göster (ui.asm)
    call    display_player_lose_msg

    ; Oyuncu kaybetti logunu yaz (file_io.asm)
    mov     rcx, qword [rbp + 48] ; file_ptr
    mov     rdx, qword [rbp + 72] ; move_count_ptr
    call    log_player_lose ; Bu bir fonksiyonsa, extern olması gerekir. Eğer veri ise, direkt kullanılır.
    jmp     .game_end_logic

.game_end_logic:
    add     rsp, 32 ; Shadow space'i geri al
    pop     rbp
    ret