org $8000

cls		EQU 3435
opench	EQU 5633
pause	EQU	7997

DISPLAY_ATTR_ADDR	EQU		0x5800
KEYBOARD_LAST_K		EQU		23560

COLOR_BLACK:	EQU		0x0
COLOR_BLUE:		EQU		0x1
COLOR_RED:		EQU		0x2
COLOR_VIOLET:	EQU		0x3
COLOR_GREEN:	EQU		0x4
COLOR_CAYAN:	EQU		0x5
COLOR_YELLOW:	EQU		0x6
COLOR_WHITE:	EQU		0x7

; text parameters - set them before printing
text_inc_color		db	COLOR_BLACK
text_paper_color	db	COLOR_WHITE
text_flash_on		db	0
text_tt_delay		db	0

; window parameters - set them before calling window mgmt functions
window_col			db	0
window_row			db	0
window_len			db	0
window_hgt			db	0
window_attr			db	0 ; 0-2 - ink, 3-5 - paper, 6 - bright, 7 - flash

; password window definitions
passwd_window_col	db	2
passwd_window_row	db	8
passwd_window_len	db	27
passwd_window_hgt	db	5
passwd_window_attr	db	%00000000

startup_message:	db	'Press any key to start ...', 0x0
password_title:		db	'ENTER  PASSWORD', 0xD, 0x0

stage_done:			db	'[DONE]', 0xD, 0x0
stage_fail:			db	'[FAIL]', 0xD, 0x0

stage_0:			db	'configure UART        ', 0x0
stage_1:			db	'configure SPI         ', 0x0
stage_2:			db	'configure CAN         ', 0x0
stage_3:			db	'configure IRQs        ', 0x0
stage_4:			db  'init scheduler        ', 0x0
stage_5:			db	'disable lock device   ', 0x0

access_granted		db	'ACCESS GRANTED', 0x0
access_denied		db	'ACCESS DENIED', 0x0

flag_title			db	'FLAG: ', 0x0

password_buffer		ds	10
encoded_password_0	db	0x08, 0x07, 0x03, 0x10, 0x15, 0x21, 0x21, 0x43, 0x09
encoded_password_1	db	0x39, 0x16, 0x2E, 0x3B, 0x47, 0x32, 0x3B, 0x13, 0x1E
xored_password		ds	10

passwd_to_flag_0	db	0x00, 0x01, 0x01, 0x05, 0x02, 0x06, 0x06, 0x08, 0x04
passwd_to_flag_1	db	0x05, 0x04, 0x01, 0x08, 0x07, 0x00, 0x05, 0x08, 0xFF


sleep:
	push	hl								; a - delay in 1/50sec fraction
	ld		b, 0
	ld		c, a
	call	pause
	pop 	hl
	ret


text_getchar:
	push	bc
	xor		a
	ld		(KEYBOARD_LAST_K), a
	ld		bc, 0
	call 	pause
	ld		a, (KEYBOARD_LAST_K)
	pop		bc
	ret


text_putchar:
	rst		16								; a contains symbol to print
	ret


text_print:
	push	hl								; hl - asciiz string to print
	ld		a, 16
	rst		16
	ld		a, (text_inc_color)
	rst		16
	ld		a, 17
	rst		16
	ld		a, (text_paper_color)
	rst		16
	ld		a, 18
	rst		16
	ld		a, (text_flash_on)
	rst		16
	pop		hl
	ld		a, (hl)
	and		a
	jr		nz, _text_print_next_symb
	ret

_text_print_next_symb:
	call	text_putchar
	inc 	hl
	ld		a, (text_tt_delay)
	and 	a
	jr		z, text_print
	
	call	sleep
	jr text_print


cursor_set_pos:
	push	bc
	ld		c, a							; a - Y
	ld		a, 22
	rst		16
	ld		a, c
	rst 	16
	ld		a, b							; b - X
	rst		16
	pop		bc
	ret


