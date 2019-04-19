#define LIST_START 0xE0
#define HASH_MASK 0b1111
#define BUCKET_SIZE 13
#define FIRST_BUCKET_ADDRESS 0x10
#define LAST_BUCKET_ADDRESS  0xe0

// PM initial state
#data 0x00 0x78
#data 0x01 0x85
#data 0x02 0x92
#data 0x03 0x9f
#data 0x04 0xac
#data 0x05 0xb9
#data 0x06 0xc6
#data 0x07 0xd3
#data 0x08 0x10
#data 0x09 0x1d
#data 0x0a 0x2a
#data 0x0b 0x37
#data 0x0c 0x44
#data 0x0d 0x51
#data 0x0e 0x5e
#data 0x0f 0x6b

#data 0x10 0x10
#data 0x1d 0x1d
#data 0x2a 0x2a
#data 0x37 0x37
#data 0x44 0x44
#data 0x51 0x51
#data 0x5e 0x5e
#data 0x6b 0x6b
#data 0x78 0x78
#data 0x85 0x85
#data 0x92 0x92
#data 0x9f 0x9f
#data 0xac 0xac
#data 0xb9 0xb9
#data 0xc6 0xc6
#data 0xd3 0xd3


// TODO: Include register initial-state compiler directive (saves, like, 2 cycles max)
// Set PC to LIST_START
const LIST_START
mov ar pc


//// ---- START OF DANK SORT ---- ////
$DANK_SORT

mov pc asr
mov pc ir; incpc
mov pm ar
mov pc asr
mov pm hr

brl; mov hr gr
brl
brl
brl
and HASH_MASK
mov ar asr
mov pm ar; mov pm asr
mov ar pc; mvn ar
add 1
add pm

mov ar lc

mov pc ar

// Move 
mov pm pc
incpc
mov pc pm
mov ar pc


// First insertion
$DANK_INSERT_FIRST_START

incpc; bls @DANK_INSERT_FIRST_END_BIGGEST

mov pc asr
mov pm ar
sub gr
adn gr; brn @DANK_INSERT_FIRST_BOTTOM

mov gr pm

$DANK_INSERT_FIRST_SHIFT
incpc; bls @DANK_INSERT_SECOND_START
mov pc asr
mov pm gr
mov ar pm
mov gr ar; declc
bra @DANK_INSERT_FIRST_SHIFT

$DANK_INSERT_FIRST_BOTTOM
declc; bra @DANK_INSERT_FIRST_START

$DANK_INSERT_FIRST_END_BIGGEST
mov pc asr
mov gr pm

$DANK_INSERT_SECOND_START
// Finalize hash in HR
mov hr ar
and HASH_MASK
mov ar asr
mov pm hr
mov pm asr

mov pm pc; mov pm ar
incpc; sub hr
mov pc pm

mov ar lc

mov hr pc

// Get the value we hashed
mov ir asr
mov pm gr

// Second insertion
$DANK_INSERT_SECOND_LOOP
incpc; bls @DANK_INSERT_SECOND_END_BIGGEST

mov pc asr
mov pm ar
sub gr
adn gr; brn @DANK_INSERT_SECOND_BOTTOM

mov gr pm

$DANK_INSERT_SECOND_SHIFT
incpc; bls @DANK_INSERT_SECOND_END_NUMLET
mov pc asr
mov pm gr
mov ar pm
mov gr ar; declc
bra @DANK_INSERT_SECOND_SHIFT

$DANK_INSERT_SECOND_BOTTOM
declc; bra @DANK_INSERT_SECOND_LOOP

$DANK_INSERT_SECOND_END_BIGGEST
mov pc asr
mov gr pm

$DANK_INSERT_SECOND_END_NUMLET

mov ir ar; mov ir pc
sub 0xFE
brz @BUCKET_SORT_END; incpc
bra @DANK_SORT; incpc


$BUCKET_SORT_END


// PC is 0 here. Data is sorted smallest-to largest in memory: just spread out into buckets ;)
// Perform final merge here

// Set PC to write index
const 0xE0
mov ar pc


// ######## INSERTION ########## 

// COPY NEGATIVE

// Initialize GR as bucket pointer and IR as element pointer
const FIRST_BUCKET_ADDRESS
mov ar gr


$LOOP
// Dereference GR into IR and compute length
mov gr asr
mov pm ar

// Subtract start from end and save (the resultant length) into LC
sub gr
mov ar lc

// Calcuate the first element of the array and store in IR
mov gr ar
add 1
mov ar ir

$COPY_BUCKET
bls @NEXT_BUCKET

mov ir asr; mov ir ar
mov pm hr

add 1
mov ar ir

// Write value to be copied into write index (data[pc] = data[ir])
mov pc asr
mov hr pm; incpc; declc
bra @COPY_BUCKET
$NEXT_BUCKET


mov gr ar
add BUCKET_SIZE
mov ar gr
sub LAST_BUCKET_ADDRESS
bnz @LOOP


$BREAK
halt
