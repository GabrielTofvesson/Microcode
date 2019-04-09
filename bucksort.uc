#define BUCKET_SIZE 0b1000
#define BUCKET_COUNT 15
#define LIST_START 0xE0
#define HASH_MASK 0b1111000

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


//// FOR TESTING PURPOSES ONLY ////

// TODO: Buckets store last index instead of length.

//// ---- Bucket sort ----

// Set PC to E0
const LIST_START
mov ar pc

$MOVE_TO_BUCKETS
mov pc asr; mov pc ar;
add pc; incpc; 
brz @MOVE_TO_BUCKETS_END 
mov pm ar; mov pm gr

// The hash
rol
rol
rol
rol
rol
rol
rol
and HASH_MASK

// Push PC
mov pc ir 

// Set current address to the hash.
mov ar asr
mov ar pc

// Increase length
// Compare loop
//  if a < b : keep looping
//  else: swap a and b and shift the rest one step
//  if at end, insert value and return.


// Length of loop, and set up PC for first list index
const 1
add pm; incpc
mov ar pm
sub pc
// Set loop counter
mov ar lc

$COMPARE_LOOP
bls @INSERT_LAST_ELEMENT
mov pc asr; incpc; declc   

// TODO: Make sure this is optimal
mov pm ar
sub gr
brn @COMPARE_LOOP
add gr; mov gr pm

mov pc asr; incpc; declc
// call @BREAK

$INSERT_LAST_ELEMENT
mov gr pm

// Pop PC
mov ir pc
bra @MOVE_TO_BUCKETS

// mov ar asr
// mov pc ir               // Push PC
// mov pm pc; add pm
// incpc
// mov pc pm
// mov ar asr
// mov gr pm
// mov ir pc               // Pop PC
// bra @MOVE_TO_BUCKETS

$MOVE_TO_BUCKETS_END
halt

// //// ---- Bubble sort ----
// 
// 
// $BUBBLE_YEET
// 
// mov pm ir; incpc
// 
// mov pc asr
// 
// 
// $SORT_LOOP
// mov pc hr // Current lowest index
// mov pm gr // Current lowest value
// 
// reset asr
// mov pc pm
// 
// $LOOP
// mov pc asr
// mov gr ar
// sub pm
// 
// // If PM < GR
// brn @CHECK
// mov pc hr // Current lowest index
// mov pm gr // Current lowest value
// 
// $CHECK
// incpc
// mov pc ar
// sub ir
// bnz @LOOP
// 
// reset asr
// mov pm pc
// mov pm asr; incpc
// mov pm ar
// mov gr pm
// mov hr asr
// mov ar pm
// reset asr
// mov pc pm
// declc
// bls @END_SORT
// bra @SORT_LOOP
// 
// $END_SORT
// halt

$BREAK
halt
