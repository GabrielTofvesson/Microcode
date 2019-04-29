// Hi! If you're reading this, you probably want to know what this program does
// To that, I say: Good luck and I hope you have patience and a strong will to
// live, 'cause both will be negatively impacted by trying to read the code
// below.
// This isn't a joke; I feel like someone telling a person to get off the edge
// of a tall building here: reading the code below WILL negatively impact your
// life. You have been warned.

#define LIST_START 0xE0
#define LIST_END 0x00
#define HIGHEST_BUCKET 0x78
#define BUCKET_SIZE 8
#define BUCKET_INDEX_TRACKER 0b11111000

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

// Set up buckets (with absolute sizes)
// Bucket count: 16
// Bucket size: 8
// Motivation: direct mapping from hash to bucket at the cost of bucket size
#data 0x00 0x00 // 0 (POSITIVE)
#data 0x08 0x00 // 1 (POSITIVE)
#data 0x10 0x00 // 2 (POSITIVE)
#data 0x18 0x00 // 3 (POSITIVE)
#data 0x20 0x00 // 4 (POSITIVE)
#data 0x28 0x00 // 5 (POSITIVE)
#data 0x30 0x00 // 6 (POSITIVE)
#data 0x38 0x00 // 7 (POSITIVE)
#data 0x40 0x00 // 8 (NEGATIVE)
#data 0x48 0x00 // 9 (NEGATIVE)
#data 0x50 0x00 // A (NEGATIVE)
#data 0x58 0x00 // B (NEGATIVE)
#data 0x60 0x00 // C (NEGATIVE)
#data 0x68 0x00 // D (NEGATIVE)
#data 0x70 0x00 // E (NEGATIVE)
#data 0x78 0x00 // F (NEGATIVE)


// Set all GR-registers to -1, so that we always can call "sub gr" to increment
// AR, no matter what value we have in IR ;)
const 0x100
mov ar ir
reset gr
reset grm
const 0xB00
mov ar ir
reset gr
reset grm

// Initialize PC to point at list
const LIST_START
mov ar pc
mov pc asr; incpc

//$BUCKET_SORT_START
mov pm ir; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE

mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE
mov pm ir; incpc; call @JTABLE


//sub LIST_END
//bnz @BUCKET_SORT_START

//call @BREAK


// Merge
const BUCKET_SIZE
mov ar hr
const LIST_START
mov ar pc
const HIGHEST_BUCKET


$MERGE
// Load bucket size
mov ar asr
mov pm lc
bls @MERGE_BOTTOM

// Copy elements to list
$MERGE_MOVE
sub gr; bls @MERGE_BOTTOM
mov ar asr
mov pm ir
mov pc asr; incpc
mov ir pm; declc; bra @MERGE_MOVE

// Check if we just copied the last bucket
$MERGE_BOTTOM
and BUCKET_INDEX_TRACKER
sub hr; bnz @MERGE


$BREAK
halt




// Jump-table subroutine
$JTABLE
mov pc hr; bop

// IR OP-field jump table
$OT_0
const 0x38
mov ar asr; bra @PREPARE_SORT

$OT_1
const 0x30
mov ar asr; bra @PREPARE_SORT

$OT_2
const 0x28
mov ar asr; bra @PREPARE_SORT

$OT_3
const 0x20
mov ar asr; bra @PREPARE_SORT

$OT_4
const 0x18
mov ar asr; bra @PREPARE_SORT

$OT_5
const 0x10
mov ar asr; bra @PREPARE_SORT

$OT_6
const 0x08
mov ar asr; bra @PREPARE_SORT

$OT_7
const 0x00
mov ar asr; bra @PREPARE_SORT

$OT_8
const 0x78
mov ar asr; bra @PREPARE_SORT

$OT_9
const 0x70
mov ar asr; bra @PREPARE_SORT

$OT_A
const 0x68
mov ar asr; bra @PREPARE_SORT

$OT_B
const 0x60
mov ar asr; bra @PREPARE_SORT

$OT_C
const 0x58
mov ar asr; bra @PREPARE_SORT

$OT_D
const 0x50
mov ar asr; bra @PREPARE_SORT

$OT_E
const 0x48
mov ar asr; bra @PREPARE_SORT

$OT_F
const 0x40
mov ar asr; bra @PREPARE_SORT




$PREPARE_SORT
mov pm pc; mov pm lc
sub gr; incpc
mov pc pm
mov ar pc

$INSERTION
mov pc asr; incpc; declc; bls @INSERTION_END_BIGGEST
mov pm ar
sub ir
adn ir; brn @INSERTION

mov ir pm

$INSERTION_SHIFT
mov pc asr
mov pm ir
mov ar pm; bls @INSERTION_END_NOTBIGGEST
mov ir ar; declc; incpc; bra @INSERTION_SHIFT

$INSERTION_END_BIGGEST
mov ir pm

$INSERTION_END_NOTBIGGEST
mov hr ar; mov hr pc
mov pc asr; ret
