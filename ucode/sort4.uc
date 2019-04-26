// Hi! If you're reading this, you probably want to know what this program does
// To that, I say: Good luck and I hope you have patience and a strong will to
// live, 'cause both negatively impacted by trying to read the code below.
// This isn't a joke; I feel like someone telling a person to get off the edge
// of a tall building here: reading the code below WILL negatively impact your
// life. You have been warned.

#define LIST_START 0xE0
#define LIST_END 0xFE
#define LIST_START_MODIFIED 0xDF
#define LIST_END_MODIFIED 0xFD
#define HASH_MASK 0b1111000
#define NEGATIVE_START 0x40
#define NEGATIVE_END 0x78
#define POSITIVE_START 0x00
#define POSITIVE_END 0x38
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


// Shift list down by one address, freeing up 0xFF for random-access use
reset asr
mov pm hr

const LIST_START_MODIFIED
mov ar asr
mov hr pm

// Initialize PC to point at list
//const LIST_START
mov ar pc


$BUCKET_SORT_START

// AR = PM[PC]
// HR = PM[PC + 1]
mov pc asr; incpc
mov pm ir; call @JTABLE

mov pc asr
mov pm hr

// Hash HR, partially hash AR.
// Result of HR-hash is in AR
// Result of AR-hash is in HR
irl; mov ar gr // PM[0xFF] = AR 
irl; reset asr
irl; mov gr pm
irl; mov pc asr // Set GR to pre-hash value of HR
irl; mov pm gr
irl
irl
and HASH_MASK

mov ar asr
mov pm lc; mov pm pc
incpc
mov pc pm
mov ar pc

$FIRST_INSERTION

incpc; bls @FIRST_INSERTION_END_BIGGEST

mov pc asr
mov pm ar
sub gr
adn gr; brn @FIRST_INSERTION_BOTTOM

mov gr pm; incpc

$FIRST_INSERTION_SHIFT
mov pc asr; bls @FIRST_INSERTION_END_NOTBIGGEST
mov pm gr
mov ar pm
mov gr ar; declc; incpc; bra @FIRST_INSERTION_SHIFT

$FIRST_INSERTION_BOTTOM
declc; bra @FIRST_INSERTION

$FIRST_INSERTION_END_BIGGEST
mov pc asr
mov gr pm

$FIRST_INSERTION_END_NOTBIGGEST

// Prepare second insertion (minimal bookkeeping)
mov hr ar
and HASH_MASK
mov ar asr
mov pm pc; mov pm lc
incpc; reset asr
mov pm gr
mov ar asr
mov pc pm
mov ar pc


$SECOND_INSERTION

incpc; bls @SECOND_INSERTION_END_BIGGEST

mov pc asr
mov pm ar
sub gr
adn gr; brn @SECOND_INSERTION_BOTTOM

mov gr pm; incpc

$SECOND_INSERTION_SHIFT
mov pc asr; bls @SECOND_INSERTION_END_NOTBIGGEST
mov pm gr
mov ar pm
mov gr ar; declc; incpc; bra @SECOND_INSERTION_SHIFT

$SECOND_INSERTION_BOTTOM
declc; bra @SECOND_INSERTION

$SECOND_INSERTION_END_BIGGEST
mov pc asr
mov gr pm

$SECOND_INSERTION_END_NOTBIGGEST
mov ir ar; mov ir pc
sub LIST_END_MODIFIED
brz @BUCKET_SORT_END; incpc
bra @BUCKET_SORT_START; incpc

$BUCKET_SORT_END


//call @BREAK


// Merge negative values
const NEGATIVE_END
mov ar hr
const NEGATIVE_START
mov ar pc
const LIST_START

$NEGATIVE_MERGE
mov pc ir
mov pc asr; incpc
mov pm lc
$NEGATIVE_MERGE_MOVE
mov pc asr; bls @NEGATIVE_MERGE_BOTTOM
mov pm gr
mov ar asr
add 1
mov gr pm; declc; incpc; bra @NEGATIVE_MERGE_MOVE

$NEGATIVE_MERGE_BOTTOM
mov ar gr
mov ir ar
sub hr
adn hr; brz @POSITIVE_MERGE_INIT
add BUCKET_SIZE
mov ar pc
mov gr ar; bra @NEGATIVE_MERGE




// Merge positive values
$POSITIVE_MERGE_INIT
const POSITIVE_END
mov ar hr
const POSITIVE_START
mov ar pc
mov gr ar   // Pop AR

$POSITIVE_MERGE
mov pc asr; incpc
mov pm lc
$POSITIVE_MERGE_MOVE
mov pc asr; bls @POSITIVE_MERGE_BOTTOM
mov pm gr
mov ar asr
add 1
mov gr pm; declc; incpc; bra @POSITIVE_MERGE_MOVE

$POSITIVE_MERGE_BOTTOM
mov ar gr
mov pc ar
and BUCKET_INDEX_TRACKER
sub hr
adn hr; brz @PROGRAM_END
adn BUCKET_SIZE
mov ar pc
mov gr ar; bra @POSITIVE_MERGE


$PROGRAM_END
$BREAK
halt




// Jump-table subroutine
$JTABLE
mov pm hr; bop


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
