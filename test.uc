# Move value in GR to HR and increment PCL

lcset 16

$LOOP
incpc; declc
bls @END          # Branch to micro-address 0 if L-flag is set
bra @LOOP
$END
HALT
