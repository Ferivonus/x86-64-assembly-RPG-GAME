; Filename: main.asm
; Description: Basit sıra tabanlı dövüş oyunu (Windows x64, NASM)
; Ana program akışı ve yüksek seviye kontrol.

default rel

; Ortak sabitleri ve verileri dahil et
%include "./game_codes/constants.inc"
%include "./game_codes/game_data.inc"

; Harici fonksiyon bildirimleri
extern printf
extern scanf
extern exit
extern rand ; Sadece main içinde çağrılıyorsa burada olmalı, diğer türlü combat.asm'de yeterli.
extern fopen
extern fclose
extern fprintf

; game_logic.asm'den
extern game_loop_start

global main

section .text

main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32 ; Shadow space

    ; Dosya işlemlerini başlat (log dosyasını aç vb.)
    ; Bu çağrı file_io.asm içindeki bir fonksiyona yönlendirilebilir.
    ; Şimdilik, sadece main içinde dosyayı açalım ve diğer loglama işlemleri için file_ptr'ı iletelim.
    lea     rcx, [log_filename]
    lea     rdx, [str_w]
    call    fopen
    mov     [file_ptr], rax ; FILE* kaydet
    test    rax, rax
    jz      .file_error

    ; Kullanıcı adı al (ui.asm tarafından işlenmeli)
    lea     rcx, [username_prompt]
    call    printf

    lea     rcx, [username_fmt]
    lea     rdx, [username]
    call    scanf

    ; Log dosyasına oyun başlangıç mesajını yaz (file_io.asm tarafından işlenmeli)
    mov     rcx, [file_ptr]
    lea     rdx, [log_play_start]
    lea     r8,  [username]
    call    fprintf

    ; Başlangıç değerlerini ayarla (game_data.inc'de tanımlanmış)
    mov     dword [player_health], INITIAL_PLAYER_HEALTH
    mov     dword [enemy_health], INITIAL_ENEMY_HEALTH
    mov     dword [move_count], 0

    ; Hoş geldin mesajını göster (ui.asm tarafından işlenmeli)
    lea     rcx, [welcome_msg]
    call    printf

    ; Ana oyun döngüsüne geçiş
    ; Parametreler: file_ptr, player_health adresi, enemy_health adresi, move_count adresi
    mov     rcx, [file_ptr]         ; RCX = file_ptr
    lea     rdx, [player_health]    ; RDX = player_health adresi
    lea     r8, [enemy_health]      ; R8 = enemy_health adresi
    lea     r9, [move_count]        ; R9 = move_count adresi
    call    game_loop_start

    ; Oyun bitişi: Temizleme ve çıkış

.file_error:
    ; Dosya açma hatası durumunda temiz çıkış
    mov     rcx, 1 ; Hata kodu 1
    call    exit

.game_end:
    ; Log dosyasını kapat (file_io.asm tarafından işlenmeli)
    mov     rcx, [file_ptr]
    test    rcx, rcx
    jz      .skip_fclose
    call    fclose
.skip_fclose:

    ; Programdan çık
    mov     rsp, rbp
    pop     rbp
    xor     eax, eax ; Return 0
    call    exit