window_set_attr:
	push	de
	push	bc
	push	hl

	ld		de, DISPLAY_ATTR_ADDR
	ld		bc, (window_len)				; b - height, c - width in symb
	ld		a, (window_row)
	ld		l, a
	ld		h, 0
	add		hl, hl							; 32 symbols per row
	add		hl, hl
	add		hl, hl
	add		hl, hl
	add		hl, hl
	add		hl, de							; hl - window attributes

	ld		a, (window_col)
	add		a, l
	ld		l, a
	ld		a, (window_attr)

_window_set_attr_1:
	push	bc
	push	hl

_window_set_attr_2:
	ld		(hl), a
	inc 	hl
	dec		c								; c - symbols left
	jr		nz, _window_set_attr_2

	pop 	hl
	pop		bc
	ld		de, 32
	add		hl, de
	djnz	_window_set_attr_1				; decrement b and jump if not zero

	pop		hl
	pop		bc
	pop		de
	ret


screen_clear:
	call 	cls
	ld		a, 2
	call 	opench
	ret


verify_password:
	push	hl
	push	bc
	push	de

	ld		hl, encoded_password_0
	ld		c, 0
	ld		b, 9
	ld		e, b
_push_part_0:
	ld		a, (hl)
	add		a, '0'
	ld		d, a
	ld		a, b
	ld		b, d
	push	bc
	ld		d, b
	ld		b, a
	ld		a, d
	inc		hl
	djnz	_push_part_0

	ld		hl, encoded_password_1
	xor		a
	ld		d, c
	ld		c, a
	ld		a, d
	ld		d, b
	ld		b, e
	ld		e, d
_push_part_1:
	ld		a, (hl)
	add		a, '0'
	ld		d, a
	ld		a, b
	ld		b, d
	push	bc
	ld		d, b
	ld		b, a
	ld		a, d
	inc		hl
	djnz	_push_part_1

	ld		hl, password_buffer
	ld		de, xored_password
	ld		b, 9
_check_xor_0:
	ld		c, b
	ld		b, a
	ld		a, c
	pop		bc
	ld		c, a
	ld		a, b
	ld		b, c
	ld		c, (hl)
	inc		hl
	xor		c
	ld		(de), a
	inc		de
	djnz	_check_xor_0

	xor		a
	ld		b, e
	ld		e, a
	ld		a, b
	ld		b, 9
	ld		hl, xored_password
_check_xor_1:
	ld		c, b
	ld		b, a
	ld		a, c
	pop 	bc
	ld		c, a
	ld		a, b
	ld		b, c
	ld		c, (hl)
	inc		hl
	xor		c
	jr		z, _continue
	ld		a, c
	xor		a
	inc		a
	ld		c, e
	ld		e, a
	ld		a, c
_continue:
	djnz	_check_xor_1
_exit:
	ld		b, a
	ld		a, e
	ld		e, b
	and 	a

	pop		de
	pop		bc
	pop		hl
	ret


show_fake_loading_stages:
	push	hl
	push	bc

	ld		hl, stage_4
	push	hl
	ld		hl, stage_3
	push	hl
	ld		hl, stage_2
	push	hl
	ld		hl, stage_1
	push	hl
	ld		hl, stage_0
	push	hl

	ld		a, 0
	ld		(text_tt_delay), a
	ld		b, 5
_print_stage_message:
	pop		hl
	push	bc
	call	text_print
	ld		a, 10
	call	sleep
	ld		a, COLOR_GREEN
	ld		(text_inc_color), a
	ld		hl, stage_done
	call	text_print
	ld		a, COLOR_BLACK
	ld		(text_inc_color), a
	pop		bc
	djnz	_print_stage_message

	ld 		hl, stage_5
	call 	text_print

	pop		bc
	pop		hl
	ret


print_flag:
	push	hl
	push	bc
	push	de

	ld		a, 10
	ld		b, 4
	call	cursor_set_pos
	ld		hl, flag_title
	call	text_print

	ld		de, passwd_to_flag_0
