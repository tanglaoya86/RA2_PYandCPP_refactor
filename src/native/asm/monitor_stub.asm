bits 64              ;log:伪指令以消除16进制下错误 <Auror>
default rel
global monitor_entry

section .text
monitor_entry:
    push   r12
    push   r13
    push   r14
    push   r15
    sub    rsp, 0x38
    mov    r15, rcx

    lea    rcx, [rel mod_name]
    mov    rax, [r15 + 8]
    call   rax
    test   rax, rax
    jz     .over
    mov    r12, rax

    mov    rcx, rax
    lea    rdx, [rel func_name]
    mov    rax, [r15 + 24]
    call   rax
    test   rax, rax
    jz     .over
    mov    r13, rax

    mov    rcx, r13
    mov    dl, byte [rel patch_len]
    mov    r8, 0x40
    mov    rax, [r15 + 40]
    call   rax

    lea    rdx, [rel trampoline]
    sub    rdx, r13
    sub    rdx, 5
    mov    byte [r13], 0xE9
    mov    dword [r13+1], edx

.over:
    xor    eax, eax
    add    rsp, 0x38
    pop    r15
    pop    r14
    pop    r13
    pop    r12
    ret

trampoline:
    push   rcx
    mov    rcx, rsp
    add    rcx, 8

    pop    rcx
    jmp    [r15 + 48]     ; 回调原始  请勿修改

section .rdata
mod_name:   db 'ntdll.dll', 0
func_name:  db 'NtQuerySystemInformation', 0
patch_len:  db 5
