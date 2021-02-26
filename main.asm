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

rol_init :
	ldi loop_counter,200		//loop for 5ms *  200 = 1s
	l1:	ldi r16,0x00			//show _ _ _ 1
		out BCDPORT,r16
		sbi DIGITPORT,DIGIT4
		call delay_5ms
		cbi	DIGITPORT,DIGIT4
		dec loop_counter
		brne l1

	ldi loop_counter,100		//loop for 10ms * 100 = 1s
	l2:	ldi r16,0x01			//show _ _ 1 2
		out BCDPORT,r16
		sbi DIGITPORT,DIGIT4
		call delay_5ms
		cbi	DIGITPORT,DIGIT4

		ldi r16,0x00
		out BCDPORT,r16
		sbi DIGITPORT,DIGIT3
		call delay_5ms
		cbi	DIGITPORT,DIGIT3
		dec loop_counter
		brne l2

	ldi loop_counter,67			//loop for 15ms * 67  = 1s
	l3:	ldi r16,0x02			//show _ 1 2 3
		out BCDPORT,r16
		sbi DIGITPORT,DIGIT4
		call delay_5ms
		cbi	DIGITPORT,DIGIT4

		ldi r16,0x01
		out BCDPORT,r16
		sbi DIGITPORT,DIGIT3
		call delay_5ms
		cbi	DIGITPORT,DIGIT3

		ldi r16,0x00
		out BCDPORT,r16
		sbi DIGITPORT,DIGIT2
		call delay_5ms
		cbi	DIGITPORT,DIGIT2

		dec loop_counter
		brne l3

	ldi head,0					//set head start from 0
	ldi loop_counter,50			// 1 loop = 5ms * 4 = 20ms, but we want to rotate every 1s so set loop_counter to 50 times = 20ms * 50 = 1s
	rjmp rol_loop				//first time skip rol_next_loop label

	rol_next_loop :	
		ldi loop_counter,50		//set it to 50 again
		inc head				// increae the head by 1
		cpi head,10				// if head is above 9 ( head == 10) reset it to 0
		breq rol_reset_head	
		rjmp rol_loop			//else go to rol_loop label
		rol_reset_head :
			ldi head,0
						
		rol_loop :
			
			mov r16,head			//copy head to r16

			;call check_toggle
			;brcs rsw_jump			//if carry set : switch is pressed -> goto sw_jump

			out BCDPORT,r16			//send output to BCDPORT by r16
			sbi DIGITPORT,DIGIT1
			call delay_5ms			//toggle each digit by 5ms
			cbi DIGITPORT,DIGIT1
			
			call rol_next_digit		//inc r16 by 1 and check if r16 == 10? if true reset to 0

			out BCDPORT,r16
			sbi DIGITPORT,DIGIT2
			call delay_5ms
			cbi DIGITPORT,DIGIT2
			
			call rol_next_digit

			out BCDPORT,r16
			sbi DIGITPORT,DIGIT3
			call delay_5ms
			cbi DIGITPORT,DIGIT3
			
			call rol_next_digit

			out BCDPORT,r16
			sbi DIGITPORT,DIGIT4
			call delay_5ms
			cbi DIGITPORT,DIGIT4
			
			dec loop_counter		//decrease the loop counter
			brne rol_loop			//if loop_counter != 0 loop again

			rjmp rol_next_loop		//if loop_counter == 0 start next loop

		rol_next_digit :
			inc r16
			cpi r16,10
			breq rol_not_end
			ret
			rol_not_end :
				ldi r16,0x00
				nop
				ret
;rsw_jump :
;	rjmp sw_jump
		

delay_5ms :	ldi r20,80
	outer_loop : ldi r21,250	
	inner_loop :
		
		nop
		dec	r21
		brne inner_loop
	
		dec r20
		brne outer_loop
	
		ret

	

