; Filename: combat.asm
; Description: Saldırı hesaplamaları ve can güncellemeleri.

default rel

; Ortak sabitleri ve verileri dahil et
%include "constants.inc"
%include "game_data.inc"

; Harici fonksiyon bildirimleri
extern rand

; ui.asm'den
extern display_miss_msg
extern display_player_hit_msg
extern display_enemy_hit_msg

; file_io.asm'den
extern log_player_attack_event
extern log_player_miss_event
extern log_enemy_attack_event
extern log_enemy_miss_event

; Global tanımlamalar
global handle_player_attack_logic
global handle_enemy_attack_logic

section .text

; handle_player_attack_logic
; RCX: file_ptr (QWORD)
; RDX: player_health_ptr (QWORD)
; R8: enemy_health_ptr (QWORD)
; R9: move_count_ptr (QWORD)
; Yığındaki parametreler (sağdan sola):
; [RSP + 32]: hit_chance (INT)
; [RSP + 40]: min_dmg (INT)  / strong_min_pct (INT)
; [RSP + 48]: max_dmg (INT)  / strong_max_pct (INT)
; [RSP + 56]: strong_min_flat_dmg (INT, sadece güçlü saldırı için)
handle_player_attack_logic:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32 ; Shadow space

    ; Parametreleri yerel kaydet
    mov     qword [rbp - 8], rcx  ; file_ptr
    mov     qword [rbp - 16], rdx ; player_health_ptr
    mov     qword [rbp - 24], r8  ; enemy_health_ptr
    mov     qword [rbp - 32], r9  ; move_count_ptr

    ; move_count'ı artır
    mov     r10, qword [rbp - 32] ; move_count_ptr
    mov     eax, dword [r10]
    inc     eax
    mov     dword [r10], eax
    mov     edi, eax              ; edi = move_count (loglama için)

    ; Yığından parametreleri doğru şekilde oku
    mov     eax, dword [rbp + 32]   ; hit_chance (1. yığın parametresi)
    mov     ebx, dword [rbp + 40]   ; min_dmg / strong_min_pct (2. yığın parametresi)
    mov     ecx, dword [rbp + 48]   ; max_dmg / strong_max_pct (3. yığın parametresi)
    mov     edx, dword [rbp + 56]   ; strong_min_flat_dmg (4. yığın parametresi - sadece güçlü için)

    ; Rand ile isabet şansı hesapla
    push    rax ; rand'a geçmeden önce RAX'ı koru (parametre geçmeden önce EAX'ın değerini kullanacağız)
    call    rand
    pop     rax ; RAX'ı geri yükle (current_hit_chance)
    xor     edx, edx
    mov     edi, 100
    div     edi             ; edx = rand() % 100
    cmp     edx, eax        ; edx'i (rand sonucu) current_hit_chance ile karşılaştır
    jae     .player_miss_logic ; Eğer kaçarsa .player_miss_logic'e git

    ; Saldırı türüne göre hasar hesapla
    ; current_hit_chance (EAX) kullanılarak saldırı tipi belirleniyor
    cmp     eax, basic_hit_chance
    je      .calculate_basic_normal_damage

    cmp     eax, normal_hit_chance
    je      .calculate_basic_normal_damage

    cmp     eax, strong_hit_chance
    je      .calculate_strong_damage

    ; Varsayılan olarak hata durumu veya başka bir saldırı
    jmp     .player_miss_logic ; Bilinmeyen saldırı tipi, kaçırma say

.calculate_basic_normal_damage:
    ; Normal min/max hasar hesaplaması
    mov     r12d, ebx ; min_dmg (current_min_dmg)
    mov     r13d, ecx ; max_dmg (current_max_dmg)

    call    rand
    xor     edx, edx
    sub     r13d, r12d
    inc     r13d
    mov     edi, r13d
    div     edi             ; edx = rand() % (range_size)
    add     edx, r12d       ; damage = (rand() % range_size) + min_dmg
    mov     esi, edx        ; esi = damage
    jmp     .damage_calculated

.calculate_strong_damage:
    ; Güçlü saldırı: yüzdeye dayalı hasar
    mov     r12d, ebx ; strong_min_pct (current_min_dmg)
    mov     r13d, ecx ; strong_max_pct (current_max_dmg)
    mov     r14d, edx ; strong_min_flat_dmg (current_strong_min_flat_dmg)

    call    rand
    xor     edx, edx
    sub     r13d, r12d
    inc     r13d
    mov     edi, r13d
    div     edi             ; edx = rand() % (pct_range_size)
    add     edx, r12d       ; edx = random percentage

    mov     r10, qword [rbp - 24] ; enemy_health_ptr
    mov     eax, dword [r10]      ; enemy_health
    imul    eax, edx              ; eax = enemy_health * percentage
    mov     edi, 100
    xor     edx, edx              ; Clear edx for div
    div     edi                   ; eax = (enemy_health * percentage) / 100

    cmp     eax, r14d             ; Compare with strong_min_flat_dmg
    jge     .strong_damage_ok
    mov     eax, r14d             ; Ensure minimum flat damage
.strong_damage_ok:
    mov     esi, eax              ; esi = final damage

.damage_calculated:
    ; Düşman sağlığını güncelle
    mov     r10, qword [rbp - 24] ; enemy_health_ptr
    mov     eax, dword [r10]
    sub     eax, esi
    jns     .player_no_underflow
    xor     eax, eax
.player_no_underflow:
    mov     dword [r10], eax      ; enemy_health'i güncelle
    mov     ebx, eax              ; ebx = yeni düşman canı (log ve display için)

    ; Log player attack (file_io.asm)
    mov     rcx, qword [rbp - 8]  ; file_ptr
    mov     edx, edi              ; move_count (32-bit)
    mov     r8d, esi              ; damage (32-bit)
    mov     r9d, ebx              ; enemy_health_after_dmg (32-bit)
    call    log_player_attack_event

    ; Display player hit message (ui.asm)
    ; RCX: damage, RDX: enemy_health (ui.asm için)
    mov     ecx, esi              ; damage (32-bit)
    mov     edx, ebx              ; enemy_health (32-bit)
    call    display_player_hit_msg

    jmp     .player_attack_end

.player_miss_logic:
    ; Display miss message (ui.asm)
    call    display_miss_msg

    ; Log player miss (file_io.asm)
    mov     rcx, qword [rbp - 8]  ; file_ptr
    mov     edx, edi              ; move_count (32-bit)
    call    log_player_miss_event

.player_attack_end:
    add     rsp, 32
    pop     rbp
    ret

; handle_enemy_attack_logic
; RCX: file_ptr (QWORD)
; RDX: player_health_ptr (QWORD)
; R8: enemy_health_ptr (QWORD)
; R9: move_count_ptr (QWORD)
; Yığındaki parametreler (sağdan sola):
; [RSP + 32]: hit_chance (INT)
; [RSP + 40]: min_dmg (INT)
; [RSP + 48]: max_dmg (INT)
handle_enemy_attack_logic:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32 ; Shadow space

    ; Parametreleri yerel kaydet
    mov     qword [rbp - 8], rcx  ; file_ptr
    mov     qword [rbp - 16], rdx ; player_health_ptr
    mov     qword [rbp - 24], r8  ; enemy_health_ptr
    mov     qword [rbp - 32], r9  ; move_count_ptr

    ; move_count'ı artır
    mov     r10, qword [rbp - 32] ; move_count_ptr
    mov     eax, dword [r10]
    inc     eax
    mov     dword [r10], eax
    mov     edi, eax              ; edi = move_count

    ; Yığından parametreleri doğru şekilde oku
    mov     ebx, dword [rbp + 32]   ; hit_chance (1. yığın parametresi)
    mov     ecx, dword [rbp + 40]   ; min_dmg (2. yığın parametresi)
    mov     edx, dword [rbp + 48]   ; max_dmg (3. yığın parametresi)

    call    rand
    xor     edx, edx
    mov     edi, 100
    div     edi             ; edx = rand() % 100
    cmp     edx, ebx        ; edx'i (rand sonucu) current_hit_chance ile karşılaştır
    jae     .enemy_miss_logic ; Eğer kaçarsa .enemy_miss_logic'e git

    ; Hasar hesapla
    mov     r12d, ecx ; min_dmg (current_min_dmg)
    mov     r13d, edx ; max_dmg (current_max_dmg)

    call    rand
    xor     edx, edx
    sub     r13d, r12d
    inc     r13d
    mov     edi, r13d
    div     edi             ; edx = rand() % (range_size)
    add     edx, r12d       ; damage = (rand() % range_size) + min_dmg
    mov     esi, edx        ; esi = damage

    ; Oyuncu sağlığını güncelle
    mov     r10, qword [rbp - 16] ; player_health_ptr
    mov     eax, dword [r10]
    sub     eax, esi
    jns     .enemy_no_underflow
    xor     eax, eax
.enemy_no_underflow:
    mov     dword [r10], eax      ; player_health'i güncelle
    mov     ebx, eax              ; ebx = yeni oyuncu canı

    ; Log enemy attack (file_io.asm)
    mov     rcx, qword [rbp - 8]  ; file_ptr
    mov     edx, edi              ; move_count (32-bit)
    mov     r8d, esi              ; damage (32-bit)
    mov     r9d, ebx              ; player_health_after_dmg (32-bit)
    call    log_enemy_attack_event

    ; Display enemy hit message (ui.asm)
    ; RCX: damage, RDX: player_health (ui.asm için)
    mov     ecx, esi              ; damage (32-bit)
    mov     edx, ebx              ; player_health (32-bit)
    call    display_enemy_hit_msg

    jmp     .enemy_attack_end

.enemy_miss_logic:
    ; Log enemy miss (file_io.asm)
    mov     rcx, qword [rbp - 8]  ; file_ptr
    mov     edx, edi              ; move_count (32-bit)
    call    log_enemy_miss_event

.enemy_attack_end:
    add     rsp, 32
    pop     rbp
    ret