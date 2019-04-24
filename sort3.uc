#optable 0xf @BREAK
#amode 3 @BREAK


#define LIST_START 0xE0
#define HASH_MASK 0b1111
#define FIRST_BUCKET 0x10   // Index of start of first bucket
#define LAST_BUCKET 0xD3    // Index of start of last bucket
#define BUCKET_SIZE 13      // Each bucket an hold 13 elements before spilling

// LUT entries contain pointers to last element in bucket
// This allows the LUT to serve as both a jump-table and as bucket-headers
// Look at me being all resourceful and stuff, huh? Inb4 slowdowns ;))
#data 0x00 0x77
#data 0x01 0x84
#data 0x02 0x91
#data 0x03 0x9e
#data 0x04 0xab
#data 0x05 0xb8
#data 0x06 0xc5
#data 0x07 0xd2
#data 0x08 0x0f
#data 0x09 0x1c
#data 0x0a 0x29
#data 0x0b 0x36
#data 0x0c 0x43
#data 0x0d 0x50
#data 0x0e 0x5d
#data 0x0f 0x6a

const LIST_START
mov ar pc

// Two values sorted per iteration, so half the iterations obv ;)
// For consistency, we just decrement LC twice per iteration, though
// Had this course also stressed power use or other efficiency-related questions,
// we probably wouldn't decrement twice per iteration for the sole purpose of "clarity"
// But alas, Kent doesn't care, so why should we?
lcset 32

$BUCKET_SORT
bls @MERGE_INIT

mov pc asr; incpc
mov pm ar; mov pm ir // Use whatever value we're sorting to index GR at complete random
mov pc asr; incpc
mov pm hr

// Shift AR and HR
irl; mov pm gr
irl
irl
irl
and HASH_MASK // Completely hash value from HR
mov ar asr
mov pm ar
add 1
mov ar pm
mov ar asr
mov gr pm; declc // Mark element as sorted by decrementing LC

mov hr ar
and HASH_MASK // Completely hash value from AR
mov ar asr
mov pm ar
add 1
mov ar pm
mov ar asr
mov ir pm; declc // Mark element as sorted by decrementing LC

bra @BUCKET_SORT


//// ---- MERGE ---- ////
$MERGE_INIT

// HR points to LUT
// PC points to start of first bucket
// AR points to list
mov pc hr   // PC is always 0 after bucketsort because FF+1 mod 100 = 0. Imagine that!
const FIRST_BUCKET
mov ar pc
const LIST_START

$MERGE
mov ar ir
mov hr asr
sub pm
mov pc gr







// If this was not the last bucket, branch back to start of merge
sub LAST_BUCKET
adn LAST_BUCKET
bnz @MERGE


$END

$BREAK
halt
