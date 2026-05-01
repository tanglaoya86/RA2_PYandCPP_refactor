;[time 2026-5-01-21:47 to 22:15]
;Auther:@Auror
;Purpose:Process protection
;Name:Process_protection

;以后写代码按照我这个排版来阐述代码信息

extern GetStdHandle
extern WriteFile
extern GetCommandLineA
extern OpenProcess
extern VirtualProtectEx
extern VirtualProtect
extern CloseHandle
extern GetLastError
extern ExitProcess

STD_OUTPUT_HANDLE    equ -11
PROCESS_VM_OPERATION equ 0x0008
FALSE                equ 0

PAGE_NOACCESS           equ 0x01
PAGE_READONLY           equ 0x02
PAGE_READWRITE          equ 0x04
PAGE_WRITECOPY          equ 0x08
PAGE_EXECUTE            equ 0x10
PAGE_EXECUTE_READ       equ 0x20
PAGE_EXECUTE_READWRITE  equ 0x40
PAGE_EXECUTE_WRITECOPY  equ 0x80
PAGE_GUARD              equ 0x100
PAGE_NOCACHE            equ 0x200
PAGE_WRITECOMBINE       equ 0x400

section .data
    hStdOut      dq 0
    oldProtect   dd 0
    newProtect   dd PAGE_READONLY
    targetPid    dd 0
    targetAddr   dq 0
    targetSize   dq 0
    hProcess     dq 0
    isSelf       dd 0

    msgUsage     db "Usage: memguard.exe <pid> <addr> <size> [protection]", 0x0D, 0x0A
                 db "  pid: 0 for self, or target process ID", 0x0D, 0x0A
                 db "  addr: hex address (e.g. 0x400000)", 0x0D, 0x0A
                 db "  size: hex size (e.g. 0x1000)", 0x0D, 0x0A
                 db "  protection: R=READONLY (default), N=NOACCESS, G=GUARD", 0x0D, 0x0A
    lenUsage     equ $ - msgUsage

    msgOpenFail  db "OpenProcess failed. Error: "
    lenOpenFail  equ $ - msgOpenFail

    msgProtectOk db "Memory protection applied.", 0x0D, 0x0A, "Old: "
    lenProtectOk equ $ - msgProtectOk

    msgProtectFail db "VirtualProtect failed. Error: "
    lenProtectFail equ $ - msgProtectFail

    msgSelfNote  db " (self)", 0x0D, 0x0A
    lenSelfNote  equ $ - msgSelfNote

    msgNewLine   db 0x0D, 0x0A
    lenNewLine   equ $ - msgNewLine

    hexDigits    db "0123456789ABCDEF"

section .bss
    errorBuf     resb 16
    hexBuf       resb 32

section .text
    global main

main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 128

    mov     ecx, STD_OUTPUT_HANDLE
    call    GetStdHandle
    mov     [rel hStdOut], rax

    call    GetCommandLineA
    mov     rcx, rax
    call    skip_program_name
    mov     r12, rax
    test    r12, r12
    jz      .usage

    mov     rcx, r12
    call    atou
    cmp     eax, 0
    jne     .remote_process
    mov     dword [rel isSelf], 1
    mov     dword [rel targetPid], 0
    jmp     .skip_pid

.remote_process:
    mov     [rel targetPid], eax
    mov     dword [rel isSelf], 0
.skip_pid:
    mov     rcx, r12
    call    find_next_arg
    mov     r12, rax
    test    r12, r12
    jz      .usage

    mov     rcx, r12
    call    atox
    mov     [rel targetAddr], rax
    mov     rcx, r12
    call    find_next_arg
    mov     r12, rax
    test    r12, r12
    jz      .usage

    mov     rcx, r12
    call    atox
    mov     [rel targetSize], rax

    mov     rcx, r12
    call    find_next_arg
    test    rax, rax
    jz      .use_default_protection
    mov     r12, rax
    mov     al, byte [r12]
    cmp     al, 'N'
    je      .set_noaccess
    cmp     al, 'G'
    je      .set_guard
    cmp     al, 'R'
    je      .use_default_protection
    jmp     .use_default_protection

.set_noaccess:
    mov     dword [rel newProtect], PAGE_NOACCESS
    jmp     .apply_protection
