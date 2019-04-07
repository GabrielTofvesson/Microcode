lcset 16
const 0     # Set AR to 0

$NEXT
bls @END
incpc; declc
add pc
bra @NEXT

$END
halt
