#define LIST_START 0xE0
#define HASH_MASK 0b1111
#define BUCKET_SIZE 14
#define BUCKET_ADDRESS 0x00
#define LAST_BUCKET_ADDRESS  0xE0
#define LAST_BUCKET_START_ADDR 0xD2


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
#data 0x00 0x00
#data 0x0E 0x00
#data 0x1C 0x00
#data 0x2A 0x00
#data 0x38 0x00
#data 0x46 0x00
#data 0x54 0x00
#data 0x62 0x00
#data 0x70 0x00
#data 0x7e 0x00
#data 0x8c 0x00
#data 0x9a 0x00
#data 0xa8 0x00
#data 0xb6 0x00
#data 0xc4 0x00
#data 0xd2 0x00


// TODO: Include register initial-state compiler directive
// (saves, like, 2 cycles max)
// Set PC to LIST_START
const LIST_START
mov ar pc


//// ---- START OF DANK SORT ---- ////
$SORT

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
$INSERT_START

// Load a value and compare with value to be inserted
// If L is set, value is greater than all other values in bucket
incpc
mov pc asr; bls @INSERT_END_BIGGEST
mov pm ar
sub ir
adn ir; brn @INSERT_BOTTOM

// We found where to insert value. Insert it
mov ir pm; incpc

// Shift values after the value we inserted
$INSERT_SHIFT
mov pc asr; bls @INSERT_END_NUMLET
mov pm gr
mov ar pm
mov gr ar; declc; incpc; bra @INSERT_SHIFT

// Continue to next value in bucket for comparison
$INSERT_BOTTOM
declc; bra @INSERT_START

// Value we are inserting was the biggest value in the bucket
$INSERT_END_BIGGEST
mov ir pm

$INSERT_END_NUMLET

// Check if we've sorted all values. If we have, merge then,
// otherwise return to top of bucketsort
mov hr ar; mov hr pc
sub 0
bnz @SORT


$BUCKET_SORT_END


const LAST_BUCKET_START_ADDR
mov ar hr
const BUCKET_ADDRESS
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
const 0x70
mov ar asr; ret

$OT_1
const 0x7e
mov ar asr; ret

$OT_2
const 0x8c
mov ar asr; ret

$OT_3
const 0x9a
mov ar asr; ret

$OT_4
const 0xa8
mov ar asr; ret

$OT_5
const 0xb6
mov ar asr; ret

$OT_6
const 0xc4
mov ar asr; ret

$OT_7
const 0xd2
mov ar asr; ret

$OT_8
const 0x00
mov ar asr; ret

$OT_9
const 0x0e
mov ar asr; ret

$OT_A
const 0x1c
mov ar asr; ret

$OT_B
const 0x2a
mov ar asr; ret

$OT_C
const 0x38
mov ar asr; ret

$OT_D
const 0x46
mov ar asr; ret

$OT_E
const 0x54
mov ar asr; ret

$OT_F
const 0x62
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
//const BUCKET_ADDRESS
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
