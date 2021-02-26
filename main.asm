;
; Rotating_7segments.asm
;
; Created: 26-Feb-21 6:22:22 PM
; Author : Tonie
;
; Replace with your application code

.equ digitDDR	= DDRD
.equ digitPort	= PORTD
.equ digit_1	= 5
.equ digit_2	= 4
.equ digit_3	= 3
.equ digit_4	= 2

.equ BcdDDR		= DDRB
.equ BcdPort	= PORTB
.equ Bcd_A		= 0
.equ Bcd_B		= 1
.equ Bcd_C		= 2
.equ Bcd_D		= 3

.equ SwDDR		= DDRC
.equ SwPort		= PORTC
.equ SwPin		= PINC
.equ Sw_ror		= 3
.equ Sw_rol		= 2
.equ Sw_pause		= 1
.equ Sw_reset		= 0

.org 0x00
setup :
	ldi r16,HIGH(RAMEND)
	out SPH,r16
	ldi r16,LOW(RAMEND)
	out SPL,r16

    ldi r16,0xFF
	out BcdDDR,r16
	out digitDDR,r16

	ldi r16,0x00
	out SwDDR,r16
	ldi r16,0xFF
	out SwPort,r16

delay_5ms :	ldi r20,80
	outer_loop : ldi r21,250	
	inner_loop :
		
		nop
		dec	r21
		brne inner_loop
	
		dec r20
		brne outer_loop
	
		ret

	

