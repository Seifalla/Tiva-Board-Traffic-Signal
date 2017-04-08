; InputOutput.s
; Runs on LM4F120/TM4C123
; Test the GPIO initialization functions by setting the LED
; color according to the status of the switches.
; The Reflex Test (no longer supported; each LED turns others off):
; This program is functionally similar to SwitchTestMain.c
; in Switch_4F120asm.  When switch #1 is pressed, the blue
; LED comes on.  When switch #2 is pressed, the red LED
; comes on.  When both switches are pressed, the green LED
; comes on.  A short delay is inserted between
; polls of the buttons to compensate for your reflexes and
; the button bounce.  The following color combinations can
; be made:
; Color    LED(s) Illumination Method
; dark     ---    release both buttons
; red      R--    press right button (#2)
; blue     --B    press left button (#1)
; green    -G-    press both buttons exactly together
; yellow   RG-    press right button, then press left button
; sky blue -GB    press left button, then press right button
; white    RGB    press either button, then press the other
;                 button, then release the first button
; pink     R-B    press either button, then release the
;                 first button and immediately press the
;                 other button
; Daniel Valvano
; September 11, 2013

;  This example accompanies the book
;  "Embedded Systems: Introduction to ARM Cortex M Microcontrollers"
;  ISBN: 978-1469998749, Jonathan Valvano, copyright (c) 2013
;  Section 4.2    Program 4.1
;
;Copyright 2013 by Jonathan W. Valvano, valvano@mail.utexas.edu
;   You may use, edit, run or distribute this file
;   as long as the above copyright notice remains
;THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED
;OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
;MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.
;VALVANO SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL,
;OR CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
;For more information about my classes, my research, and my books, see
;http://users.ece.utexas.edu/~valvano/

; negative logic switch #2 connected to PF0 on the Launchpad
; red LED connected to PF1 on the Launchpad
; blue LED connected to PF2 on the Launchpad
; green LED connected to PF3 on the Launchpad
; negative logic switch #1 connected to PF4 on the Launchpad
; NOTE: The NMI (non-maskable interrupt) is on PF0.  That means that
; the Alternate Function Select, Pull-Up Resistor, Pull-Down Resistor,
; and Digital Enable are all locked for PF0 until a value of 0x4C4F434B
; is written to the Port F GPIO Lock Register.  After Port F is
; unlocked, bit 0 of the Port F GPIO Commit Register must be set to
; allow access to PF0's control registers.  On the LM4F120, the other
; bits of the Port F GPIO Commit Register are hard-wired to 1, meaning
; that the rest of Port F can always be freely re-configured at any
; time.  Requiring this procedure makes it unlikely to accidentally
; re-configure the JTAG and NMI pins as GPIO, which can lock the
; debugger out of the processor and make it permanently unable to be
; debugged or re-programmed.

        IMPORT   SysTick_Init
        IMPORT   SysTick_Wait
        IMPORT   SysTick_Wait100ms
        IMPORT   PLL_Init

GPIO_PORTF_DATA_R  EQU 0x400253FC
GPIO_PORTF_DIR_R   EQU 0x40025400
GPIO_PORTF_AFSEL_R EQU 0x40025420
GPIO_PORTF_PUR_R   EQU 0x40025510
GPIO_PORTF_DEN_R   EQU 0x4002551C
GPIO_PORTF_LOCK_R  EQU 0x40025520
GPIO_PORTF_CR_R    EQU 0x40025524
GPIO_PORTF_AMSEL_R EQU 0x40025528
GPIO_PORTF_PCTL_R  EQU 0x4002552C
GPIO_PORTE_DATA_R  EQU 0x400243FC
GPIO_PORTE_DIR_R   EQU 0x40024400
GPIO_PORTE_AFSEL_R EQU 0x40024420
GPIO_PORTE_PUR_R   EQU 0x40024510
GPIO_PORTE_DEN_R   EQU 0x4002451C
GPIO_PORTE_LOCK_R  EQU 0x40024520
GPIO_PORTE_CR_R    EQU 0x40024524
GPIO_PORTE_AMSEL_R EQU 0x40024528
GPIO_PORTE_PCTL_R  EQU 0x4002452C
GPIO_LOCK_KEY      EQU 0x4C4F434B  ; Unlocks the GPIO_CR register
RED_CW       EQU 0x40025008				; PF1
GREEN_CW   	 EQU 0x40025020				; PF3
SW1      	 EQU 0x40025040                 ; on the left side of the Launchpad board PF4
RED			 EQU 0x40024080				; PE5
YELLOW		 EQU 0x40024040				; PE4
GREEN		 EQU 0x40024020				; PE3
SYSCTL_RCGC2_R     EQU 0x400FE108
SYSCTL_RCGC2_GPIOF EQU 0x00000020  ; port F Clock Gating Control

        AREA    |.text|, CODE, READONLY, ALIGN=2
        THUMB
        EXPORT  Start
		
Start
    BL  PortF_Init 					; initialize input and output pins of Port F
	BL	PortE_Init					; same for Port E
    BL  PLL_Init                    ; set system clock to 80 MHz
    BL  SysTick_Init                ; initialize SysTick timer
	

LED_test							; run through turning on/off each LED state
;	MOV R0, #1
;	BL	SysTick_Wait100ms	
;	BL	trafficRed
;	MOV R0, #1
;	BL	SysTick_Wait100ms
;	BL	trafficAllOff
;	BL	trafficGreen
;	MOV R0, #10
;	BL 	SysTick_Wait100ms
;	BL	trafficAllOff
;	BL	trafficYellow
;	MOV R0, #10
;	BL	SysTick_Wait100ms
;	BL	trafficAllOff
;	MOV R0, #10
;	BL	SysTick_Wait100ms
;	BL	walkRed
;	MOV R0, #10
;	BL	SysTick_Wait100ms
;	BL	walkGreen
;	MOV R0, #10
;	BL	SysTick_Wait100ms
;	BL	walkAllOff
	
;	BL	LED_test					

logic
	BL	trafficAllOff
	BL	walkAllOff
	BL	trafficGreen
	BL	walkRed
	MOV R0, #150						; wait 15
	BL	SysTick_Wait100ms
crosswalk
    LDR R1, =GPIO_PORTF_DATA_R 			; pointer to Port F data
    LDR R0, [R1]               			; read all of Port F
    AND R0,R0,#0x10           			; just the input pin PF4
	CMP	R0, #0x10						; R0 == 0x10?
	BEQ	crosswalk						; if equal (switch not pressed), wait for crosswalk input
	
	BL	trafficAllOff
	BL	trafficYellow
	MOV R0, #50						; wait 5
	BL	SysTick_Wait100ms
	BL	trafficAllOff
	BL	trafficRed					; then turn red
	BL	walkAllOff
	BL	walkGreen
	MOV R0, #100						; wait 10
	BL	SysTick_Wait100ms
	
	MOV	R5, #10
toggle_LED
	MOV R0, #10					
	BL	SysTick_Wait100ms				; necessary wait at start of loop to ensure loop cycles as intended
	BL	walkAllOff
	MOV R0, #10						
	BL	SysTick_Wait100ms
	BL	walkGreen
	SUBS R5, R5, #1
	BHI	toggle_LED
	
	B	logic	
	
;states
trafficGreen
	LDR R0, =GREEN
	MOV R4, #0x08
	STR R4, [R0]
    BX	LR	
trafficRed
	LDR R0, =RED
	MOV R4, #0x20
	STR R4, [R0]
	BX	LR
trafficYellow
    LDR R0, =YELLOW      
	MOV R4, #0x10
	STR R4, [R0]
    BX	LR
trafficAllOff
	LDR R0, =RED
    MOV R4, #0  
	STR R4, [R0]
	LDR R0, =GREEN                 
	STR R4, [R0]
	LDR R0, =YELLOW              	
	STR R4, [R0]	
    BX	LR
walkGreen
    LDR R0, =GREEN_CW         
	MOV R4, #0x08
	STR R4, [R0]
    BX	LR
walkRed
    LDR R0, =RED_CW     
	MOV R4, #0x02
	STR R4, [R0]
    BX	LR
walkAllOff
    LDR R0, =RED_CW                 
	MOV R4, #0
	STR R4, [R0]
	LDR R0, =GREEN_CW 
	STR R4, [R0]
    BX	LR


;------------delay------------
; Delay function for testing, which delays about 3*count cycles.
; Input: R0  count
; Output: none
ONESEC             EQU 5333333      ; approximately 1s delay at ~16 MHz clock
QUARTERSEC         EQU 1333333      ; approximately 0.25s delay at ~16 MHz clock
FIFTHSEC           EQU 1066666      ; approximately 0.2s delay at ~16 MHz clock
	
delay
	LDR R0, =QUARTERSEC
loop
    SUBS R0, R0, #1                 ; R0 = R0 - 1 (count = count - 1)
    BNE loop                       ; if count (R0) != 0, skip to 'delay'
    BX  LR                          ; return
	
	


;------------PortF_Init------------
; Initialize GPIO Port F for negative logic switches on PF0 and
; PF4 as the Launchpad is wired.  Weak internal pull-up
; resistors are enabled, and the NMI functionality on PF0 is
; disabled.  Make the RGB LED's pins outputs.
; Input: none
; Output: none
; Modifies: R0, R1
PortF_Init
    LDR R1, =SYSCTL_RCGC2_R         ; 1) activate clock for Port F
    LDR R0, [R1]                 
    ORR R0, R0, #0x20               ; set bit 5 to turn on clock
    STR R0, [R1]                  
    NOP
    NOP                             ; allow time for clock to finish
    LDR R1, =GPIO_PORTF_LOCK_R      ; 2) unlock the lock register
    LDR R0, =0x4C4F434B             ; unlock GPIO Port F Commit Register
    STR R0, [R1]                    
    LDR R1, =GPIO_PORTF_CR_R        ; enable commit for Port F
    MOV R0, #0xFF                   ; 1 means allow access
    STR R0, [R1]                    
    LDR R1, =GPIO_PORTF_AMSEL_R     ; 3) disable analog functionality
    MOV R0, #0                      ; 0 means analog is off
    STR R0, [R1]                    
    LDR R1, =GPIO_PORTF_PCTL_R      ; 4) configure as GPIO
    MOV R0, #0x00000000             ; 0 means configure Port F as GPIO
    STR R0, [R1]                  
    LDR R1, =GPIO_PORTF_DIR_R       ; 5) set direction register
	ORR R0, #0x0E					; set bits 1-3 for PF1, PF3 LED output
	BIC R0, #0x10					; reset bit 4 for PF4 input
    STR R0, [R1]                    
    LDR R1, =GPIO_PORTF_AFSEL_R     ; 6) regular port function
    MOV R0, #0                      ; 0 means disable alternate function 
    STR R0, [R1]                    
    LDR R1, =GPIO_PORTF_PUR_R       ; pull-up resistors for PF4
    MOV R0, #0x10                   ; enable weak pull-up on PF4
    STR R0, [R1]              
    LDR R1, =GPIO_PORTF_DEN_R       ; 7) enable Port F digital port
    MOV R0, #0xFF                   ; 1 means enable digital I/O
    STR R0, [R1]                   
    BX  LR      

