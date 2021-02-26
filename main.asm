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

.equ last_input_addr	= 0x0100
.equ mode_addr			= 0x0101

.def head = r18
.def loop_counter = r17
.def input_temp = r19

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

	ldi r16,0x0F
	sts last_input_addr,r16			//assume switches haven't presssed

	ldi ZH,HIGH(my_num << 1)

	ldi head,10					//set head start from 0
	ldi loop_counter,50			// 1 loop = 5ms * 4 = 20ms, but we want to rotate every 1s so set loop_counter to 50 times = 20ms * 50 = 1s
	rjmp rotate_loop	

	rjmp ror_loop


rol_loop :	
		ldi loop_counter,50		//set it to 50 again
		inc head				// increae the head by 1
		cpi head,14				// if head is above 9 ( head == 10) reset it to 0
		breq rol_reset_head	
		rjmp rotate_loop			//else go to rol_loop label
		rol_reset_head :
			ldi head,0
			rjmp rotate_loop

ror_loop :	
		ldi loop_counter,50		//set it to 50 again
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

	
	dec loop_counter		//decrease the loop counter
	brne rotate_loop			//if loop_counter != 0 loop again

	rjmp ror_loop		//if loop_counter == 0 start next loop
      
delay_5ms :	ldi r20,80
	outer_loop : ldi r21,250	
	inner_loop :
		
		nop
		dec	r21
		brne inner_loop
	
		dec r20
		brne outer_loop
	
		ret

	

