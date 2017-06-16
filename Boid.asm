	.inesprg 1   ; 1x 16KB PRG code
	.ineschr 1   ; 1x  8KB CHR data
	.inesmap 0   ; mapper 0 = NROM, no bank swapping
	.inesmir 1   ; background mirroring
	

;THIS WAS THE LAST NESSY THING I WAS PLAYING WITH.
;OPEN THIS, boidphys.asm, controllers.asm, and background1.dat
;;;;;;;;;;;;;;;
;DECLARE VARIABLES
	.rsset $0000  ;SET INITIAL VARIBALE POSITION AT 0

temp .rs 1
mainstate .rs 1
controller1 .rs 1
controller1edge .rs 1
controller1posedge .rs 1
boidspeedy .rs 1
boidy .rs 1
scrollpos .rs 1
universaltimer .rs 1


		
	.bank 0
	.org $C000 
	.include "controllers.asm"
	.include "boidphys.asm"

loadbackground:
	LDA $2002
	LDA #$20
	STA $2006
	LDA #$00
	STA $2006
loadbackgroundloop1:
	LDA background1, x
	STA $2007
	INX
	CPX #$E0
	BNE loadbackgroundloop1
	LDX #$00
loadbackgroundloop2:
	LDA background2, x
	STA $2007
	INX
	CPX #$E0
	BNE loadbackgroundloop2
	LDX #$00
loadbackgroundloop3:
	LDA background3, x
	STA $2007
	INX
	CPX #$E0
	BNE loadbackgroundloop3
	LDX #$00
loadbackgroundloop4:
	LDA background4, x
	STA $2007
	INX
	CPX #$E0
	BNE loadbackgroundloop4
	LDX #$00
loadbackgroundloop5:
	LDA background5, x
	STA $2007
	INX
	CPX #$40
	BNE loadbackgroundloop5
	RTS

loadbackground2:
	LDA $2002
	LDA #$24
	STA $2006
	LDA #$20
	STA $2006
loadbackgroundloop21:
	LDA background21, x
	STA $2007
	INX
	CPX #$E0
	BNE loadbackgroundloop21
	LDX #$00
loadbackgroundloop22:
	LDA background22, x
	STA $2007
	INX
	CPX #$E0
	BNE loadbackgroundloop22
	LDX #$00
loadbackgroundloop23:
	LDA background23, x
	STA $2007
	INX
	CPX #$E0
	BNE loadbackgroundloop23
	LDX #$00
loadbackgroundloop24:
	LDA background24, x
	STA $2007
	INX
	CPX #$E0
	BNE loadbackgroundloop24
	LDX #$00
loadbackgroundloop25:
	LDA background25, x
	STA $2007
	INX
	CPX #$40
	BNE loadbackgroundloop25

; 	LDX #$80 ; Prevent addresses $23F8 to $23FF of PPU from showing up in top right corner
; bgfix:
; 	LDA #$1A
; 	STA $2007
; 	DEX
; 	BNE bgfix
;	LDX #$E0
; loadbackgroundloop2:
; 	LDA background2, x
; 	STA $2007
; 	DEX
; 	BNE loadbackgroundloop2

loadattributes:
	LDA $2002
	LDA #$23
	STA $2006
	LDA #$C0
	STA $2006
	LDX #$00
loadattributeloop:
	LDA attribute, x
	;LDA #$1B
	STA $2007
	INX
	CPX #$20 ; 32 = 20 in hex, we've got 38 total attribute things in the attribute table
	BNE loadattributeloop
	RTS



VBLANKWAIT:       ; First wait for vblank to make sure PPU is ready
	BIT $2002
	BPL VBLANKWAIT
	RTS



;;;;;;;;;;;;;;;;;;;;;;
;;START OF EXECUTION;;
;;;;;;;;;;;;;;;;;;;;;;

RESET:
	SEI          ; disable IRQs
	CLD          ; disable decimal mode
	LDX #$40
	STX $4017    ; disable APU frame IRQ
	LDX #$FF
	TXS          ; Set up stack
	INX          ; now X = 0
	STX $2000    ; disable NMI
	STX $2001    ; disable rendering
	STX $4010    ; disable DMC IRQs

	JSR VBLANKWAIT

clrmem:
	LDA #$00
	STA $0000, x
	STA $0100, x
	STA $0300, x
	STA $0400, x
	STA $0500, x
	STA $0600, x
	STA $0700, x
	LDA #$FE
	STA $0200, x    ;move all sprites off screen
	INX
	BNE clrmem
	LDA #$80
	STA mainstate
	
	JSR VBLANKWAIT



; ************** NEW CODE ****************
LoadPalettes:
	LDA $2002    ; read PPU status to reset the high/low latch
	LDA #$3F
	STA $2006    ; write the high byte of $3F00 address
	LDA #$00
	STA $2006    ; write the low byte of $3F00 address
	LDX #$20
