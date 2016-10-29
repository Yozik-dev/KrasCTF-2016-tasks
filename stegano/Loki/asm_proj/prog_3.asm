.386
.model flat,stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc

includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib

WinMain proto :DWORD, :DWORD, :DWORD, :DWORD
Control proto :DWORD, :DWORD, :DWORD
Comp proto :DWORD, :DWORD


.DATA

    AppName db "Crack_Me", 0 
    
    WindowClassName db "window", 0
    ButtonClassName db "button", 0
    EditClassName db "edit", 0
    LabelClassName db "static", 0
    
    LabelText_1 db "Your name:", 0
    LabelText_2 db "Serial num:", 0
    
    ButtonText db "Check!", 0
    
    text db "text", 0
    
    interest db 0eeh, 0d8h, 0c2h, 097h, 0d6h, 0c5h, 0d2h, 097h, 097h, 0d6h
             db 097h, 0d0h, 0d2h, 0c5h, 0d6h, 0c3h, 097h, 0c5h, 0d2h, 0c1h
             db 0d2h, 0c5h, 0c4h, 0d2h, 0c5h, 097h, 099h, 099h, 099h, 0d5h
             db 0c2h, 0c3h, 097h, 0c4h, 0c3h, 0d2h, 0d0h, 0d6h, 0d9h, 0d8h
             db 097h, 08ch, 09eh
             
             ;db 59h, 6fh, 75h, 20h, 61h, 72h, 65h, 20h, 20h, 61h
             ;db 20h, 67h, 65h, 72h, 61h, 74h, 20h, 72h, 65h, 76h
             ;db 65h, 72h, 73h, 65h, 72h, 20h, 2eh, 2eh, 2eh, 62h
             ;db 75h, 74h, 20h, 73h, 74h, 65h, 67h, 61h, 6eh, 6fh
             ;db 20h, 3bh, 29h       
             
             db 0f3h, 0d6h, 0cbh, 0cah, 0c3h, 084h, 0d7h, 0c1h, 0d6h, 0cdh
             db 0c5h, 0c8h, 085h
             
             ;db 57h, 72h, 6fh, 6eh, 67h, 20h, 73h, 65h, 72h, 69h
             ;db 61h, 6ch, 21h

.DATA?

    hInstance HINSTANCE ?
    CommandLine LPSTR ?
    
    hwndButton HWND ?
    
    hwndEdit_1 HWND ?
    hwndEdit_2 HWND ?
    
    hwndLabel_1 HWND ?
    hwndLabel_2 HWND ?
    
    buf_1 db 17 dup(?)
    buf_2 db 17 dup(?)
    
    msgBoxText db 42 dup(?)
    
.CONST

    ButtonID equ 1
    
    EditID_1 equ 11
    EditID_2 equ 12
    
    LabelID_1 equ 21 
    LabelID_2 equ 22   

.CODE

start:
    invoke GetModuleHandle, NULL
    mov hInstance, eax
    
    invoke GetCommandLine
    mov CommandLine, eax
    
    invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
    invoke ExitProcess, eax
 
      
WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG
    LOCAL hwnd:HWND

    mov   wc.cbSize,SIZEOF WNDCLASSEX
    mov   wc.style, CS_HREDRAW or CS_VREDRAW
    mov   wc.lpfnWndProc, OFFSET WndProc
    mov   wc.cbClsExtra,NULL
    mov   wc.cbWndExtra,NULL
    push  hInstance
    pop   wc.hInstance
    mov   wc.hbrBackground, COLOR_WINDOW
    mov   wc.lpszMenuName,NULL
    mov   wc.lpszClassName,OFFSET WindowClassName
    
    invoke LoadIcon,NULL,IDI_APPLICATION
    mov   wc.hIcon,eax
    mov   wc.hIconSm,eax
    
    invoke LoadCursor,NULL,IDC_ARROW
    mov   wc.hCursor,eax
    
    invoke RegisterClassEx, addr wc
    invoke CreateWindowEx,NULL,\
                ADDR WindowClassName,\
                ADDR AppName,\
                WS_OVERLAPPEDWINDOW,\
                CW_USEDEFAULT,\
                CW_USEDEFAULT,\
                325,\
                150,\
                NULL,\
                NULL,\
                hInst,\
                NULL
    mov hwnd, eax
    
    invoke CreateWindowEx,
        NULL,\
        ADDR LabelClassName,\
        NULL,\
        WS_CHILD or WS_VISIBLE or WS_TABSTOP,\
        10, 10,\
        130, 25,\
        hwnd,\
        LabelID_1,\
        hInstance,\
        NULL
    mov hwndLabel_1, eax
    invoke SetWindowText, hwndLabel_1, addr LabelText_1 
    
    invoke CreateWindowEx,\
        WS_EX_CLIENTEDGE,\
        ADDR EditClassName,\
        NULL,\
        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or ES_AUTOHSCROLL or WS_TABSTOP,\
        150, 10,\
        150, 25,\
        hwnd,\
        EditID_1,\
        hInstance,\
        NULL
    mov hwndEdit_1, eax
    
    invoke SetFocus, hwndEdit_1
    
    invoke CreateWindowEx,
        NULL,\
        ADDR LabelClassName,\
        NULL,\
        WS_CHILD or WS_VISIBLE,\
        10, 40,\
        130, 25,\
        hwnd,\
        LabelID_2,\
        hInstance,\
        NULL
    mov hwndLabel_2, eax
    invoke SetWindowText, hwndLabel_2, addr LabelText_2 
    
    invoke CreateWindowEx,\
        WS_EX_CLIENTEDGE,\
        ADDR EditClassName,\
        NULL,\
        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or ES_AUTOHSCROLL or WS_TABSTOP,\
        150, 40,\
        150, 25,\
        hwnd,\
        EditID_2,\
        hInstance,\
        NULL
    mov hwndEdit_2, eax
    
    invoke CreateWindowEx,\
        NULL,\
        ADDR ButtonClassName,\
        offset ButtonText,\
        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON  or WS_TABSTOP,\
        100,80,\
        125,25,\
        hwnd,\
        ButtonID,\
        hInstance,\
        NULL
    mov hwndButton, eax
    
    invoke ShowWindow, hwnd, CmdShow
    invoke UpdateWindow, hwnd

    .WHILE TRUE
        invoke GetMessage, addr msg, NULL, 0, 0
        .BREAK .IF (!eax)
        
        invoke TranslateMessage, addr msg
        invoke DispatchMessage, addr msg
    .ENDW
    mov eax, msg.wParam
    ret
WinMain endp


WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    .IF uMsg == WM_DESTROY
        invoke PostQuitMessage, NULL
        
    .ELSEIF uMsg == WM_COMMAND
        mov eax, wParam
        
        .IF lParam == 0
        
        .ELSEIF ax == ButtonID
            
            shr eax,16    
            .IF ax == BN_CLICKED
            
                invoke GetWindowText, hwndEdit_1, addr buf_1, 17 
                invoke GetWindowText, hwndEdit_2, addr buf_2, 17
                
                invoke Control, addr buf_1, addr buf_2, addr msgBoxText
            
                invoke MessageBox, NULL, addr msgBoxText, offset AppName, MB_OK
                
            .ENDIF
	
        .ENDIF
    
    .ELSE
        invoke DefWindowProc, hWnd ,uMsg, wParam, lParam    ; Default message processing
        ret
    
    .ENDIF
    
    xor eax ,eax
    ret
WndProc endp 
   

Control proc str_1:DWORD, str_2:DWORD, msg_str:DWORD
    local card :byte
        
    push esi
    push edi 
    push eax
    push ebx
    push ecx
    push edx
    
    invoke Comp, str_1, str_2
    cmp eax, 053h
    jne _ne

    mov ecx, 43 ; удача
    mov ebx, dword ptr [msg_str] 
    mov byte ptr [ebx+ecx], 0h     
d:
    mov dl, byte ptr [interest+ecx-1]
    xor dl, 0b7h
    mov byte ptr [ebx+ecx-1], dl
    loop d
    jmp r

