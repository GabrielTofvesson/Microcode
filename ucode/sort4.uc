// Hi! If you're reading this, you probably want to know what this program does
// To that, I say: Good luck and I hope you have patience and a strong will to
// live, 'cause both will be negatively impacted by trying to read the code
// below.
// This isn't a joke; I feel like someone telling a person to get off the edge
// of a tall building here: reading the code below WILL negatively impact your
// life. You have been warned.

// For clarity's sake, I thought I'd add a small preface here:
// We use the optable as a replacement for a hashing algorithm. Check the
// #optable directives if you're wondering what bucket the 4 highest bits of a
// value end up pointing to. Each entry in the optable simply loads the
// address of the corresponding bucket and initiates an insertion sort for said 
// bucket.
// Labels ending in "_SPEC" are edge-case optimization labels. They are
// branched to in the case of special edge cases with the idea being that they
// are much faster than following the reguar code-path (even if said path would
// ultimately perform the same action).
// For example, "call @JTABLE_SPEC" invokes a special jumptable subroutine
// which parallelizes some of the boilerplate needed for the upcoming merge.


#define LIST_START 0xE0
#define LIST_END 0x00
#define HIGHEST_BUCKET 0xD2
#define BUCKET_SIZE 14
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

// Generate program memory:
//      Addresses 0xE0-0xFF ignored
//      Addresses that are a multiple of 0xE are set to 0
//      All other addresses contain a relative pointer to the next bucket start
#pmgen if address < 0xE0: print(str(address)+" "+str(0 if (address % 14) == 0 else ((address - (address % 0xE)) - 0xE) if address > 0xD else -1))


// Set all GR-registers to -1, so that we always can call "sub gr" to increment
// AR, no matter what value we have in IR ;)
const 0xB00         // GRx=10, M=11
lsr; mov ar ir
lsr; reset gr
lsr; reset grm
mov ar ir           // GRx=00, M=01
reset gr
reset grm


// Initialize PC to point at list
const LIST_START
mov ar pc
mov pc asr

// Perform bucketsort for 32 elements
#emit
>for i in range(31):
>  print("mov pm ir; incpc; call @JTABLE")
mov pm ir; call @JTABLE_SPEC


// Initialize state for merge
const HIGHEST_BUCKET
mov ar asr
mov pm lc
sub gr

// Do the merge thing
$MERGE
mov ar asr; declc; bls @MB_SPEC
mov pm ir
mov pc asr
mov ir pm; incpc
sub gr

// Copy elements to list
$MERGE_MOVE
mov ar asr; declc; bls @MB_SPEC
mov pm ir
mov pc asr                      // This branch improves stability
mov ir pm; incpc; bls @MERGE_BOTTOM  // Transfer value and copy more elements
sub gr; bra @MERGE_MOVE

$MERGE_BOTTOM
sub gr
mov ar asr

$MB_SPEC
mov pm ar; mov pm asr
sub gr
mov pm lc; bnz @MERGE

// Breakpoint hook and program termination point
$BREAK
$END
halt




// Jump-table subroutine
$JTABLE
mov pc hr; bop

$JTABLE_SPEC
const LIST_START
mov ar hr; bop


// Generate jump table
#emit
>bucket_size=14
>for i in range(16):
>  print("$OT_"+hex(i)[2::])
>  if i < 8:
>    print("const "+str(bucket_size*(7-i)))
>  else:
>    print("const "+str(bucket_size*(23-i)))
>  print("mov ar asr; bra @PREPARE_SORT")


// Actual bucketsort
$PREPARE_SORT
mov pm pc; mov pm lc                    // Load bucket length
sub gr; incpc                           // Increment bucket length
mov pc pm; bls @IE_SPEC                 // Store new length

mov ar pc; sub ar
sub ir // Save -IR into AR (you'll see why)


$INSERTION
mov pc asr; incpc; declc; bls @INSERTION_END_BIGGEST
add pm                  // Effectively, AR=PM-IR, except more like AR=-IR+PM
sub pm; brn @INSERTION

mov pm ar
mov ir pm; bls @IEN_SPEC

$INSERTION_SHIFT
mov pc asr
mov pm ir
mov ar pm; bls @INSERTION_END_NOTBIGGEST
mov ir ar; declc; incpc; bra @INSERTION_SHIFT

$IEN_SPEC
mov pc asr
mov ar pm; bra @INSERTION_END_NOTBIGGEST

$IE_SPEC
mov ar asr

$INSERTION_END_BIGGEST
mov ir pm

$INSERTION_END_NOTBIGGEST
mov hr pc
mov pc asr; ret
