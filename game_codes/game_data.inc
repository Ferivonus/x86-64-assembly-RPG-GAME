; Filename: game_data.inc
; Description: Oyunun veri bölümü tanımlarını içerir.

section .data
    ; -------------------------------
    ; Renkli Mesaj Tanımları
    ; -------------------------------

    ; Hoş geldin mesajı (Yeşil)
    welcome_msg:
        db esc, "[32mFerivonus'un Sira Tabanli Savasi!", 10, 0

    ; ASCII-only kullanıcı adı sorusu (SARI)
    username_prompt:
        db esc, "[33mLutfen kullanici adinizi girin: ", 0

    ; scanf formatı: kullanıcı adı için (maksimum 31 karakter)
    username_fmt:
        db "%31s", 0

    ; Menü istemi: Camgöbeği
    menu_prompt_color:
        db esc, "[36m", 0       ; Camgöbeği renk kodu
    menu_prompt_text:
        db "Hamleni sec: 1 - Basit, 2 - Normal, 3 - Guclu: ", 0
    menu_prompt_reset:
        db esc, "[0m", 0        ; Renk sıfırlama

    ; scanf için saf format (sayı girdisi)
    input_fmt:
        db "%d", 0

    ; Kaçırma mesajı (Kırmızı)
    miss_msg:
        db esc, "[31mSaldiri bosa gitti!", 10, 0

    ; Oyuncu başarılı saldırı mesajı (Yeşil/Sarı/Yeşil)
    player_hit_msg:
        db esc, "[32mVurdun! ", esc, "[33mRakibe %d hasar verdin. ", esc, "[32mKalan dusman cani: %d", 10, 0

    ; Düşman saldırısı mesajı (Mor/Kırmızı/Mor)
    enemy_hit_msg:
        db esc, "[35mDusman vurdu! ", esc, "[31mSana %d hasar verdi. ", esc, "[35mKalan canin: %d", 10, 0

    ; Oyuncu kazandı mesajı (Yeşil)
    player_win_msg:
        db esc, "[32mTebrikler! Rakibi yendin!", 10, 0

    ; Oyuncu kaybetti mesajı (Kırmızı)
    player_lose_msg:
        db esc, "[31mOldun! Daha iyi sansla tekrar dene.", 10, 0

    ; Log dosyası adı
    log_filename:
        db "game_log.txt", 0

    ; Log format dizeleri (indeks ve parametre içerirler)
    log_play_start:
        db "Oyun Basladi. Kullanici: %s", 10, 0

    log_player_attack:
        db "%d. PLAYER -> Dusman: %d hasar, Dusman cani: %d", 10, 0
    log_player_miss:
        db "%d. PLAYER -> Dusmana saldirisa basari yok.", 10, 0
    log_enemy_attack:
        db "%d. DUSMAN -> Player: %d hasar, Player cani: %d", 10, 0
    log_enemy_miss:
        db "%d. DUSMAN -> Player hamlesi basarisiz.", 10, 0

    log_player_win:
        db "%d. PLAYER kazandi!", 10, 0
    log_player_lose:
        db "%d. PLAYER kaybetti!", 10, 0

    ; Yardımcı stringler
    str_w:        db "w", 0

section .bss
    username            resb 32             ; 31 karakter + null
    action_choice       resd 1              ; 32-bit int
    player_health       resd 1              ; Player HP
    enemy_health        resd 1              ; Enemy HP
    file_ptr            resq 1              ; FILE* pointer
    move_count          resd 1              ; Hamle indeksi