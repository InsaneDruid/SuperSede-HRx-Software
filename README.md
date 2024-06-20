# SuperSede-HRx Software
Firmware and Tools for the SuperSede-HRx Graphics cards for the CBM PET lineup.

## The Firmware
The firmware needed for the SuperSede cards consist of

* A modified CharRom (with inverted characters).
* A 4k ROM containing the EditorROM followed by the GRAPHIX software in the E900-EFFF area.
### CharROM
[SuperSede CharROM (based on 901447-10)](https://github.com/InsaneDruid/SuperSede-HRx-Software/blob/main/firmware/SuperSede_CharROM_901447-10_(2516).bin "SuperSede CharROM (based on 901447-10)")

#### The invertCharRom script
If you have a PET with a custom or localized CharROM, you can use this script to invert all the graphics stored in the CharROM, making it compatible with the use on the SuperSede cards.

[invertCharRom.py](https://github.com/InsaneDruid/SuperSede-HRx-Software/blob/main/tools/invertCharRom.py "invertCharRom pyhton script")

### HR40
[HR40 Firmware (for Basic2)](https://github.com/InsaneDruid/SuperSede-HRx-Software/blob/main/firmware/HR40_GRAPHIX_BASIC2_(2532).bin "HR40 Firmware (for Basic2)")

[HR40 Firmware (for Basic4)](https://github.com/InsaneDruid/SuperSede-HRx-Software/blob/main/firmware/HR40_GRAPHIX_BASIC4_(2532).bin "HR40 Firmware (for Basic4)")

### HR40b
[HR40b Firmware (50Hz Editor, N-Keyboard)](https://github.com/InsaneDruid/SuperSede-HRx-Software/blob/main/firmware/HR40B_GRAPHIX_50Hz_N_(2532).bin "HR40b Firmware (50Hz Editor, N-Keyboard)")

[HR40b Firmware (60Hz Editor, N-Keyboard)](https://github.com/InsaneDruid/SuperSede-HRx-Software/blob/main/firmware/HR40B_GRAPHIX_60Hz_N_(2532).bin "HR40b Firmware (60Hz Editor, N-Keyboard)")

### HR80
[HR80 Firmware (50Hz Editor, B-Keyboard)](https://github.com/InsaneDruid/SuperSede-HRx-Software/blob/main/firmware/HR80_GRAPHIX_50Hz_B_(2532).bin "HR80 Firmware (50Hz Editor, B-Keyboard)")

[HR80 Firmware (60Hz Editor, B-Keyboard)](https://github.com/InsaneDruid/SuperSede-HRx-Software/blob/main/firmware/HR80_GRAPHIX_60Hz_B_(2532).bin "HR80 Firmware (60Hz Editor, B-Keyboard)")

### HR80 SoftROM Firmware Variant
This is an extract of the GRAPHIX software that can be loaded into RAM when you have an EDIT ROM that cannot accommodate the code (such as localized Editor versions). It operates exactly as before with all commands preserved and one extra for screen printing added. Should work with the HR-40B board (not tested) but not HR-40. 

[graphix.prg - HR80 SoftROM Firmware](https://github.com/InsaneDruid/SuperSede-HRx-Software/blob/main/firmware/graphix.prg "graphix.prg - HR80 SoftROM Firmware")

#### Usage

* Load *graphix* into memory using the *L* command in the TIM machine code monitor
	* you can use the normal *LOAD* command, followed by *NEW* after adjusting the top of basic pointers
* Protect the memory space the firmware resides in by adjusting the top of basic pointers: *POKE 52,0 : POKE 53,110 : CLR*
* The HR command address is now *SYS 30464, x* (existing software has to be adjusted accordingly)
* Use *SYS 30464,G* to print the currently displayed image. 
* To adjust line spacing for the printer use *POKE 32515, x* where x is the value for your printer (see below).

## The PrintScreen Routine
Andy Grady wrote a new screen printing routine as only the documentation for the original one could be found.
The graphixprint routine will work with all printers, but its recommended to use a custom routine for 8023p printers (see below).

[graphixprint.prg](https://github.com/InsaneDruid/SuperSede-HRx-Software/blob/main/tools/graphixprint.prg "graphixprint program for making hardcopies on 3022 or 4022 printers")
### General Usage

* Load the *graphixprint* code into memory using the *L* command in the TIM machine code monitor
  	* You can use the normal *LOAD* command, followed by *NEW* after adjusting the top of basic pointers.
	* Make sure you protect the memory where the code is loaded by adjusting the top of basic pointers:  
 	*POKE 52,0 : POKE 53,125:  CLR*
* Use the command *SYS 32000* to print the currently displayed screen on the connected printer.
* Set the line spacing on memory location 32264, depending on the printer used:
	* 3022 printer: *poke 32264,18*
	* 4022 printer: *poke 32264,21*
	* 8023p printer: *poke 32264,8* (prints using a 7x6 matrix so will see line gaps, see below)
* You can increase the left margin offset using: *poke 32313,x*
	* x = 1 by default (so it works with the 3022)  
	* do not set it to 0 for 3022 
 
### Avoiding line gaps on the CBM 8023p
Load the *graphixp8023* code into memory using above procedure.
This routine is optimized for the CBM 8023p printer as it uses an 8x8 dot matrix and thus eliminates line spacing artefacts.
There is no need to adjust line spacing. 

[graphixp8023.prg](https://github.com/InsaneDruid/SuperSede-HRx-Software/blob/main/tools/graphixp8023.prg "graphixp8023 program for making hardcopies on 8023 printers")
