# QL SuperForth #

## Origin ##
QL SuperForth was written for the Sinclair QL in the mid 1980's and marketed by a company called Digital Precision. There is still interest in using SuperForth in the QL community, e.g. see [Sfera](https://github.com/programandala-net/sfera), and an attempt is being made to rescue the source code from 5.25 inch floppy disks. This repository contains a meta-compiler that was developed from the original SuperForth source code published as it may assist in the rescue and/or provide a better starting point for further development.
## Original SuperForth ##
The original executable and support files are available from a [QL web site](http://www.dilwyn.me.uk/language/index.html). The original manual is available in the doc directory of this repository.

## Status ##
At present the state of the meta-compiler is a little uncertain. It was last functionally modified in late 1986 and is thought to be complete and fully working. However this is unproven until the following steps to build a system have been carried out on a QL or emulator. Assistance in carrying out this exercise will be welcomed as the author has little time available at present.

There will be differences in the source code, for example the registers used in the machine code are different to those the original system. The extent of the differences is unknown at present. 

## This Meta-compiler ##
This will build a new forth executable in two stages:

1. Assemble the machine code using a QL assembler
2. Run SuperForth to build a new version of SuperForth

Source code is present for two versions, the basic system and an extended version with a floating point extension.

### Source File Names ###
The file names have been given conventional names and extensions in this repository. These may need to be changed to be compatible with the QL and/or emulators as original QL names included the drive, filename and extension with underscore separators.

### Assemble machine code ###
Assemble either `assemble.asm` or `assemblefp.asm`. These will include the other .asm files as appropriate, the assembled files should be named `primitives.obj` or `primitives_obj` as that is the name expected by the Forth meta-compiler. It is uncertain which assembler was originally used, it may have been one by HiSoft or Metacomco, so the format of the assembler files may need to be adjusted, particularly for the macros. 

### Build the new system ###
Run either `compile.fth` or `compilefp.fth` to build the new system. These will include the rest of the `.fth` files in the correct order. If this is successful, repeating this step with the newly built system should produce an identical system.