.set_guard:
    mov     dword [rel newProtect], PAGE_GUARD
    jmp     .apply_protection
.use_default_protection:
    mov     dword [rel newProtect], PAGE_READONLY

.apply_protection:
    cmp     dword [rel isSelf], 0
    jne     .protect_self

    mov     ecx, PROCESS_VM_OPERATION
    xor     edx, edx
    mov     r8d, [rel targetPid]
    call    OpenProcess
    test    rax, rax
    jz      .open_fail
    mov     [rel hProcess], rax

    mov     rcx, rax
    mov     rdx, [rel targetAddr]
    mov     r8, [rel targetSize]
    mov     r9d, [rel newProtect]
    lea     rax, [rel oldProtect]
    mov     [rsp + 32], rax
    call    VirtualProtectEx
    test    eax, eax
    jz      .protect_fail

    mov     rcx, [rel hProcess]
    call    CloseHandle
    jmp     .report_success

.protect_self:
    mov     rcx, [rel targetAddr]
    mov     rdx, [rel targetSize]
    mov     r8d, [rel newProtect]
    lea     r9, [rel oldProtect]
    call    VirtualProtect
    test    eax, eax
    jz      .protect_self_fail

.report_success:
    mov     rcx, [rel hStdOut]
    lea     rdx, [rel msgProtectOk]
    mov     r8, lenProtectOk
    xor     r9d, r9d
    mov     qword [rsp + 32], 0
    call    WriteFile

    mov     eax, [rel oldProtect]
    lea     rdx, [rel hexBuf]
    call    print_hex32
    mov     rcx, [rel hStdOut]
    mov     r8, 8
    xor     r9d, r9d
    mov     qword [rsp + 32], 0
    call    WriteFile

    cmp     dword [rel isSelf], 0
    je      .newline_done
    mov     rcx, [rel hStdOut]
    lea     rdx, [rel msgSelfNote]
    mov     r8, lenSelfNote
    xor     r9d, r9d
    mov     qword [rsp + 32], 0
    call    WriteFile
    jmp     .newline_done

.newline_done:
    jmp     .done

.protect_self_fail:
    call    GetLastError
    mov     rcx, [rel hStdOut]
    lea     rdx, [rel msgProtectFail]
    mov     r8, lenProtectFail
    xor     r9d, r9d
    mov     qword [rsp + 32], 0
    call    WriteFile
    lea     rdx, [rel errorBuf]
    mov     ecx, eax
    call    print_dec
    mov     rcx, [rel hStdOut]
    lea     rdx, [rel errorBuf]
    mov     r8, 10
    xor     r9d, r9d
    mov     qword [rsp + 32], 0
    call    WriteFile
    jmp     .done

.protect_fail:
    push    rax
    call    GetLastError
    mov     r12d, eax
    pop     rax
    mov     rcx, [rel hProcess]
    call    CloseHandle
    mov     rcx, [rel hStdOut]
    lea     rdx, [rel msgProtectFail]
    mov     r8, lenProtectFail
    xor     r9d, r9d
    mov     qword [rsp + 32], 0
    call    WriteFile
    mov     ecx, r12d
    lea     rdx, [rel errorBuf]
    call    print_dec
    mov     rcx, [rel hStdOut]
    lea     rdx, [rel errorBuf]
    mov     r8, 10
    xor     r9d, r9d
    mov     qword [rsp + 32], 0
    call    WriteFile
    jmp     .done

.open_fail:
    call    GetLastError
    mov     r12d, eax
    mov     rcx, [rel hStdOut]
    lea     rdx, [rel msgOpenFail]
    mov     r8, lenOpenFail
    xor     r9d, r9d
    mov     qword [rsp + 32], 0
    call    WriteFile
    mov     ecx, r12d
    lea     rdx, [rel errorBuf]
    call    print_dec
    mov     rcx, [rel hStdOut]
    mov     r8, 10
    xor     r9d, r9d
    mov     qword [rsp + 32], 0
    call    WriteFile
    jmp     .done

.usage:
    mov     rcx, [rel hStdOut]
    lea     rdx, [rel msgUsage]
    mov     r8, lenUsage
    xor     r9d, r9d
    mov     qword [rsp + 32], 0
    call    WriteFile

.done:
    xor     ecx, ecx
    call    ExitProcess
    leave
    ret

