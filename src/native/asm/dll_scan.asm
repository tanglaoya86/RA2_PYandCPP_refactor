default rel

extern printf
extern ExitProcess

%define PEB_LDR_DATA_OFFSET		0x18
%define IN_LOAD_ORDER_MODULE_LIST_OFFSET 0x10
%define LDR_BASE_DLL_NAME_OFFSET	0x58
%define LDR_DLL_BASE_OFFSET		0x30
%define LDR_SIZE_OF_IMAGE_OFFSET	0x40
%define LDR_FULL_DLL_NAME_OFFSET	0x48

section .bss
    buffer:	 resb 520
    found_base:  resq 1


section .data
    ;VT100
    col_reset:	    db 0x1B, "[0m", 0
    col_green:	    db 0x1B, "[32m", 0
    col_red:	    db 0x1B, "[31m", 0
    col_yellow:     db 0x1B, "[33m", 0
    col_cyan:	    db 0x1B, "[36m", 0
    col_white:	    db 0x1B, "[97m", 0

    fmt_banner:     db 0x1B, "[36m"
		    db "", 13, 10
		    db "dll_checker", 13, 10
		    db ""
		    db 0x1B, "[0m", 13, 10, 0

    fmt_mod_header: db 13, 10
		    db 0x1B, "[97m"
		    db "                                          --- Loaded Modules ---", 13, 10
		    db "  #   Base Address        Size       Name"
		    db 0x1B, "[0m", 13, 10
		    db "----------------------------------------------------------------", 13, 10, 0

    fmt_mod_entry:  db " %2u   0x%016llX  %08X  %s", 13, 10, 0

    fmt_scan_start: db 13, 10
		    db 0x1B, "[97m"
		    db "                                          --- Target DLL Scan ---"
		    db 0x1B, "[0m", 13, 10, 0

    fmt_detected:   db 0x1B, "[32m[+]%s ", 0x1B, "[0m"
		    db "%-35s ", 0x1B, "[33mDETECTED", 0x1B, "[0m"
		    db "  (Base: 0x%016llX", 13, 10
		    db "   Path: %s)", 13, 10, 0

    fmt_not_found:  db 0x1B, "[31m[-]%s ", 0x1B, "[0m"
		    db "%-35s ", 0x1B, "[31mNOT FOUND", 0x1B, "[0m", 13, 10, 0

    fmt_summary:    db 13, 10
		    db 0x1B, "[97m"
		    db "=== Summary ===", 13, 10
		    db "Detected: %u / Missing: %u", 13, 10
		    db 0x1B, "[0m", 0

    ; -- 目标 DLL 列表（以双 NULL 结束）你可以自己加--
    target_dlls:
	db "vcruntime140.dll",0
	db "vcruntime140_1.dll",0
	db "msvcp140.dll",0
	db "msvcp140_1.dll",0
	db "msvcp140_2.dll",0
	db "concrt140.dll",0
	db "ucrtbase.dll",0
	db "python3.dll",0
	db "python310.dll",0
	db "python311.dll",0
	db "python312.dll",0
	db "libcrypto-3-x64.dll",0
	db "libssl-3-x64.dll",0
	db "sqlite3.dll",0
	db "tcl86t.dll",0
	db "tk86t.dll",0
	db "libffi-8.dll",0
	db "zlib1.dll",0
	db "libbz2.dll",0
	db "liblzma.dll",0
	db "mkl_rt.dll",0
	db "mkl_core.dll",0
	db "mkl_avx2.dll",0
	db "mkl_def.dll",0
	db "mkl_vml_avx2.dll",0
	db "mkl_vml_def.dll",0
	db "libiomp5md.dll",0
	db "libopenblas.dll",0
	db "libgfortran-5.dll",0
	db "libquadmath-0.dll",0
	db "libjpeg-9.dll",0
	db "libpng16-16.dll",0
	db "libtiff-5.dll",0
	db "libwebp-7.dll",0
	db "libwebpmux-3.dll",0
	db "libwebpdemux-2.dll",0
	db "libopenjp2.dll",0
	db "liblerc.dll",0
	db "libfreetype-6.dll",0
	db "libharfbuzz-0.dll",0
	db "libfribidi-0.dll",0
	db "libbrotlicommon.dll",0
	db "libbrotlidec.dll",0
	db "avcodec-60.dll",0
	db "avformat-60.dll",0
	db "avutil-58.dll",0
	db "swresample-4.dll",0
	db "swscale-7.dll",0
	db "avdevice-60.dll",0
	db "postproc-57.dll",0
	db "libtheoradec-1.dll",0
	db "libvorbis-0.dll",0
	db "libvorbisfile-3.dll",0
	db "libvorbisenc-2.dll",0
	db "libogg-0.dll",0
	db "libopus-0.dll",0
	db "libopusfile-0.dll",0
	db "libmp3lame-0.dll",0
	db "libmpg123-0.dll",0
	db "libflac-8.dll",0
	db "libsndfile-1.dll",0
	db "OpenAL32.dll",0
	db "libfluidsynth-2.dll",0
	db "libgme.dll",0
	db "libmodplug-1.dll",0
	db "SDL2.dll",0
	db "SDL2_image.dll",0
	db "SDL2_mixer.dll",0
	db "SDL2_ttf.dll",0
	db "SDL2_net.dll",0
	db "glew32.dll",0
	db "freeglut.dll",0
	db "glut32.dll",0
	db "glfw3.dll",0
	db "pygame_ce.base.dll",0
	db "pygame_ce.math.dll",0
	db "pygame_ce.image.dll",0
	db "pygame_ce.mixer.dll",0
	db "pygame_ce.music.dll",0
	db "pygame_ce.transform.dll",0
	db "pygame_ce.draw.dll",0
	db "pygame_ce.display.dll",0
	db "pygame_ce.event.dll",0
	db "pygame_ce.key.dll",0
	db "pygame_ce.mouse.dll",0
	db "pygame_ce.surface.dll",0
	db "pygame_ce.font.dll",0
	db "pygame_ce.pixelarray.dll",0
	db "pygame_ce._sdl2.dll",0
	db "pygame_ce._sprite.dll",0
	db "pygame_ce.scrap.dll",0
	db "pygame_ce.rect.dll",0
	db "pygame_ce.color.dll",0
	db "pygame_ce.rwobject.dll",0
	db "pygame_ce.time.dll",0
	db "pygame_ce.joystick.dll",0
	db "pygame_ce.overlay.dll",0
	db "pygame_ce.fastevent.dll",0
	db "pygame_ce._camera.dll",0
	db "pygame_ce._freetype.dll",0
	db "pygame_ce.mask.dll",0
	db "pygame_ce._sdl2.audio.dll",0
	db "pygame_ce._sdl2.controller.dll",0
	db "pygame_ce._sdl2.touch.dll",0
	db "pygame_ce._sdl2.video.dll",0
	db "pygame_ce._sdl2.misc.dll",0
	db "avbin.dll",0
	db "libopenal-1.dll",0
	db "libopenal32.dll",0
	db "libp3framework.dll",0
	db "libpanda.dll",0
	db "libpandaexpress.dll",0
	db "libp3dtool.dll",0
	db "libp3dtoolconfig.dll",0
	db "libp3interrogatedb.dll",0
	db "libp3direct.dll",0
	db "libp3egg.dll",0
	db "libp3net.dll",0
	db "libp3audiotraits.dll",0
	db "libp3vision.dll",0
	db "libp3display.dll",0
	db "libp3pgraph.dll",0
	db "libp3grutil.dll",0
	db "libp3gsgbase.dll",0
	db "libp3gobj.dll",0
	db "libp3parametrics.dll",0
	db "libp3collide.dll",0
	db "libp3dgraph.dll",0
	db "libp3chan.dll",0
	db "libp3char.dll",0
	db "libp3audio.dll",0
	db "libp3movies.dll",0
	db "libp3physx.dll",0
	db "libp3bullet.dll",0
	db "libp3ode.dll",0
	db "libp3recorder.dll",0
	db "libp3fx.dll",0
	db "libp3text.dll",0
	db "libp3procedural.dll",0
	db "libp3render.dll",0
	db "libp3softimages.dll",0
	db "libp3tinydisplay.dll",0
	db "libp3dgui.dll",0
	db "libp3tiff.dll",0
	db "libp3gl.dll",0
	db "libpnmimage.dll",0
	db "libp3windisplay.dll",0
	db "libp3ffmpeg.dll",0
	db "libp3fftw.dll",0
	db "libp3vorbis.dll",0
	db "libp3openal.dll",0
	db "sdl2.dll",0
	db "SDL2_gfx.dll",0
	db "opengl32.dll",0
	db "glu32.dll",0
	db "libcurl-4.dll",0
	db "libmysql.dll",0
	db "libpq.dll",0
	db "libxml2-2.dll",0
	db "libxslt-1.dll",0
	db "iconv-2.dll",0
	db "libexslt-0.dll",0
	db "pythoncom310.dll",0
	db "pywintypes310.dll",0
	db 0		   ; 列表结束

