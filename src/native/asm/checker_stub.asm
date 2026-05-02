bits 64              ;log:伪指令以消除16进制下错误 <Auror>
default rel
global checker_entry

section .text
checker_entry:
    push   rbx
    push   rsi
    push   rdi
    push   rbp
    sub    rsp, 0x28
    mov    rbp, rcx

    xor    eax, eax
    mov    rax, gs:[rax + 0x60]
    mov    al, [rax + 0x2]
    test   al, al
    jnz    .debugged

    lea    rcx, [rel mon_path]
    mov    edx, 0x80000000
    or     edx, 3
    xor    r8d, r8d
    xor    r9d, r9d
    mov    rax, [rbp + 0]
    call   rax
    cmp    rax, -1
    je     .fail

    mov    rbx, rax
    mov    rcx, rax
    xor    edx, edx
    mov    rax, [rbp + 16]
    call   rax
    mov    rsi, rax
    mov    rcx, 0
    mov    rdx, rsi
    mov    r8, 0x3000
    mov    r9, 0x04
    mov    rax, [rbp + 8]
    call   rax
    test   rax, rax
    jz     .fail
    mov    rdi, rax
    mov    rcx, rbx
    mov    rdx, rdi
    mov    r8, rsi
    xor    r9, r9
    mov    rax, [rbp + 24]
    call   rax
    test   eax, eax
    jz     .fail

    mov    rcx, rdi
    mov    rdx, rsi
    mov    r8, [rbp + 32]
    mov    rax, [rbp + 40]
    call   rax
    test   al, al
    jz     .fail

    mov    rcx, rbx
    mov    rax, [rbp + 48]
    call   rax
    mov    eax, 0
    jmp    .clean

.debugged:
    mov    ecx, 0xC0000009
    mov    rax, [rbp + 56]
    mov    rdx, [rbp + 64]
    call   rax

.fail:
    mov    eax, 1

.clean:
    add    rsp, 0x28
    pop    rbp
    pop    rdi
    pop    rsi
    pop    rbx
    ret

section .rdata
mon_path:   db 'monitor.exe', 0