_print_next_flag_symbol:
	ld		a, (de)
	cp		0xFF
	jr		z, _exit
	ld		hl, password_buffer
	ld		c, a
	ld		b, 0
	add		hl, bc
	ld		a, (hl)
	call	text_putchar
	ld		a, 10
	call	sleep
	inc		de
	jr		_print_next_flag_symbol

_exit:
	pop		de
	pop		bc
	pop		hl
	ret


access_flag:
	push	bc
	push	hl

	ld		a, (passwd_window_col)
	ld		(window_col), a
	ld		a, (passwd_window_row)
	ld		(window_row), a
	ld		a, (passwd_window_len)
	ld		(window_len), a
	ld 		a, (passwd_window_hgt)
	ld		(window_hgt), a
	ld		a, (passwd_window_attr)
	ld		(window_attr), a
	call	window_set_attr

	ld		a, 9
	ld		b, 8
	call	cursor_set_pos
	ld		a, COLOR_WHITE
	ld		(text_inc_color), a
	ld		a, COLOR_BLACK
	ld		(text_paper_color), a
	ld 		hl, password_title
	call 	text_print

	ld		b, 9
	ld		d, 7
_print_passwd_placeholder:
	push	bc
	ld		a, 11
	ld		b, d
	call	cursor_set_pos
	ld		a, '_'
	call	text_putchar
	inc		d
	inc		d
	pop		bc
	djnz	_print_passwd_placeholder

	ld		a, 11
	ld		b, 7
	call 	cursor_set_pos

	ld		b, 0
_read_next_char:
	push	bc
	call	text_getchar
	pop 	bc
	ld		c, a
	cp		0xD								; end of password input
	jr		z, _verify_password
	ld		a, b
	sub		9								; read no more then passwd len
	jr		nc, _read_next_char
	ld		a, c
	sub		'!'								; >= '!'
	jr		c, _read_next_char
	ld		a, c
	sub		'{'								; <= 'z'
	jr		nc, _read_next_char

	ld		hl, password_buffer
	push	bc
	ld		c, b
	ld		b, 0
	add		hl, bc
	pop		bc
	ld		(hl), c
	ld		a, '*'
	call	text_putchar
	ld		a, ' '
	call 	text_putchar
	inc		b
	jr		_read_next_char
_verify_password:
	xor		a
	ld		(window_attr), a
	call	window_set_attr
	ld		a, 5
	ld		b, 22
	call	cursor_set_pos
	ld		a, COLOR_WHITE
	ld		(text_paper_color), a
	call	verify_password
	jr		nz, _password_verification_failed
	ld		a, COLOR_GREEN
	ld		(text_inc_color), a
	ld		hl, stage_done
	call	text_print
	ld		a, 10
	ld		b, 9
	call	cursor_set_pos
	ld		a, COLOR_BLACK
	ld		(text_paper_color), a
	ld		hl, access_granted
	ld		a, 1
	ld		(text_flash_on), a
	call	text_print
	xor		a
	ld		(text_flash_on), a
	ld	 	a, 150
	call	sleep
	call	window_set_attr
	call	print_flag
	call	text_getchar
	jr		_exit
_password_verification_failed:
	ld		a, COLOR_RED
	ld		(text_inc_color), a
	ld		hl, stage_fail
	call	text_print
	ld		a, 10
	ld		b, 9
	call	cursor_set_pos
	ld		a, COLOR_BLACK
	ld		(text_paper_color), a
	ld		a, 1
	ld		(text_flash_on), a
	ld		hl, access_denied
	call	text_print
	xor		a
	ld		(text_flash_on), a
	ld		a, 150
	call	sleep
_exit:
	
	pop		hl
	pop		bc
	ret


start:
	call	screen_clear

	ld		a, 10							; Y
	ld		b, 3							; X
	call 	cursor_set_pos
	ld		a, 5
	ld 		(text_tt_delay), a
	ld 		hl, startup_message
	call 	text_print
	call 	text_getchar
	call	screen_clear

	call	show_fake_loading_stages
	ld		a, 20
	call 	sleep

_try_to_get_flag:
	call access_flag
	jr	_try_to_get_flag

	ret

end start
