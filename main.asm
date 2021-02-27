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
.equ mode		= 0x0101
.equ is_pause	= 0x0102
.equ pressed_flag = 0x0103
.equ pressed_mode = 0x0104

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

	ldi r16,0x0F
	sts last_input,r16			//assume switches haven't presssed

reset :
	ldi head,10					//set head start from 0
	ldi loop_counter,25			// 1 loop = 5ms * 4 = 20ms, but we want to rotate every 1s so set loop_counter to 50 times = 20ms * 50 = 1s
	clr r16
	sts is_pause,r16
	sts mode,r16

halt:

	call read_input
	call delay_5ms			//delay 10ms for debounce
	call delay_5ms
	call read_input2

	call check_mode
	lds r16,mode
	cpi r16,0
	breq halt				//if mode == 0 still halt
	rjmp rotate_loop		//else goto rotate_loop
	 

read_input :						//use this label before bouncing
	in current_input,SWPIN
	andi current_input,0x0F			//get input to r19 then mask to get only 4 LSBs
	
	ldi r16,0x0F
	cpse current_input,r16			//if current input == 0x0F (switches are halting) return to loop
	sts last_input,current_input	//else store current input to last_input for debouncing
	ret

read_input2 :						//use this label after bouncing
	in current_input,SWPIN
	andi current_input,0x0F			//get input to r19 then mask to get only 4 LSBs
	
	lds r16,last_input
	cp r16,current_input			//if current input is still the same as before delay then the swich is being pressed (not bounce)
	breq set_pressedFlag			//set flag so that we can know the switch has been pressed
	ret								//if current != last (bounce) return to loop
	set_pressedFlag :
		sts pressed_mode,current_input		//store selected mode to pressed_mode and set pressed flag to 1
		ldi r16,1
		sts pressed_flag,r16
		ret

check_mode :
	lds r16,pressed_flag
	sbrs r16,0					//if pressed_flag not set then back to loop
	ret

	in current_input,SWPIN
	andi current_input,0x0F		//get input to r19 then mask to get only 4 LSBs

	cpi current_input,0x0F		//if the switch has been released go to set_mode, else return to loop
	breq set_mode
	ret
	set_mode :
		clr r16
		sts pressed_flag,r16	//set pressed_flag to 0
		lds r16,pressed_mode

		cpi r16,0b00001110
		breq set_reset_mode
		cpi r16,0b00000111
		breq set_ror_mode
		cpi r16,0b00001011
		breq set_rol_mode
		cpi r16,0b00001101
		breq set_pause_mode
		
		clc
		ret
	set_reset_mode :			//set mode for pressed switch. 0 : reset, 1 : ror, 2 : rol
		ldi r16,0
		sts mode,r16
		clr r16
		sts is_pause,r16
		ret
	set_ror_mode :
		ldi r16,1
		sts mode,r16
		clr r16
		sts is_pause,r16
		ret
	set_rol_mode :
		ldi r16,2
		sts mode,r16
		clr r16
		sts is_pause,r16
		ret
	set_pause_mode :			//if paused switch selected then toggle is_pause flag
		lds r16,is_pause
		ldi r20,0xFF
		eor r16,r20
		sts is_pause,r16
		ret

rol_loop :	
		ldi loop_counter,25		//set loop time for 0.5s (20ms * 25 = 500ms = 0.5s)
		inc head				// increae the head by 1
		cpi head,14				// if head reached tail position then set it to start position
		breq rol_reset_head	
		rjmp rotate_loop		//else go to rol_loop label
		rol_reset_head :
			ldi head,0
			rjmp rotate_loop

ror_loop :	
		ldi loop_counter,25		//set it to 25 again
		dec head				// decreae the head by 1
		cpi head,0xFF			// if head reached start position then set it to tail position
		breq ror_reset_head	
		rjmp rotate_loop		//else go to rol_loop label
		ror_reset_head :
			ldi head,13
			rjmp rotate_loop

next_num :
	check_tail :
		cpi ZL,14				//same as head
		brne tail_not_reach
		clr ZL
	tail_not_reach:
		lpm r16,Z+
		cpi r16,10				//if the number is greater than 9 don't enable the digitPort
		brge clear_digit_port
		ret
		clear_digit_port :
			clr r16
			out DIGITPORT,r16
			ret

rotate_loop :
	
	ldi ZH,HIGH(my_num << 1)
	mov ZL,head			//copy head to r16
	
	call read_input		//read input before debouncing delay
	call check_mode

	sbi DIGITPORT,DIGIT1
	call next_num

	out BCDPORT,r16			//send output to BCDPORT by r16
	call delay_5ms			//toggle each digit by 5ms
	cbi DIGITPORT,DIGIT1


	sbi DIGITPORT,DIGIT2
	call next_num

	out BCDPORT,r16			
	call delay_5ms			
	cbi DIGITPORT,DIGIT2

	call read_input2		//read input after 10ms delay for debouncing

	sbi DIGITPORT,DIGIT3
	call next_num

	out BCDPORT,r16			
	call delay_5ms			
	cbi DIGITPORT,DIGIT3

	sbi DIGITPORT,DIGIT4
	call next_num

	out BCDPORT,r16			
	call delay_5ms			
	cbi DIGITPORT,DIGIT4

	lds r16,is_pause
	cpi r16,0xFF
	breq rotate_loop		//if is_pause set then loop again without decreasing loop counter

	dec loop_counter		//else decrease loop counter by 1
	brne rotate_loop		

load_jumpTable :				//if loop_counter == 0 then jump to current mode using ijmp instruction
	lds r16,mode
	ldi ZL,LOW(mode_jumpTable)
	ldi ZH,HIGH(mode_jumpTable)
	add ZL,r16
	ijmp

mode_jumpTable :
	rjmp reset
	rjmp ror_loop
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

	

