#optable 0x0 @TABLE_0
#optable 0x1 @TABLE_1
#optable 0x2 @TABLE_2
#optable 0x3 @TABLE_3

mov pm ir
reset asr
mov pm grm
const 0
mov ar asr
mov pm gr
bop

$TABLE_0
const 1
bra @END

$TABLE_1
const 2
bra @END

$TABLE_2
const 3
bra @END

$TABLE_3
const 4


$END
halt
