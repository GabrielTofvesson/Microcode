#define LIST_START 0xE0
#define HASH_MASK 0b1111000

// PM initial state
#data 0x00 0x00
#data 0x08 0x08
#data 0x10 0x10
#data 0x18 0x18
#data 0x20 0x20
#data 0x28 0x28
#data 0x30 0x30
#data 0x38 0x38
#data 0x40 0x40
#data 0x48 0x48
#data 0x50 0x50
#data 0x58 0x58
#data 0x60 0x60
#data 0x68 0x68
#data 0x70 0x70
#data 0x78 0x78

// Set PC to LIST_START
const LIST_START
mov ar pc


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
rol
rol
rol
rol
and HASH_MASK
mov ar hr

// Dereference AR (HR) into AR (ar = buckets[ar])
mov hr asr
mov pm ar

// Increment element end-index stored in program memory
add 1
mov ar pm

// Push PC
mov pc ir


// Prepare for insertion sort here:

// Compute length of bucket into LC
sub hr
mov ar lc

// Save start index to PC (for fast dereferencing)
mov hr pc; declc

// Start of nested insertion sort
$INSERTION_SORT_LOOP_START

// If LC is set, we've reached the end of the elements
bls @INSERTION_SORT_END_BIGGEST

// Increment check index
incpc

// If(data[pc] < gr) continue;
mov pc asr
mov pm hr; mov pm ar
sub gr
brn @INSERTION_SORT_LOOP_BOTTOM

// Insert and shift here
mov gr pm

// Just shift all the elements
$INSERTION_SHIFT_LOOP
bls @INSERTION_SORT_END_NOT_BIGGEST
incpc
mov pc asr
mov pm gr
mov hr pm
mov gr hr; declc
bra @INSERTION_SHIFT_LOOP


$INSERTION_SORT_LOOP_BOTTOM
declc; bra @INSERTION_SORT_LOOP_START


// Jump here if gr wasn't inserted into list
$INSERTION_SORT_END_BIGGEST
incpc
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

call @BREAK

// Set PC to write index
const 0xE0
mov ar pc


// ######## INSERTION ########## 

// COPY NEGATIVE

// Initialize GR as bucket pointer and IR as element pointer
const 0x78
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
sub 0x08 // AR is one above the length, so sub 8.
mov ar gr
sub 0x38
bnz @LOOP_NEGATIVE


// COPY POSITIVE
const 0x00
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
add 0x08 // AR is one above the length, so sub 8.
mov ar gr
sub 0x40
bnz @LOOP_POSITIVE

call @BREAK

$BREAK
halt