_ne: 
    mov ecx, 13 ; провал
    mov ebx, dword ptr [msg_str]
    mov byte ptr [ebx+ecx], 0h   
d1:
    mov dl, byte ptr [interest+43+ecx-1]
    xor dl, 0a4h
    mov byte ptr [ebx+ecx-1], dl
    loop d1

r:
    pop edx
    pop ecx
    pop ebx
    pop eax
    pop edi
    pop esi

    ret
Control endp


Comp proc str_1:DWORD, str_2:DWORD

    push esi
    push edi
    push ebx
    push ecx
    push edx
    
    mov esi, str_1
    mov edi, str_2
    
    xor eax, eax ; маска проверки (dx = 0x53 (01010011) если правильные строки)
    xor ecx, ecx ; счетчик
    
    mov bl, byte ptr [esi+ecx]
    mov dl, byte ptr [esi+ecx+8]
    xor bl, dl
    add bl, '0'
    cmp bl, byte ptr [edi+ecx] ; str_1[0] xor str_1[8] == str_2[0]
    je m_1
    or ax, 10000000b
    jmp [m_1+4]
m_1:
    or ax, 00000000b
    
    inc ecx
    mov bl, byte ptr [esi+ecx]
    mov dl, byte ptr [esi+ecx+8]
    xor bl, dl
    add bl, '0'
    cmp bl, byte ptr [edi+ecx] ; str_1[1] xor str_1[9] == str_2[1]
    je m_2
    or ax, 00000000b
    jmp [m_2+4]
m_2:
    or ax, 01000000b
    
    inc ecx
    mov bl, byte ptr [esi+ecx]
    mov dl, byte ptr [esi+ecx+8]
    xor bl, dl
    add bl, '0'
    cmp bl, byte ptr [edi+ecx] ; str_1[2] xor str_1[10] == str_2[2]
    je m_3
    or ax, 00100000b
    jmp [m_3+4]
m_3:
    or ax, 00000000b
    
    inc ecx
    mov bl, byte ptr [esi+ecx]
    mov dl, byte ptr [esi+ecx+8]
    xor bl, dl
    add bl, '0'
    cmp bl, byte ptr [edi+ecx] ; str_1[3] xor str_1[11] == str_2[3]
    je m_4
    or ax, 00000000b
    jmp [m_4+4]
m_4:
    or ax, 00010000b
    
    inc ecx
    mov bl, byte ptr [esi+ecx]
    mov dl, byte ptr [esi+ecx+11]
    xor bl, dl
    add bl, '0'
    cmp bl, byte ptr [edi+ecx+3] ; str_1[4] xor str_1[15] == str_2[7]
    je m_5
    or ax, 00000000b
    jmp [m_5+4]
m_5:
    or ax, 00000001b
    
    inc ecx
    mov bl, byte ptr [esi+ecx]
    mov dl, byte ptr [esi+ecx+9]
    xor bl, dl
    add bl, '0'
    cmp bl, byte ptr [edi+ecx+1] ; str_1[5] xor str_1[14] == str_2[6]
    je m_6
    or ax, 00000000b
    jmp [m_6+4]
m_6:
    or ax, 00000010b
    
    inc ecx
    mov bl, byte ptr [esi+ecx]
    mov dl, byte ptr [esi+ecx+7]
    xor bl, dl
    add bl, '0'
    cmp bl, byte ptr [edi+ecx-1] ; str_1[6] xor str_1[13] == str_2[5]
    je m_7
    or ax, 00000100b
    jmp [m_7+4]
m_7:
    or ax, 00000000b
    
    inc ecx
    mov bl, byte ptr [esi+ecx]
    mov dl, byte ptr [esi+ecx+5]
    xor bl, dl
    add bl, '0'
    cmp bl, byte ptr [edi+ecx-3] ; str_1[7] xor str_1[12] == str_2[4]
    je m_8
    or ax, 00001000b
    jmp [m_8+4]
m_8:
    or ax, 00000000b  
    
    pop edx
    pop ecx
    pop ebx
    pop edi
    pop esi
    ret
Comp endp


end start 