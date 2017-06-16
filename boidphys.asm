;boidphys.asm
;includes phys for the boid

BOIDGRAV:
		;if not terminal velocity, increase downward speed
	LDX universaltimer
	INX
	STX universaltimer
	TXA
	ROR A
	BCS TERMVEL
	LDA boidspeedy
	CMP #$00
	BEQ TERMVEL
	SEC
	SBC #$01
	STA boidspeedy
TERMVEL:

	LDA boidspeedy 
	CMP #$06
	BMI BOIDDOWNPLS
	SEC
	SBC #$06
	STA temp
	LDA boidy
	SEC
	SBC temp ; A now has prospective new boidy
	CMP #$11
	BCC TOPPEDOUT
	STA boidy
	JMP DONEBOIDGRAV
TOPPEDOUT:
	LDA #$11
	STA boidy
BOIDDOWNPLS:
	LDA #$06
	SEC
	SBC boidspeedy
	CLC
	ADC boidy
	CMP #$D6
	BCS BOTTOMMEDOUT
	STA boidy
	JMP DONEBOIDGRAV
BOTTOMMEDOUT:
	LDA #$D6
	STA boidy
DONEBOIDGRAV:
	RTS


UPDATEBOIDY:
	LDA boidy
	STA $0200
	STA $0204
	CLC
	ADC #$08
	STA $0208
	STA $020C
	CLC
	ADC #$08
	STA $0210
	STA $0214
	CLC
	ADC #$08
	STA $0218
	STA $021C
	RTS