#define LIST_START 0xE0
#define HASH_MASK 0b1111
#define BUCKET_SIZE 13
#define FIRST_BUCKET_ADDRESS 0x10
#define LAST_BUCKET_ADDRESS  0xE0
#define LAST_BUCKET_START_ADDR 0xD3


#optable 0x0 @OT_0
#optable 0x1 @OT_1
#optable 0x2 @OT_2
#optable 0x3 @OT_3
#optable 0x4 @OT_4
#optable 0x5 @OT_5
#optable 0x6 @OT_6
#optable 0x7 @OT_7
#optable 0x8 @OT_8
#optable 0x9 @OT_9
#optable 0xa @OT_A
#optable 0xb @OT_B
#optable 0xc @OT_C
#optable 0xd @OT_D
#optable 0xe @OT_E
#optable 0xf @OT_F

// PM initial state

// Deprecated: LUT to be replaced with K1-jump table
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

// Not deprecated
#data 0x10 0x00
#data 0x1d 0x00
#data 0x2a 0x00
#data 0x37 0x00
#data 0x44 0x00
#data 0x51 0x00
#data 0x5e 0x00
#data 0x6b 0x00
#data 0x78 0x00
#data 0x85 0x00
#data 0x92 0x00
#data 0x9f 0x00
#data 0xac 0x00
#data 0xb9 0x00
#data 0xc6 0x00
#data 0xd3 0x00


// TODO: Include register initial-state compiler directive (saves, like, 2 cycles max)
// Set PC to LIST_START
const LIST_START
mov ar pc


//// ---- START OF DANK SORT ---- ////
$DANK_SORT

mov pc asr; incpc
mov pm ir; call @JTABLE // Call jumptable. This also copies PC to HR

// We return here after visiting jump table
// AR contains a magic value and ASR contains the same value
mov pm lc; mov pm pc

// Move
incpc
mov pc pm
mov ar pc


// First insertion
$DANK_INSERT_FIRST_START

incpc; bls @DANK_INSERT_FIRST_END_BIGGEST

mov pc asr
mov pm ar
sub ir
adn ir; brn @DANK_INSERT_FIRST_BOTTOM

mov ir pm; incpc

$DANK_INSERT_FIRST_SHIFT
mov pc asr; bls @DANK_INSERT_FIRST_END_NUMLET
mov pm gr
mov ar pm
mov gr ar; declc; incpc; bra @DANK_INSERT_FIRST_SHIFT

$DANK_INSERT_FIRST_BOTTOM
declc; bra @DANK_INSERT_FIRST_START

$DANK_INSERT_FIRST_END_BIGGEST
mov pc asr
mov ir pm

$DANK_INSERT_FIRST_END_NUMLET

mov hr ar; mov hr pc
sub 0
brz @BUCKET_SORT_END
bra @DANK_SORT


$BUCKET_SORT_END


const LAST_BUCKET_START_ADDR
mov ar hr
const FIRST_BUCKET_ADDRESS
mov ar pc
const LIST_START

$MERGE
mov pc ir
mov pc asr; incpc
mov pm lc

$MERGE_MOVE
mov pc asr; bls @MERGE_BOTTOM
mov pm gr
mov ar asr
add 1
mov gr pm; declc; incpc; bra @MERGE_MOVE

$MERGE_BOTTOM
mov ar gr
mov ir ar
sub hr
adn hr; brz @PROGRAM_END
adn BUCKET_SIZE
mov ar pc
mov gr ar; bra @MERGE


$PROGRAM_END
$BREAK
halt


// Jump-table subroutine
$JTABLE
mov pc hr; bop

// IR OP-field jump table
$OT_0
const 0x78
mov ar asr; ret

$OT_1
const 0x85
mov ar asr; ret

$OT_2
const 0x92
mov ar asr; ret

$OT_3
const 0x9f
mov ar asr; ret

$OT_4
const 0xac
mov ar asr; ret

$OT_5
const 0xb9
mov ar asr; ret

$OT_6
const 0xc6
mov ar asr; ret

$OT_7
const 0xd3
mov ar asr; ret

$OT_8
const 0x10
mov ar asr; ret

$OT_9
const 0x1d
mov ar asr; ret

$OT_A
const 0x2a
mov ar asr; ret

$OT_B
const 0x37
mov ar asr; ret

$OT_C
const 0x44
mov ar asr; ret

$OT_D
const 0x51
mov ar asr; ret

$OT_E
const 0x5e
mov ar asr; ret

$OT_F
const 0x6b
mov ar asr; ret



// Old merge-algo

// Set PC to write index
//const 0xE0
//mov ar pc
//
//
//// ######## INSERTION ########## 
//
//// COPY NEGATIVE
//
//// Initialize GR as bucket pointer and IR as element pointer
//const FIRST_BUCKET_ADDRESS
//mov ar gr
//
//
//$LOOP
//// Dereference GR into IR and compute length
//mov gr asr
//mov pm ar
//
//// Subtract start from end and save (the resultant length) into LC
//sub gr
//mov ar lc
//
//// Calcuate the first element of the array and store in IR
//mov gr ar
//add 1
//mov ar ir
//
//$COPY_BUCKET
//bls @NEXT_BUCKET
//
//mov ir asr; mov ir ar
//mov pm hr
//
//add 1
//mov ar ir
//
//// Write value to be copied into write index (data[pc] = data[ir])
//mov pc asr
//mov hr pm; incpc; declc
//bra @COPY_BUCKET
//$NEXT_BUCKET
//
//
//mov gr ar
//add BUCKET_SIZE
//mov ar gr
//sub LAST_BUCKET_ADDRESS
//bnz @LOOP
//
//
//$BREAK
//halt
