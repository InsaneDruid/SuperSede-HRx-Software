"""invertCharRom.py: Python script to invert a CBM PET CharROM
for use on the Supersoft HR40, HR40b and HR80 graphics card
and my *SuperSede* clone series for the CBM PET series."""

__author__      = "InsaneDruid"
__copyright__   = "Copyright 2024"
__license__     = "Creative Commons Attribution-ShareAlike 4.0 International"

import argparse
import os
parser = argparse.ArgumentParser(description="Invert the Characters of a CBM PET CharROM")
parser.add_argument("sourcefile", help="The name of the source CharROM.")
parser.add_argument("destinationfile", help="The name of the file to be created.")
args = parser.parse_args()

print(f"reading file {args.sourcefile}")
print(f"writing file {args.destinationfile}")
with open(args.sourcefile, "rb") as sourcefile:
    sourcefile.seek(0, os.SEEK_END)
    currentbyte = sourcefile.tell()
    sourcefile.seek(0,0)
    with open(args.destinationfile,"wb") as destinationfile:
                         
        while currentbyte >0:
            content = sourcefile.read(1)  

            destinationfile.write((255-content[0]).to_bytes(1))  

            currentbyte = currentbyte -1
print(f"operation finished")