section .text
global main

stricmp:
    push    rbx
    push    rsi
    push    rdi
    mov     rsi, rcx
    mov     rdi, rdx
.loop:
    movzx   eax, byte [rsi]
    movzx   ebx, byte [rdi]
    cmp     al, 'A'
    jb	    .s1
    cmp     al, 'Z'
    ja	    .s1
    add     al, 0x20
.s1:
    cmp     bl, 'A'
    jb	    .s2
    cmp     bl, 'Z'
    ja	    .s2
    add     bl, 0x20
.s2:
    cmp     al, bl
    jne     .done
    test    al, al
    jz	    .done
    inc     rsi
    inc     rdi
    jmp     .loop
.done:
    sub     eax, ebx
    pop     rdi
    pop     rsi
    pop     rbx
    ret

uni2ascii:
    push    rdi
    mov     rdi, rdx
.copy:
    mov     al, byte [rcx]
    mov     byte [rdi], al
    add     rcx, 2
    inc     rdi
    sub     r8d, 2
    jnz     .copy
    mov     byte [rdi], 0
    pop     rdi
    ret

FindDll:
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbx
    sub     rsp, 0x48
    mov     r12, rcx			
    xor     eax, eax
    mov     [found_base], rax		

    xor     eax, eax
    mov     rax, [gs:rax + 0x60]
    mov     rax, [rax + PEB_LDR_DATA_OFFSET]
    mov     r13, [rax + IN_LOAD_ORDER_MODULE_LIST_OFFSET]   
    mov     r14, r13			
