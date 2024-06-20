;*********************************************************************
; Andy Grady 2024 
; Output Supersoft HR-40b and 80 screen i mage to the CBM 8023p printer
;
;*********************************************************************


		open		=$F563
		set_output	=$F7FE
		print_one	=$F266
		LA		=$D2
		FA		=$D4
		STATUS		=$96
		FNLEN		=$D1
		SA		=$D3
		CHKOUT		=$FFC9		
		CHROUT		=$FFD2
		CLRCH		=$FFCC

		xlow  	= $93EE
		xhigh	= $93EF
		ypoint 	= $93F2
		byte	= $FF
		yras	= $01
		count 	= $027A




!TO "graphix8023",cbm
*=$7D00

			JSR set_start					; setup printer modes and setup matrix

read_nextline:		LDX #$7C					; hi res graphics filenumber
			JSR CHKOUT                   			; $FFC9 CHKOUT  Set Output
		
read_point:		JSR examine					; is point at x,y set or blank
			LDY yras					; get where in the line we are
			LDA $96						; is bit set
			BEQ next_point					; bit not set so go to next
			LDA byte					; get wire line byte
			
			ORA bit_table,y 				; set the bit in the wire line according to position of yras
			STA byte					; store the wire line byte
next_point:		DEC ypoint
			DEY						; go to next location down on the wire line
			STY yras					; store Y ras location in wire line 	
			BEQ done_line					; done all 8
			BNE read_point
			
done_line:		LDA byte					; line wire byte
			JSR CHROUT

			JSR reset_yras

			JSR $EFD3					; inc xpoint
			LDA xhigh
			BNE check_low					; not gone to 319 in x direction yet
setup_dotwire:		
			JSR reset_y					; got to add back 7 to ypoint as moving along x axis with same y
			BNE read_point	

check_low:		LDA xlow
			CMP #$40					; have we reached 320 dots in X ?
			BNE setup_dotwire				; read next dot in line wire as not done 319 dots in x direction
			JSR reset_x					; reset X to 0. Leave ypoint as is
			DEC count
			BEQ read_done					; done 25 8 bit lines

			JSR CLRCH
			JSR L_A7B7					; output Custom line

			LDA #$FF
			CMP $97						; end on keypress
			BEQ read_nextline
		;	JMP L_A79B

		;	JMP read_nextline				; not done 319 dots in x (full line so go again)

read_done:		JSR L_A7B7					; output Custom line
			JSR L_A79B					; close open printer channels
			RTS
		
reset_y:		CLC						; as we are restoring reset point to next x coord
			LDA ypoint
			ADC #$08
			STA ypoint
			RTS

next_row:		SEC						; 
			LDA ypoint
			SBC #$08
			STA ypoint
			BCC read_done
			BEQ read_done
			RTS

examine:		LDA #$04					; supersoft routine to examine point on screen at specific X,Y
			STA $BB
			LDA #$00
			STA $96
			LDA byte
			PHA
			LDA yras
			pha
			JSR $EFF7
			pla
			STA yras
			PLA
			STA byte
			RTS

set_start:		LDA #$7C
			STA LA                       			;Current Logical File Number
			LDA #$04
			STA FA                       			;Current Device Number
			LDA #$00
			STA STATUS                   			;Kernal I/O Status Word: ST
			STA FNLEN                    			;Length of Current File Name
			LDA #$11
			STA SA                       			;Current Secondary Address
			JSR open

			LDA #$7D
			STA LA                       			;Current Logical File Number
			LDA #$12
			STA SA                       			;Current Secondary Address
			JSR open

			LDA #$7E
			STA LA                       			;Current Logical File Number
			LDA #$06
			STA SA                       			;Current Secondary Address
			JSR open

			LDA #$7F
			STA LA                       			;Current Logical File Number
			LDA #$00
			STA SA                       			;Current Secondary Address
			JSR open


			LDX #$7E
			JSR CHKOUT                   			;$FFC9 CHKOUT  Set Output
			LDA #$08
			JSR CHROUT                  			;$FFD2 CHROUT  Output Vector
			LDA STATUS                   			;Kernal I/O Status Word: ST
			BEQ L_A6A0
			JSR CLRCH                    			;$FFCC CLRCH   Restore I/O Vector
			RTS
;
L_A6A0:

;
L_A6BD:			JSR CLRCH
			

			LDX #$7F
			JSR CHKOUT
			LDA #$0D					; output a line feed
			JSR CHROUT
			JSR CLRCH


			LDA #$C7					; 199 rows
			STA ypoint
			LDA #$19
			STA count

reset_x:		LDA #$00					; set x to top left
			STA xlow
			STA xhigh
			STA byte
			TAY
			TAX

reset_yras:		LDA #$00
			STA byte
			LDA #$08					; each wire line is made up of 8 bits
			STA yras					; store in raster variable
			RTS

L_A7E5:			LDA #$FF
			JSR CHROUT
			JMP CHROUT

L_A7B7:			LDX #$7D					; output hi res character
			JSR CHKOUT
			LDA #$0D
			JSR CHROUT                   			; $FFD2 CHROUT  Output Vector
			JMP CLRCH                    			; $FFCC CLRCH   Restore I/O Vector

L_A79B:			LDA #$7C
			STA LA                       			; Current Logical File Number
			JSR $F2E0
			LDA #$7D
			STA LA                       			; Current Logical File Number
			JSR $F2E0
			LDA #$7E
			STA LA                       			; Current Logical File Number
			JSR $F2E0
			LDA #$7F
			STA LA                       			; Current Logical File Number
			JMP $F2E0


bit_table:		!BYTE $00,$01,$02,04,$08,$10,$20,$40,$80		; wire bit table to build up each wire column before sending