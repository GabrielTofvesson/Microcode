#!/bin/bash

usage(){
    echo -e "Usage:\n\t$0 [TARGET] {TYPE | OUTFILE}\n\t$0 [TARGET] [MICROTARGET] [OUTFILE]\n\t$0 [TARGET] [TYPE] [OUTFILE] [COMBINE]\n\t$0 [TARGET] asm [OUTFILE] [COMBINE] [MICROTARGET]\n\nWhere:\n\tTARGET: main compilation target file\n\tTYPE: either \"asm\" or \"micro\"\n\tOUTFILE: output .mia file\n\tCOMBINE: existing .mia file to combine compilation output with\n\tMICROTARGET: explicit microinstruction target"
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
            OUTPUT=$3
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

make all

if [ "$TYPE" = "asm" ]; then
    KJAR="compiler.jar"
    KCLASS="CompilerKt"
else
    KJAR="microcompiler.jar"
    KCLASS="MicrocompilerKt"
fi
kotlin -classpath $KJAR $KCLASS $TARGET > comp.out || exit

if [ "$COMBINE" = "" ]; then
    if [ "$MICRO" != "" ]; then
        kotlin -classpath microcompiler.jar MicrocompilerKt $MICRO >> comp.out || exit
    fi

    kotlin -classpath weaver.jar WeaverKt comp.out $OUTPUT || exit
else
    if [ "$MICRO" != "" ]; then
        kotlin -classpath microcompiler.jar MicrocompilerKt $MICRO >> comp.out || exit
    fi
    kotlin -classpath weaver.jar WeaverKt comp.out $COMBINE $OUTPUT || exit
fi

echo "Compiled successfully to $OUTPUT"
