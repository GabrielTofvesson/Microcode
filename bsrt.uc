#define LIST_START 0xE0
#define HASH_MASK 0b1111

// PM initial state
#data 0x00 0x70
#data 0x01 0x7c
#data 0x02 0x88
#data 0x03 0x94
#data 0x04 0xa0
#data 0x05 0xac
#data 0x06 0xb8
#data 0x07 0xc4
#data 0x08 0x10
#data 0x09 0x1c
#data 0x0a 0x28
#data 0x0b 0x34
#data 0x0c 0x40
#data 0x0d 0x4c
#data 0x0e 0x58
#data 0x0f 0x64

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







//// ---- START OF NORMAL (TRASH) BUCKET SORT ---- ////
// Start of bucket sort loop

// $BUCKET_SORT_START
// 
// // Dereference pc into AR and GR (data[pc_])
// mov pc asr
// mov pm ar; mov pm gr
// 
// // Hash: rotate left by 7 and only keep bits 3-6 (inclusive)
// // This means we index on the highest 4 bits of the value
// // and we have 3 bits of leniency: bucket size of 8
// rol
// rol
// rol
// rol; mov pc ir
// and HASH_MASK
// mov ar asr
// mov pm hr
// mov pm asr
// 
// mov pm pc; mov pm ar
// incpc; sub hr
// mov pc pm
// 
// // Prepare for insertion sort here:
// // Compute length of bucket into LC
// mov ar lc
// 
// // Save start index to PC (for fast dereferencing)
// mov hr pc
// 
// // Start of nested insertion sort
// $INSERTION_SORT_LOOP_START
// 
// // If LC is set, we've reached the end of the elements
// bls @INSERTION_SORT_END_BIGGEST
// 
// 
// // If(data[pc] < gr) continue;
// mov pc asr
// mov pm ar
// sub gr
// adn gr; brn @INSERTION_SORT_LOOP_BOTTOM
// 
// // Insert and shift here
// mov gr pm
// 
// // Just shift all the elements
// $INSERTION_SHIFT_LOOP
// bls @INSERTION_SORT_END_NOT_BIGGEST
// incpc
// mov pc asr
// mov pm gr
// mov ar pm
// mov gr ar; declc
// bra @INSERTION_SHIFT_LOOP
// 
// 
// $INSERTION_SORT_LOOP_BOTTOM
// declc; bra @INSERTION_SORT_LOOP_START
// 
// 
// // Jump here if gr wasn't inserted into list
// $INSERTION_SORT_END_BIGGEST
// mov pc asr
// mov gr pm
// 
// // Jump here if we already inserted gr into list
// $INSERTION_SORT_END_NOT_BIGGEST
// 
// //// ---- LOOP BOTTOM ---- ////
// // Check if we should continue
// mov ir pc; mov ir ar
// incpc
// sub 0xFF
// brz @BUCKET_SORT_END
// bra @BUCKET_SORT_START
$BUCKET_SORT_END




// PC is 0 here. Data is sorted smallest-to largest in memory: just spread out into buckets ;)
// Perform final merge here

// Set PC to write index
const 0xE0
mov ar pc


// ######## INSERTION ########## 

// COPY NEGATIVE

// Initialize GR as bucket pointer and IR as element pointer
const 0x10
mov ar gr

// $LOOP_NEGATIVE
// // Dereference GR into IR and compute length
// mov gr asr
// mov pm ir; mov pm ar
// 
// // Subtract start from end and save (the resultant length) into LC
// sub gr
// mov ar lc
// 
// // Copy 0x78 to initial list (0xE0)
// $COPY_BUCKET_NEGATIVE
// bls @NEXT_BUCKET_NEGATIVE
// 
// mov ir asr; mov ir ar
// mov pm hr
// 
// add 1
// mov ar ir
// 
// // Write value to be copied into write index (data[pc] = data[ir])
// mov pc asr
// mov hr pm; incpc; declc
// bra @COPY_BUCKET_NEGATIVE
// $NEXT_BUCKET_NEGATIVE
// 
// mov gr ar
// add 0x0C // AR is one above the length, so sub 8.
// mov ar gr
// sub 0x70
// bnz @LOOP_NEGATIVE






// COPY POSITIVE

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
add 0x0C
mov ar gr
sub 0xD0
bnz @LOOP_POSITIVE


$BREAK
halt
