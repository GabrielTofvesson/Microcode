#!/bin/bash

MODULE_PATH=$(realpath ${0%/*})

# JARs
UCOMP=microcompiler.jar
COMP=compiler.jar
WEAVER=weaver.jar

# Main classes
UCOMPMAIN=MicrocompilerKt
COMPMAIN=CompilerKt
WEAVERMAIN=WeaverKt

# Random number generator
RGEN=rand_gen.py

# Intermediate file
INTER=comp.out


usage(){
    echo -e "Usage:\n\t$0 [TARGET] {TYPE | OUTFILE}\n\t$0 [TARGET] [MICROTARGET] [OUTFILE]\n\t$0 [TARGET] [TYPE] [OUTFILE] [COMBINE]\n\t$0 [TARGET] asm [OUTFILE] [COMBINE] [MICROTARGET]\n\nWhere:\n\tTARGET: main compilation target file\n\tTYPE: either \"asm\" or \"micro\"\n\tOUTFILE: output .mia file\n\tCOMBINE: existing .mia file to combine compilation output with\n\tMICROTARGET: explicit microinstruction target"
}

path_of(){
    echo "$MODULE_PATH/$1"
}

if [ $# -eq 0 ]; then
    >&2 echo "Not enough arguments!"
    usage
    exit
fi


TARGET=$1

case $# in
    1)
        TYPE="asm"
        OUTPUT="build.mia"
        ;;

    2)
        if [ "$2" = "asm" ] || [ "$2" = "micro" ] ; then
            TYPE=$2
            OUTPUT="build.mia"
        else
            TYPE="asm"
            OUTPUT=$2
        fi
        ;;

    3)
        if [ "$2" = "asm" ] || [ "$2" = "micro" ]; then
            TYPE=$2
            if [ "$3" = "-v" ]; then
                VERILOG=$3
                OUTPUT="build.mia"
            else
                OUTPUT=$3
            fi
        else
            TYPE="asm"
            OUTPUT=$2
            MICRO=$3
        fi
        ;;

    4)
        TYPE=$2
        OUTPUT=$3
        COMBINE=$4
        ;;

    5)
        if [ "$2" != "asm" ]; then
            >&2 echo "TYPE must be asm"
            usage
            exit
        fi

        TYPE=$2
        OUTPUT=$3
        COMBINE=$4
        MICRO=$5
        ;;

    *)
        >&2 echo "Too many arguments!"
        usage
        exit
        ;;
esac

(cd $MODULE_PATH && make all)

if [ "$TYPE" = "asm" ]; then
    KJAR=$COMP
    KCLASS=$COMPMAIN
else
    KJAR=$UCOMP
    KCLASS=$UCOMPMAIN
fi

kotlin -classpath $(path_of $KJAR) $KCLASS $TARGET > $INTER || exit
python "$(path_of $RGEN)" >> $INTER

if [ "$COMBINE" = "" ]; then
    if [ "$MICRO" != "" ]; then
        kotlin -classpath $(path_of $UCOMP) $UCOMPMAIN $MICRO >> $INTER || exit
    fi

    kotlin -classpath $(path_of $WEAVER) $WEAVERMAIN $INTER $OUTPUT $VERILOG || exit
else
    if [ "$MICRO" != "" ]; then
        kotlin -classpath $(path_of $UCOMP) $UCOMPMAIN $MICRO >> $INTER || exit
    fi
    kotlin -classpath $(path_of $WEAVERJAR) $WEAVERMAIN $INTER $COMBINE $OUTPUT $VERILOG || exit
fi

# Remove intermediate compilation file
rm -f $INTER

echo "Compiled successfully to $OUTPUT"