;------------PortE_Init------------
; Initialize GPIO Port E for PE5-7 outputs to LEDs
; Input: none
; Output: none
; Modifies: R0, R1
PortE_Init
    LDR R1, =SYSCTL_RCGC2_R         ; 1) activate clock for Port E
    LDR R0, [R1]                 
    ORR R0, R0, #0x10               ; set bit 4 to turn on clock
    STR R0, [R1]                  
    NOP
    NOP                             ; allow time for clock to finish                   
    LDR R1, =GPIO_PORTE_AMSEL_R     ; 3) disable analog functionality
    MOV R0, #0                      ; 0 means analog is off
    STR R0, [R1]                    
    LDR R1, =GPIO_PORTE_PCTL_R      ; 4) configure as GPIO
    MOV R0, #0x00000000             ; 0 means configure Port E as GPIO
    STR R0, [R1]                  
    LDR R1, =GPIO_PORTE_DIR_R       ; 5) set direction register
	ORR R0, #0x38					; set bits 2-5 for PE2-5 LED output
    STR R0, [R1]                    
    LDR R1, =GPIO_PORTE_AFSEL_R     ; 6) regular port function
    MOV R0, #0                      ; 0 means disable alternate function 
    STR R0, [R1]                            
    LDR R1, =GPIO_PORTE_DEN_R       ; 7) enable Port E digital port
    MOV R0, #0x38                   ; 1 means enable digital I/O
    STR R0, [R1]                   
    BX  LR  

stop
	
    ALIGN                           ; make sure the end of this section is aligned
    END                             ; end of file
