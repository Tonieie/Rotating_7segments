;
; Rotating_7segments.asm
;
; Created: 26-Feb-21 6:22:22 PM
; Author : Tonie
;
; Replace with your application code

.equ DIGITDDR	= DDRD
.equ DIGITPORT	= PORTD
.equ DIGIT1	= 5
.equ DIGIT2	= 4
.equ DIGIT3	= 3
.equ DIGIT4	= 2

.equ BCDDDR		= DDRB
.equ BCDPORT	= PORTB
.equ BCDA		= 0
.equ BCDB		= 1
.equ BCDC		= 2
.equ BCDD		= 3

.equ SWDDR		= DDRC
.equ SWPORT		= PORTC
.equ SWPIN		= PINC
.equ SWROR		= 3
.equ SWROL		= 2
.equ SWPAUSE		= 1
.equ SWRESET		= 0

.equ last_input	= 0x0100
.equ mode			= 0x0101
.equ is_pause			= 0x0102

.def head = r18
.def loop_counter = r17
.def current_input = r19

.org 0x500
my_num : .db 0,1,2,3,4,5,6,7,8,9,10,11,12,13

.org 0x00
setup :
	ldi r16,HIGH(RAMEND)
	out SPH,r16
	ldi r16,LOW(RAMEND)
	out SPL,r16

    ldi r16,0xFF
	out BCDDDR,r16
	out DIGITDDR,r16

	ldi r16,0x00
	out SWDDR,r16
	ldi r16,0xFF
	out SWPORT,r16

	ldi r16,0x00
	sts is_pause,r16

	ldi r16,0x0F
	sts last_input,r16			//assume switches haven't presssed

	ldi ZH,HIGH(my_num << 1)

reset :
	ldi head,10					//set head start from 0
	ldi loop_counter,25			// 1 loop = 5ms * 4 = 20ms, but we want to rotate every 1s so set loop_counter to 50 times = 20ms * 50 = 1s
halt:
	call read_input
	call delay_5ms
	call delay_5ms
	call debounce
	brcs halt
	rjmp rotate_loop

read_input :
	in current_input,SWPIN
	andi current_input,0x0F
	lds r16,last_input
	cpse r16,current_input
	sts last_input,current_input
	ret

debounce :
	in current_input,SWPIN
	andi current_input,0x0F

	lds r16,last_input
	cp current_input,r16
	breq set_mode
	clc
	ret
	set_mode :
		cpi current_input,0b00001110
		breq set_reset_mode
		cpi current_input,0b00000111
		breq set_ror_mode
		cpi current_input,0b00001011
		breq set_rol_mode
		cpi current_input,0b00001101
		breq set_pause_mode
		
		clc
		ret
	set_reset_mode :
		ldi r16,0
		sts mode,r16
		sec
		ret
	set_ror_mode :
		ldi r16,1
		sts mode,r16
		sec
		ret
	set_rol_mode :
		ldi r16,2
		sts mode,r16
		sec
		ret
	set_pause_mode :
		lds r16,is_pause
		cpi r16,0
		breq set_pause
		cpi r16,0xFF
		breq clr_pause
		ret
		set_pause :
			ser r16
			sts is_pause,r16
			ret
		clr_pause :
			clr r16
			sts is_pause,r16
			ret

rol_loop :	
		ldi loop_counter,25		//set it to 50 again
		inc head				// increae the head by 1
		cpi head,14				// if head is above 9 ( head == 10) reset it to 0
		breq rol_reset_head	
		rjmp rotate_loop			//else go to rol_loop label
		rol_reset_head :
			ldi head,0
			rjmp rotate_loop

ror_loop :	
		ldi loop_counter,25		//set it to 50 again
		dec head				// increae the head by 1
		cpi head,0xFF				// if head is above 9 ( head == 10) reset it to 0
		breq ror_reset_head	
		rjmp rotate_loop			//else go to rol_loop label
		ror_reset_head :
			ldi head,13
			rjmp rotate_loop

next_num :
	check_tail :
		cpi ZL,14
		brne tail_not_reach
		clr ZL
	tail_not_reach:
		lpm r16,Z+
		cpi r16,10
		brge clear_digit_port
		ret
		clear_digit_port :
			clr r16
			out DIGITPORT,r16
			ret

rotate_loop :
	
	mov ZL,head			//copy head to r16
	
	call read_input

	sbi DIGITPORT,DIGIT1
	call next_num

	out BCDPORT,r16			//send output to BCDPORT by r16
	call delay_5ms			//toggle each digit by 5ms
	cbi DIGITPORT,DIGIT1


	sbi DIGITPORT,DIGIT2
	call next_num

	out BCDPORT,r16			//send output to BCDPORT by r16
	call delay_5ms			//toggle each digit by 5ms
	cbi DIGITPORT,DIGIT2

	call debounce
	call read_input

	sbi DIGITPORT,DIGIT3
	call next_num

	out BCDPORT,r16			//send output to BCDPORT by r16
	call delay_5ms			//toggle each digit by 5ms
	cbi DIGITPORT,DIGIT3

	sbi DIGITPORT,DIGIT4
	call next_num

	out BCDPORT,r16			//send output to BCDPORT by r16
	call delay_5ms			//toggle each digit by 5ms
	cbi DIGITPORT,DIGIT4

	call debounce

	lds r16,is_pause
	cpi r16,0xFF
	breq rotate_loop
	cpi r16,0
	breq dec_counter
	
	dec_counter :
		dec loop_counter		//decrease the loop counter
		brne rotate_loop			//if loop_counter != 0 loop again

	lds r16,mode
	cpi r16,0
	breq b4_reset
	cpi r16,1
	breq b4_ror
	cpi r16,2
	breq b4_rol
	rjmp rotate_loop
	b4_reset :
		rjmp reset
	b4_ror :
		rjmp ror_loop
	b4_rol :
		rjmp rol_loop
      
delay_5ms :	ldi r20,80
	outer_loop : ldi r21,250	
	inner_loop :
		
		nop
		dec	r21
		brne inner_loop
	
		dec r20
		brne outer_loop
	
		ret

	

