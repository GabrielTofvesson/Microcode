#define BUCKET_SIZE 0b1000
#define BUCKET_COUNT 15
#define LIST_START 0xE0
#define LIST_SIZE 0x20
#define HASH_MASK 0b1111000




//// FOR TESTING PURPOSES ONLY ////
bra @BUBBLE_YEET




//// ---- Set initial state ----


// Zero-out everything
const 0
mov ar asr

const 1
mov ar pc

// Set up loop
const BUCKET_SIZE
mov ar hr
lcset BUCKET_COUNT

// Reset bucket counters for each bucket
$INIT_BUCKETS
mov pc pm; bls @INIT_BUCKETS_END
mov ar asr; declc
add hr; bra @INIT_BUCKETS

$INIT_BUCKETS_END




//// ---- Bucket sort ----

// Set PC to E0
const LIST_START
mov ar pc; lcset LIST_SIZE



$MOVE_TO_BUCKETS
mov pc asr; declc; bls @MOVE_TO_BUCKETS_END 
mov pm ar; mov pm gr; incpc

rol
rol
rol
rol
rol
rol
rol
and HASH_MASK

mov ar asr
mov pc ir               // Push PC
mov pm pc; add pm
incpc
mov pc pm
mov ar asr
mov gr pm
mov ir pc               // Pop PC
bra @MOVE_TO_BUCKETS

$MOVE_TO_BUCKETS_END


//// ---- Bubble sort ----



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

$LOOP
