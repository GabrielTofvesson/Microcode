#### FOR TESTING PURPOSES ONLY ####
bra @BUBBLE_YEET




## ---- Set initial state ----


# Zero-out everything
const 0
mov ar asr

const 1
mov ar pc

# Set up loop
const 0b1000
mov ar hr
lcset 15

# Reset bucket counters for each bucket
$INIT_BUCKETS
mov pc pm; bls @INIT_BUCKETS_END
mov ar asr; declc
add hr; bra @INIT_BUCKETS

$INIT_BUCKETS_END




## ---- Bucket sort ----

# Set PC to E0
const 0xE0
mov ar pc; lcset 0x20



$MOVE_TO_BUCKETS
mov pc asr; declc; bls @MOVE_TO_BUCKETS_END 
mov pm ar; mov pm gr; incpc

rol ar
rol ar
rol ar
rol ar
rol ar
rol ar
rol ar
and 0x78

mov ar asr
mov pc ir               # Push PC
mov pm pc; add pm
incpc
mov pc pm
mov ar asr
mov gr pm
mov ir pc               # Pop PC
bra @MOVE_TO_BUCKETS

$MOVE_TO_BUCKETS_END


## ---- Bubble sort ----



$BUBBLE_YEET



mov pm ir; incpc
mov pc asr
mov pm gr; mov pm ar


mov pc hr; incpc
mov pc asr
sub pm
brn @BUBBLE_UPDATE
bra @NOUPDATE
$BUBBLE_UPDATE
mov pc hr
mov pm gr; mov pm ar
bra @LOOP
$NOUPDATE
mov gr ar
bra @LOOP
