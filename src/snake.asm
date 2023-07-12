:BasicUpstart2(start)
*=$2000 "Program"


.pseudocommand MA_GETJOY2BIT bitvalue {
	lda $DC00
	and bitvalue
}

.pseudocommand MA_GETJOY2 {
	lda $DC00
}

.pseudocommand MA_RASTERWAIT line {

	loop: 	lda $d012		// Wait for frame
			cmp line
			bne loop

}

.pseudocommand M_JMP_IF_ZERO label {
	bne label
}

/*
	Call & keep regs save on stack

*/
.pseudocommand M_CALL addr {

	pha
	txa
	pha
	tya 
	pha

	jsr addr

	pla
	tay
	pla
	tax
	pla

}

/*
	Call & keep regs save on stack
	Call with 1 register param (x reg)
*/
.pseudocommand M_CALL1R addr : x  {

	pha
	txa
	pha
	tya 
	pha

	ldx x
	jsr addr

	pla
	tay
	pla
	tax
	pla

}

/*
	Call & keep regs save on stack
	Call with 2 register param (x,y reg)
*/
.pseudocommand M_CALL2R addr : x : y {

	pha
	txa
	pha
	tya 
	pha

	ldx x
	ldy y
	jsr addr

	pla
	tay
	pla
	tax
	pla

}


.pseudocommand MX_JMP_IF_NOTX value : dstlabel {

	cpx value
	bne dstlabel

}



start: 

	sei
	jmp program

	title_str:
		.byte 7
		.text "*snake*"

	score:
		.text "0000"

	xy:
		.byte $00, $00	

	lives:
		.byte $00

	random:
		.fill 256,random()*40

	random_counter:
		.byte $00

	save_x:
		.byte $00

	save_y:
		.byte $00	

program: {

	jsr title
	jsr game

	jmp program

}


scr_clear: {
	
	lda #$20
	ldx #$00
	l1:
		sta 1024,x
		inx
		cpx #200
		bne l1
		ldx #$00
	l2:
		sta 1024+200,x
		inx
		cpx #200
		bne l2
		ldx #$00
	l3:
		sta 1024+400,x
		inx
		cpx #200
		bne l3
		ldx #$00
	l4:
		sta 1024+600,x
		inx
		cpx #200
		bne l4
		ldx #$00
	l5:
		sta 1024+800,x
		inx
		cpx #200
		bne l5
		ldx #$00

	rts

}

scr_scrollup: {
	
	ldx #$00
	l1:
		lda 1024+40,x
		sta 1024,x
		inx
		cpx #200
		bne l1
		ldx #$00
	l2:
		lda 1024+240,x
		sta 1024+200,x
		inx
		cpx #200
		bne l2
		ldx #$00
	l3:
		lda 1024+440,x
		sta 1024+400,x
		inx
		cpx #200
		bne l3
		ldx #$00
	l4:
		lda 1024+640,x
		sta 1024+600,x
		inx
		cpx #200
		bne l4
		ldx #$00
	l5:
		lda 1024+840,x
		sta 1024+800,x
		inx
		cpx #200-40
		bne l5
	
		lda #$20
		ldx #$00
	l6:
		sta 1024+(40*24),x
		inx
		cpx #40
		bne l6		


	rts

}


bgcolors: {
	
	stx $d020
	sty $d021

	rts

}




titlescreendraw: {

	M_CALL2R bgcolors : #$00 : #$06

	jsr scr_clear

	//title
	ldx #$00

	l1:

	lda title_str+1, x
	sta $0400 + (10*40) + 17, x

	inx
	cpx title_str

	bne l1


	//score
	ldx #$00

	l2:

	lda score, x
	sta $0400 + (12*40) + 18, x

	inx
	cpx #4

	bne l2


	rts

}

title: {
	
	jsr titlescreendraw
	
	title_loop:
	
		MA_GETJOY2BIT #$10
		M_JMP_IF_ZERO title_loop

	//scroll up loop
	ldx #$00
	

	scroll_loop:
		MA_RASTERWAIT #$ff
		M_CALL scr_scrollup

		lda random,x
		tay
		lda #'*'
		sta 1024+24*40,y
		
		inx
		MX_JMP_IF_NOTX #$20 : scroll_loop


	jsr titlescreendraw

	rts
}


game: {

	jsr initlevel
	jsr levelloop

	inc $D021
	rts

}


scoreup: {

	//-- digit 3

	lda score + 3
	cmp #'9'
	beq dig3_is9
	inc score +3
	rts

	dig3_is9:
	lda #'0'
	sta score +3

	//-- digit 2

	lda score+2
	cmp #'9'
	beq dig2_is9
	inc score+2
	rts

	dig2_is9:
	lda #'0'
	sta score+2

	//-- digit 1

	lda score+1
	cmp #'9'
	beq dig1_is9
	inc score+1
	rts

	dig1_is9:
	lda #'0'
	sta score+1

	//-- digit 0

	lda score
	cmp #'9'
	beq dig0_is9
	inc score
	rts

	dig0_is9:
	lda #'0'
	sta score	

}

initlevel: {

	M_CALL2R bgcolors : #$00 : #$00
	jsr scr_clear

	lda #20
	sta xy
	lda #15
	sta xy+1

	lda #'0'
	sta score
	sta score+1
	sta score+2
	sta score+3

	rts

}




levelloop: {

	
	loop:

		/* do scrolling */
		M_CALL scr_scrollup

		/* increase  score */
		jsr scoreup

		/* draw score */
		ldx #$00

		lscore:

		lda score, x
		sta $0400 + 18, x

		inx
		cpx #4

		bne lscore

		/* slow down */
		MA_RASTERWAIT #$88
		MA_RASTERWAIT #$10
		MA_RASTERWAIT #$88
		MA_RASTERWAIT #$10
		MA_RASTERWAIT #$88

		/* draw random star at bottom of screen */
		inc random_counter
		ldy random_counter
		lda random,y
		tay
		lda #'*'
		sta 1024+24*40,y

		/* draw player */
		ldx xy 
		lda #81
		sta 1024+14*40,x

		/*check player*/
		lda 1024+15*40,x
		cmp #'*'
		beq exit

		/*handle joystick*/
		if1:
		cpx #39
		beq else1		
		MA_GETJOY2BIT #$08
		M_JMP_IF_ZERO else1
		inc xy
		
		else1:
		cpx #00
		beq endjoy
		MA_GETJOY2BIT #$04
		M_JMP_IF_ZERO endjoy
		dec xy
		
		endjoy:
		
		jmp loop

	exit:

	ldy #00
	dieloop:

		MA_RASTERWAIT #$10
		MA_RASTERWAIT #$88

		inc 55296+14*40,x
		iny
		cpy #50
		bne dieloop

	lda #14
	sta 55296+14*40,x
	rts

	
}


