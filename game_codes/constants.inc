; Filename: constants.inc
; Description: Oyun sabitlerini ve makroları içerir.

; ------------------------------
; Sabitler (equ)
; ------------------------------
basic_hit_chance    equ 90      ; Basit saldırı: %90 isabet
basic_min_dmg       equ 10      ; Basit saldırı: minimum 10
basic_max_dmg       equ 20      ; Basit saldırı: maksimum 20

normal_hit_chance   equ 75      ; Normal saldırı: %75 isabet
normal_min_dmg      equ 20      ; Normal saldırı: minimum 20
normal_max_dmg      equ 30      ; Normal saldırı: maksimum 30

strong_hit_chance   equ 50      ; Güçlü saldırı: %50 isabet
strong_min_pct      equ 30      ; Güçlü saldırı: minimum %30
strong_max_pct      equ 50      ; Güçlü saldırı: maksimum %50
strong_min_flat_dmg equ 10      ; Güçlü saldırı: en az 10 sabit hasar

enemy_hit_chance    equ 80      ; Düşman saldırısı: %80 isabet
enemy_min_dmg       equ 5       ; Düşman saldırısı: minimum 5
enemy_max_dmg       equ 15      ; Düşman saldırısı: maksimum 15

INITIAL_PLAYER_HEALTH equ 100   ; Oyuncu başlangıç canı
INITIAL_ENEMY_HEALTH equ 100    ; Düşman başlangıç canı

; ------------------------------
; ANSI Renk Kodları
; ------------------------------
esc                 equ 0x1b    ; Escape karakteri