.next_entry:
    mov     r15, [r14]			
    cmp     r15, r13
    je	    .not_found
    mov     r14, r15			
    lea     rbx, [r14 + LDR_BASE_DLL_NAME_OFFSET]
    movzx   ecx, word [rbx]		
    test    cx, cx
    jz	    .next_entry
    cmp     cx, 520
    jbe     .len_ok
    mov     cx, 520
.len_ok:
    mov     rcx, [rbx + 8]		
    lea     rdx, [buffer]
    mov     r8d, ecx
    call    uni2ascii
    lea     rcx, [buffer]
    mov     rdx, r12
    call    stricmp
    test    eax, eax
    jnz     .next_entry
    mov     rax, [r14 + LDR_DLL_BASE_OFFSET]
    mov     [found_base], rax
    lea     rbx, [r14 + LDR_FULL_DLL_NAME_OFFSET]
    movzx   ecx, word [rbx]
    test    cx, cx
    jz	    .no_path
    cmp     cx, 520
    jbe     .plen_ok
    mov     cx, 520
.plen_ok:
    mov     rcx, [rbx + 8]
    lea     rdx, [buffer]
    mov     r8d, ecx
    call    uni2ascii
    jmp     .done
.no_path:
    mov     byte [buffer], 0
.done:
    mov     rax, [found_base]
    jmp     .ret
.not_found:
    xor     eax, eax
    mov     [found_base], rax
    mov     byte [buffer], 0
.ret:
    add     rsp, 0x48
    pop     rbx
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    ret


