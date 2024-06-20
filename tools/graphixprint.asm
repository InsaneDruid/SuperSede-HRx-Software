
;**********************************************************
; code to output the hi resoltion plot screen from
; the Supersoft HR-40, 40B and -80 320x200 hi res boards
; Code prodced by Andy Grady - 2024
; Free to modify for your own use
;***********************************************

		open		=$F563			; file open
		set_output	=$F7FE			; set output channel
		print_one	=$F266			; output one charatcer to current output channel
		LA		=$D2			; logical file number
		FA		=$D4			; file address
		STATUS		=$96			; status 
		FNLEN		=$D1			; file name length
		SA		=$D3			; secondary address
		CHKOUT		=$FFC9		
		CHROUT		=$FFD2
		CLRCH		=$FFCC

		xlow  	= $93EE				; 16 bit x coord 0-320
		xhigh	= $93EF
		ypoint 	= $93F2				; 8 bit y cord 0-200
		byte	= $FF
		yras	= $01
		count 	= $027A
		xcount  = $027B
		blank   = $05
		charcount=$04




!TO "graphixprint",cbm

*=$7D00

			JSR set_start					; setup printer modes and setup matrix
			LDX #$7C					; printer secondary channel 5
			JSR CHKOUT
read_point:		                   				; $FFC9 CHKOUT  Set Output
		
read_point1:		JSR examine					; is point at x,y set or blank
			LDY yras					; get where in the line we are
			LDA $96						; is bit set (none zero is set)
			BEQ next_point					; bit not set so go to next
			LDA byte					; build wire line byte
			ORA bit_table,y 				; set the bit in the wire line according to position of yras
			STA byte					; store the wire line byte

			ORA blank					; is it a blank character as no need to print if so but need to count
			STA blank					; stops printing blanks if zero then processed a space
next_point:		DEC ypoint					; next bit down (y) in Supersoft coordinates
			LDA #$FF 
			CMP ypoint					; check if gone past last line y=0. if so process remainder as blanks
			BNE next_point1

			INC ypoint
next_point2:		DEC ypoint
			DEY
			BEQ done_col					; process last line and ignore if beyond y=0 but still need to process special char
			BNE next_point2


next_point1:		DEY						; go to next location down on the printer wire line
			STY yras					; store Y ras location in wire line 	
			BEQ done_col					; done all 7
     			BNE read_point1					; get next point
			


done_col:		LDA byte					; line wire byte
			LDX xcount				
			STA byte_table,X				; store character in memory and process all 6 before printing
			JSR reset_yras					; reset y raster for printer
			DEC xcount					; next line in the custom char. if done 6 then print out as 7 x 6 matrix
			BNE nextx					; if done 6 columns then output char to printer
	
			JSR outputchar					; output special character to printer without line feed
			JSR reset_xcount				; reset column counter for special character
	
nextx:			LDA xhigh
			BEQ nextx1
			LDA xlow			
			CMP #$3F					; check last point in x = 319
			BEQ next_row1					; end of current row and fill in remaining special characters and print

nextx1:			JSR $EFD3					; inc xpoint using supersoft code
			JSR reset_y					; got to add back 7 to ypoint as moving along x axis with same y
			
			JMP read_point	

next_row1:		LDX xcount				
			CPX #$06
			BEQ next_row2					; last full character is blank so don't print
			
			LDA #$00
completchar:		STA byte_table,X				; fill rest of custom char with 0's
			DEX
			BNE completchar
			
			JSR outputtoprint
next_row2:		LDA #$FF
			CMP $97						; end on keypress
			BEQ completcharcont
			JMP L_A79B

completcharcont:	JSR reset_x					; reset X to 0. Leave ypoint as is
			
			DEC count					; next line
			BEQ read_done					; done 25 8 bit lines
			BNE read_point

outputtoprint:		JSR outputchar					; output last one
			JSR set_outputnorm
			LDA #$0D					; finsihed the line so output CR
			JSR CHROUT
			JSR reset_xcount
			LDA #$00
			STA blank
			JSR set_outputspecial
			RTS
read_done:		
			JSR CLRCH
			JSR L_A79B					; close open printer channels
			RTS
		
reset_y:		CLC						; as we are restoring reset point to next x coord
			LDA ypoint
			ADC #$07
			STA ypoint
			RTS

next_row:		SEC						; 
			LDA ypoint
			SBC #$07
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
			PHA
			JSR $EFF7
			PLA
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
			STA blank
			LDA #$05
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
			LDA #$15
			JSR CHROUT                  			;$FFD2 CHROUT  Output Vector
			LDA STATUS                   			;Kernal I/O Status Word: ST
			BEQ L_A6BD
			JSR CLRCH                    			;$FFCC CLRCH   Restore I/O Vector
			RTS
;
L_A6BD:			JSR set_outputnorm
			LDA #$0D					; output a line feed
			JSR CHROUT
			JSR CLRCH


			LDA #$C7					; 199 rows
			STA ypoint
			LDA #$1d
			STA count
		


reset_x:		JSR reset_xcount				; reset column counter for special character
			LDA #$00					; set x to top left
			STA xlow
			STA xhigh
			STA byte
			TAY
			TAX
			LDA #$01
			STA charcount

reset_yras:		LDA #$00
			STA byte
			LDA #$07					; each wire line is made up of 8 bits
			STA yras					; store in raster variable
			RTS

reset_xcount:		LDA #$06
			STA xcount
			RTS


L_A7E5:			LDA #$FF
			JSR CHROUT
			JMP CHROUT

outputchar:		
			LDA blank
			BEQ outputspecial2
			

outputchar1:		LDX #$06
outputchar2:		LDA byte_table,X
			JSR CHROUT
			DEX 
			BNE outputchar2
			LDA #$00
			STA blank
			
			JSR set_outputnorm
			LDX charcount
			BEQ outputspecial
			LDA #$20

nextspace:		JSR CHROUT
			DEX
			BNE nextspace
outputspecial:		
			LDA #$FE					; chr$(254)
			JSR CHROUT                   			; $FFD2 CHROUT  Output Vector
			LDA #$8D					; chr$(141) CR withput LF
			JSR CHROUT
			JSR set_outputspecial
outputspecial2:		INC charcount
			
			RTS

;close up the open chanels

L_A79B:			LDA #$7C
			STA LA                       			; Current Logical File Number
			JSR $F2E0
			LDA #$7E
			STA LA                       			; Current Logical File Number
			JSR $F2E0
			LDA #$7F
			STA LA                       			; Current Logical File Number
			JMP $F2E0

set_outputnorm:		JSR CLRCH
			LDX #$7F					; output hi res character
			JSR CHKOUT
			RTS

set_outputspecial:	JSR CLRCH                    			; $FFCC CLRCH   Restore I/O Vector
			LDX #$7C
			JSR CHKOUT
			RTS

bit_table:		!BYTE $00,$01,$02,$04,$08,$10,$20,$40		; wire bit table to build up each wire column byte before sending

byte_table:		!BYTE $00,$00,$00,$00,$00,$00,$00,$00		; 6 bytes per special characte