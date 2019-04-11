#define LIST_START 0xE0
#define HASH_MASK 0b1111

// PM initial state
#data 0x00 0x10
#data 0x01 0x1c
#data 0x02 0x28
#data 0x03 0x34
#data 0x04 0x40
#data 0x05 0x4c
#data 0x06 0x58
#data 0x07 0x64
#data 0x08 0x70
#data 0x09 0x7c
#data 0x0a 0x88
#data 0x0b 0x94
#data 0x0c 0xa0
#data 0x0d 0xac
#data 0x0e 0xb8
#data 0x0f 0xc4

#data 0x10 0x10
#data 0x1c 0x1c
#data 0x28 0x28
#data 0x34 0x34
#data 0x40 0x40
#data 0x4c 0x4c
#data 0x58 0x58
#data 0x64 0x64
#data 0x70 0x70
#data 0x7c 0x7c
#data 0x88 0x88
#data 0x94 0x94
#data 0xa0 0xa0
#data 0xac 0xac
#data 0xb8 0xb8
#data 0xc4 0xc4

// TODO: Include register initial-state compiler directive (saves, like, 2 cycles max)
// Set PC to LIST_START
const LIST_START
mov ar pc

bra @BUCKET_SORT_START





// 
// 
// //// ---- START OF DANK BUCKET SORT ---- ////
// $DANK_SORT_START
// 
// // Get value at index of PC and index of PC + 1
// // (ar = gr0 = data[pc]; hr = gr3 = data[pc + 1])
// mov pc asr
// mov pm ar; mov pm gr; incpc
// mov pc asr
// mov pm hr
// reset ir
// mov pm gr
// 
// bsl
// bsl
// bsl
// bsl
// bsl
// bsl
// bsl
// and HASH_MASK
// 
// 




//// ---- START OF NORMAL (TRASH) BUCKET SORT ---- ////
// Start of bucket sort loop
$BUCKET_SORT_START

// Dereference pc into AR and GR (data[pc_])
mov pc asr
mov pm ar; mov pm gr

// Hash: rotate left by 7 and only keep bits 3-6 (inclusive)
// This means we index on the highest 4 bits of the value
// and we have 3 bits of leniency: bucket size of 8
rol
rol
rol
rol; mov pc ir
and HASH_MASK
mov ar asr
mov pm hr
mov pm asr

mov pm pc; mov pm ar
incpc; sub hr
mov pc pm

// Prepare for insertion sort here:
// Compute length of bucket into LC
mov ar lc

// Save start index to PC (for fast dereferencing)
mov hr pc

// Start of nested insertion sort
$INSERTION_SORT_LOOP_START

// If LC is set, we've reached the end of the elements
bls @INSERTION_SORT_END_BIGGEST; incpc

// If(data[pc] < gr) continue;
mov pc asr
mov pm ar
sub gr
adn gr; brn @INSERTION_SORT_LOOP_BOTTOM

// Insert and shift here
mov gr pm

// Just shift all the elements
$INSERTION_SHIFT_LOOP
bls @INSERTION_SORT_END_NOT_BIGGEST
incpc
mov pc asr
mov pm gr
mov ar pm
mov gr ar; declc
bra @INSERTION_SHIFT_LOOP


$INSERTION_SORT_LOOP_BOTTOM
declc; bra @INSERTION_SORT_LOOP_START


// Jump here if gr wasn't inserted into list
$INSERTION_SORT_END_BIGGEST
mov pc asr
mov gr pm

// Jump here if we already inserted gr into list
$INSERTION_SORT_END_NOT_BIGGEST

//// ---- LOOP BOTTOM ---- ////
// Check if we should continue
mov ir pc
incpc
mov pc ar
sub 0
brz @BUCKET_SORT_END
bra @BUCKET_SORT_START
$BUCKET_SORT_END

// PC is 0 here. Data is sorted smallest-to largest in memory: just spread out into buckets ;)
// Perform final merge here

// Set PC to write index
const 0xE0
mov ar pc


// ######## INSERTION ########## 

// COPY NEGATIVE

// Initialize GR as bucket pointer and IR as element pointer
const 0xC4
mov ar gr

$LOOP_NEGATIVE
// Dereference GR into IR and compute length
mov gr asr
mov pm ir; mov pm ar

// Subtract start from end and save (the resultant length) into LC
sub gr
mov ar lc

// Copy 0x78 to initial list (0xE0)
$COPY_BUCKET_NEGATIVE
bls @NEXT_BUCKET_NEGATIVE

mov ir asr; mov ir ar
mov pm hr

sub 1
mov ar ir

// Write value to be copied into write index (data[pc] = data[ir])
mov pc asr
mov hr pm; incpc; declc
bra @COPY_BUCKET_NEGATIVE
$NEXT_BUCKET_NEGATIVE

mov gr ar
sub 0x0C // AR is one above the length, so sub 8.
mov ar gr
sub 0x7C
bnz @LOOP_NEGATIVE


// COPY POSITIVE
const 0x10
mov ar gr

$LOOP_POSITIVE
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

// Copy 0x78 to initial list (0xE0)
$COPY_BUCKET_POSITIVE
bls @NEXT_BUCKET_POSITIVE

mov ir asr; mov ir ar
mov pm hr

add 1
mov ar ir

// Write value to be copied into write index (data[pc] = data[ir])
mov pc asr
mov hr pm; incpc; declc
bra @COPY_BUCKET_POSITIVE
$NEXT_BUCKET_POSITIVE

mov gr ar
add 0x0C // AR is one above the length, so sub 8.
mov ar gr
sub 0x88
bnz @LOOP_POSITIVE

$BREAK
halt