strlen:
    push    rdi
    mov     rdi, rcx
    xor     al, al
    mov     rcx, -1
    repne scasb
    not     rcx
    dec     rcx
    mov     rax, rcx
    pop     rdi
    ret


EnumerateModules:
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbx
    sub     rsp, 0x48
    lea     rcx, [fmt_mod_header]
    call    printf
    xor     eax, eax
    mov     rax, [gs:rax + 0x60]
    mov     rax, [rax + PEB_LDR_DATA_OFFSET]
    mov     r12, [rax + IN_LOAD_ORDER_MODULE_LIST_OFFSET]
    mov     r13, r12
    xor     r15d, r15d			 
.next_mod:
    mov     r14, [r13]
    cmp     r14, r12
    je	    .done
    mov     r13, r14
    mov     rcx, [r13 + LDR_DLL_BASE_OFFSET]
    test    rcx, rcx
    jz	    .next_mod
    mov     rbx, rcx
    mov     edx, [r13 + LDR_SIZE_OF_IMAGE_OFFSET]
    lea     r8, [r13 + LDR_BASE_DLL_NAME_OFFSET]
    movzx   r9d, word [r8]
    test    r9w, r9w
    jz	    .next_mod
    cmp     r9w, 260
    jbe     .name_ok
    mov     r9w, 260
.name_ok:
    mov     rcx, [r8 + 8]
    lea     rdx, [buffer]
    mov     r8d, r9d
    call    uni2ascii
    inc     r15d
    lea     rcx, [fmt_mod_entry]
    mov     edx, r15d			
    mov     r8, rbx			 ; Base
    mov     r9d, [r13 + LDR_SIZE_OF_IMAGE_OFFSET] ; Size
    lea     r10, [buffer]		
    sub     rsp, 32
    call    printf
    add     rsp, 32
    jmp     .next_mod
.done:
    add     rsp, 0x48
    pop     rbx
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    ret


main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 0x60

    ; 打印横幅
    lea     rcx, [fmt_banner]
    call    printf

    ; 枚举模块
    call    EnumerateModules

    ; 开始目标扫描
    lea     rcx, [fmt_scan_start]
    call    printf
    lea     r12, [target_dlls]
    xor     r14d, r14d			 ; 检测到计数器
    xor     r15d, r15d			 ; 缺失计数器

.scan_loop:
    cmp     byte [r12], 0
    je	    .show_summary
    ; 查找 DLL
    mov     rcx, r12
    call    FindDll
    test    rax, rax
    jz	    .not_loaded
    inc     r14d
    lea     rcx, [fmt_detected]
    ; 实际参数：第一个 %s 是空字符串为了补足格式  格式为 "[+]%s %-35s DETECTED ..."
    ; fmt_detected:  db 0x1B, "[32m[+]%s ", 0x1B, "[0m"
    ;		      db "%-35s ", 0x1B, "[33mDETECTED", 0x1B, "[0m"
    ;		      db "  (Base: 0x%016llX", 13, 10
    ;		      db "   Path: %s)", 13, 10, 0
    ; 期望: %s (颜色后的空填充), %s (名称), %016llX (基址), %s (路径)
    ; 第一个 %s 可以传一个空字符串，以便让 "[+]" 后面紧接 DLL 名称。
    ; 我传 "" 作为第一个参数，名称作为第二个，基址作为第三个，路径作为第四个。
    lea     rdx, [empty_str]	
    mov     r8, r12
    mov     r9, [found_base]
    lea     r10, [buffer]
    sub     rsp, 32
    call    printf
    add     rsp, 32
    jmp     .next_target
.not_loaded:
    inc     r15d
    lea     rcx, [fmt_not_found]

    lea     rdx, [empty_str]
    mov     r8, r12
    sub     rsp, 32
    call    printf
    add     rsp, 32
.next_target:

    mov     rcx, r12
    call    strlen
    lea     r12, [r12 + rax + 1]
    jmp     .scan_loop

.show_summary:
    lea     rcx, [fmt_summary]
    mov     edx, r14d
    mov     r8d, r15d
    call    printf

.exit:
    xor     ecx, ecx
    call    ExitProcess

section .data
    empty_str: db 0