LoadPalettesLoop:
	LDA palette, x        ;load palette byte
	STA $2007             ;write to PPU
	DEX                   ;set index to next byte
	BNE LoadPalettesLoop  ;if x = $20, 32 bytes copied, all done

	; load the start screen
	JSR loadbackground

	; load the stage graphics~
	JSR loadbackground2

	; load the attribute table
	JSR loadattributes

	LDA #%10010000   ; enable NMI, sprites from Pattern Table 0
	STA $2000

	LDA #%00001000   ; enable background stuffs
	STA $2001

	; reset scrolling
	LDA $2002
	LDA #$00
	STA $2005
	STA $2005

;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; MAIN LOOP ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;

FOREVER:
	JMP FOREVER     ;jump back to Forever, infinite loop
	
 

NMI:
	;CHECK TO READ THE NEWSPAPER SEE WHAT THE NEWSPAPER IS

	;PUT THE NEWSPAPER OUT ON THE LAWN FOR OLD MR JENKINS
	;FUNNY, BUT REALLY THIS PART REFRESHES THE SCREEN.

	LDA #$00
	STA $2003  ; set the low byte (00) of the RAM address
	LDA #$02
	STA $4014  ; set the high byte (02) of the RAM address, start the transfer

;REFRESH CONTROLLER INPUT VARIABLE
	JSR UPDATECONTROLLERS

;START OF GAME STATE MACHINE
	BIT mainstate
	BMI MENUSTATE
	BVS PLAYSTATE

	MENUSTATE:
				; ENSURE CORRECT BG!!!
			LDA #%00001000   ; disable sprites, keep background stuffs
			STA $2001

			LDA controller1posedge
			;AND #$10
			;BEQ DONEWITHCONTROLLERS
			CMP #$10
			BNE DONEMENU

		; PRESSED START! SETUP SPRITES!
			LDX #$00
		SPRITEMAPLOOP:
			LDA sprites, x
			STA $200, x
			INX
			CPX #$10
			BNE SPRITEMAPLOOP

			LDA #%00011000   ; enable sprites, keep background stuffs
			STA $2001

		; CHANGE BACKGROUND!
			LDA $2002
			LDA #$FF
			STA $2005
			STA scrollpos
			LDA #$00
			STA $2005

		; UPDATE VARS
			LDA $08
			STA boidspeedy


		; SPRITES LOADED, MOVE TO GAME STATE
			LDA #$40
			STA mainstate
			JMP DONEMENU

		DONEMENU:
			JMP DONEFRAME

	PLAYSTATE:

		;CHECK FOR 'START' INPUT
			LDA controller1posedge
			;AND #$20
			;BEQ NOSEL
			CMP #$10
			BNE NOSEL
			LDA MENUSTATE
			STA mainstate
		;PRESSED SELECT. RESET AND HIDE SPRITES!

			LDA #%00001000   ; disable sprites, keep background stuffs
			STA $2001

			; CHANGE BACKGROUND!
			LDA $2002
			LDA #$00
			STA $2005
			STA $2005

		NOSEL:
			JSR BOIDGRAV
			JSR UPDATEBOIDY

				;Check for right
			LDA #$01
			CMP controller1
			BNE NORIGHT
			LDA #$50
			STA boidy

		NORIGHT:

				;Check for A
			LDA #$40
			CMP controller1posedge
			BNE NOAEDGE
			LDA #$0F
			STA boidspeedy

		NOAEDGE:
		DONEFRAME:
		RTI        ; return from interrupt
	 
;;;;;;;;;;;;;;  
	
	
	
	.bank 1
	.org $E000
palette:
	.db $22,$29,$1A,$0F, $10,$0F,$36,$11, $10,$0D,$21,$34, $27,$36,$16,$06
	.db $00,$29,$22,$0F, $31,$02,$38,$3C, $0F,$1C,$15,$14, $22,$29,$1A,$0F

sprites:
	.db $80,$40,$00,$40
	.db $80,$41,$00,$48
	.db $88,$50,$00,$40
	.db $88,$51,$00,$48
	.db $90,$60,$00,$40
	.db $90,$61,$00,$48
	.db $98,$70,$00,$40
	.db $98,$71,$00,$48

	.include "background1.dat"

	.org $FFFA     ;first of the three vectors starts here
	.dw NMI        ;when an NMI happens (once per frame if enabled) the 
									 ;processor will jump to the label NMI:
	.dw RESET      ;when the processor first turns on or is reset, it will jump
									 ;to the label RESET:
	.dw 0          ;external interrupt IRQ is not used in this tutorial
	
	
;;;;;;;;;;;;;;  
	
	
	.bank 2
	.org $0000
	.incbin "test2.chr"   ;includes graphics shiz
