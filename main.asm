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

.def head = r18
.def loop_counter = r17

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

rol_init :
	ldi loop_counter,200
	l1:	ldi r16,0x00
		out BCDPORT,r16
		sbi DIGITPORT,DIGIT4
		call delay_5ms
		cbi	DIGITPORT,DIGIT4
		dec loop_counter
		brne l1

	ldi loop_counter,100
	l2:	ldi r16,0x01
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

	ldi loop_counter,67
	l3:	ldi r16,0x02
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

	ldi head,0
	ldi loop_counter,50
	rjmp rol_loop

	rol_next_loop :	
		ldi loop_counter,50
		inc head
		cpi head,10
		breq rol_reset_head
		rjmp rol_loop
		rol_reset_head :
			ldi head,0
						
		rol_loop :
			
			mov r16,head

			out BCDPORT,r16
			sbi DIGITPORT,DIGIT1
			call delay_5ms
			cbi DIGITPORT,DIGIT1
			
			inc r16
			call rol_check_end

			out BCDPORT,r16
			sbi DIGITPORT,DIGIT2
			call delay_5ms
			cbi DIGITPORT,DIGIT2
			
			inc r16
			call rol_check_end

			out BCDPORT,r16
			sbi DIGITPORT,DIGIT3
			call delay_5ms
			cbi DIGITPORT,DIGIT3
			
			inc r16
			call rol_check_end

			out BCDPORT,r16
			sbi DIGITPORT,DIGIT4
			call delay_5ms
			cbi DIGITPORT,DIGIT4
			
			dec loop_counter
			brne rol_loop

			rjmp rol_next_loop

		rol_check_end :
			cpi r16,10
			breq rol_not_end
			ret
			rol_not_end :
				ldi r16,0x00
				ret
		

delay_5ms :	ldi r20,80
	outer_loop : ldi r21,250	
	inner_loop :
		
		nop
		dec	r21
		brne inner_loop
	
		dec r20
		brne outer_loop
	
		ret

	

