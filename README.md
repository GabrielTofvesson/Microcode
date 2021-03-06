# Microcode
University project developed by me ([GabrielTofvesson](https://github.com/GabrielTofvesson)) and my
lab partner Edvard Thörnros ([FredTheDino](https://github.com/FredTheDino)).

This repository is copied verbatim from its original repository (https://gitlab.liu.se/edvth289/TSEA28-Microkod.git),
but since that repository is private (because of university lab policies), I have, with the permission of the
course examiner, posted it here instead.

More interesting information can be found in the README files of the other branches.


# Requirements
To compile and run the microcompiler and one of the ASM compilers in the other branches, you will need Kotlin.
Python is also required for one of the ASM compilers and for the microcode preprocessor.
To run the emulator, an X11 environment must be set up, along with `libxm4` (available as an `apt` pkg for `i386`).

# Branches

* `master`: I don't really know what this branch contains, but it's not useful for much

* `dev`: The interesting branch. We include two ASM compilers and a microcode compiler, along with our own microprogramming language

* `hdl`: A small modification to the `dev` branch adding support for the generation of Verilog instead of microcode


# Running
To run the microcode, simply run `./lmia`

# Note
Most rights reserved, as `lmia` and `libXm.so` are simply included in the repo, but are by no means owned or developed by neither me nor my lab partner. These aforementioned files may come to be removed from the repository
