#define LIST_START 0xE0
#define HASH_MASK 0b1111000
#define NEGATIVE_START 0x40
#define NEGATIVE_END 0x78
#define POSITIVE_START 0x00
#define POSITIVE_END 0x38
#define BUCKET_SIZE 8


// Set up buckets (with absolute sizes)
// Bucket count: 16
// Bucket size: 8
// Motivation: direct mapping from hash to bucket at the cost of bucket size (-6 per bucket)
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



// Initialize PC to point at list
const LIST_START
mov ar pc


$BUCKET_SORT_START

// AR = PM[PC]
// HR = PM[PC + 1]
mov pc asr
mov pc ir; incpc
mov pm ar
mov pc asr
mov pm hr

// Hash HR, partially hash AR.
// Result of HR-hash is in AR
// Result of AR-hash is in HR
brl; mov hr gr
brl
brl
brl
brl
brl
brl
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
incpc
mov pc pm
mov ar pc
mov ir asr
mov pm gr



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
sub 0xFE
brz @BUCKET_SORT_END; incpc
bra @BUCKET_SORT_START; incpc

$BUCKET_SORT_END



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




$POSITIVE_MERGE_INIT
const POSITIVE_END
mov ar hr
const POSITIVE_START
mov ar pc
mov gr ar   // Pop AR

$POSITIVE_MERGE
mov pc ir
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
mov ir ar
sub hr
adn hr; brz @PROGRAM_END
add BUCKET_SIZE
mov ar pc
mov gr ar; bra @POSITIVE_MERGE


$PROGRAM_END
$BREAK
halt