skip_program_name:
    push    rbx
    mov     rbx, rcx
.skip_quote:
    cmp     byte [rbx], 0x22
    jne     .skip_blank
    inc     rbx
.scan_quote:
    cmp     byte [rbx], 0
    je      .end_null
    cmp     byte [rbx], 0x22
    jne     .next_quote
    inc     rbx
    jmp     .skip_blank
.next_quote:
    inc     rbx
    jmp     .scan_quote
.skip_blank:
    cmp     byte [rbx], 0x20
    ja      .found_start
    cmp     byte [rbx], 0
    je      .end_null
    inc     rbx
    jmp     .skip_blank
.found_start:
    cmp     byte [rbx], 0
    je      .end_null
    mov     rax, rbx
    pop     rbx
    ret
.end_null:
    xor     eax, eax
    pop     rbx
    ret

find_next_arg:
    push    rbx
    mov     rbx, rcx
.skip_blank:
    cmp     byte [rbx], 0x20
    ja      .advance_arg
    cmp     byte [rbx], 0
    je      .end_arg
    inc     rbx
    jmp     .skip_blank
.advance_arg:
    cmp     byte [rbx], 0x20
    jbe     .blank_found
    cmp     byte [rbx], 0
    je      .end_arg
    inc     rbx
    jmp     .advance_arg
.blank_found:
    inc     rbx
.skip_blanks:
    cmp     byte [rbx], 0x20
    ja      .next_arg_found
    cmp     byte [rbx], 0
    je      .end_arg
    inc     rbx
    jmp     .skip_blanks
.next_arg_found:
    mov     rax, rbx
    pop     rbx
    ret
.end_arg:
    xor     eax, eax
    pop     rbx
    ret

atou:
    xor     eax, eax
    xor     edx, edx
.next_digit:
    movzx   edx, byte [rcx]
    test    dl, dl
    jz      .done
    cmp     dl, '0'
    jb      .done
    cmp     dl, '9'
    ja      .done
    sub     dl, '0'
    imul    eax, 10
    add     eax, edx
    inc     rcx
    jmp     .next_digit
.done:
    ret

atox:
    xor     eax, eax
    xor     edx, edx
    cmp     word [rcx], '0x'
    je      .skip_prefix
    cmp     word [rcx], '0X'
    je      .skip_prefix
    jmp     .next_xdigit
.skip_prefix:
    add     rcx, 2
.next_xdigit:
    movzx   edx, byte [rcx]
    test    dl, dl
    jz      .done_x
    cmp     dl, '0'
    jb      .done_x
    cmp     dl, '9'
    jbe     .decimal_x
    cmp     dl, 'A'
    jb      .done_x
    cmp     dl, 'F'
    jbe     .upper_x
    cmp     dl, 'a'
    jb      .done_x
    cmp     dl, 'f'
    jbe     .lower_x
    jmp     .done_x
.decimal_x:
    sub     dl, '0'
    jmp     .accumulate
.upper_x:
    sub     dl, 'A' - 10
    jmp     .accumulate
.lower_x:
    sub     dl, 'a' - 10
.accumulate:
    shl     rax, 4
    or      rax, rdx
    inc     rcx
    jmp     .next_xdigit
.done_x:
    ret

print_dec:
    push    rdi
    push    rbx
    mov     rdi, rdx
    mov     ebx, ecx
    mov     ecx, 10
    mov     eax, ebx
    xor     edx, edx
    add     rdi, 9
    mov     byte [rdi], 0
    dec     rdi
    std
.next_dec:
    xor     edx, edx
    div     ecx
    xchg    eax, edx
    add     al, '0'
    stosb
    xchg    eax, edx
    test    eax, eax
    jnz     .next_dec
    cld
    inc     rdi
    mov     rdx, rdi
    pop     rbx
    pop     rdi
    ret

print_hex32:
    push    rdi
    push    rbx
    mov     rdi, rdx
    mov     ebx, eax
    mov     ecx, 8
    add     rdi, 7
    std
.next_hex:
    mov     eax, ebx
    and     eax, 0xF
    lea     rax, [rel hexDigits + rax]
    mov     al, byte [rax]
    stosb
    shr     ebx, 4
    loop    .next_hex
    cld
    inc     rdi
    mov     rdx, rdi
    pop     rbx
    pop     rdi
    ret
