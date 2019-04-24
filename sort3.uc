#define LIST_START 0xE0
#define HASH_MASK 0b1111
#define FIRST_BUCKET 0x10   // Index of start of first bucket
#define LAST_BUCKET 0xD3    // Index of start of last bucket
#define BUCKET_SIZE 13      // Each bucket an hold 13 elements before spilling


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
reset ir // Point PC to start of list. Let MUX activate GR3

// Two values sorted per iteration, so half the iterations obv ;)
lcset 16

$BUCKET_SORT
declc; bls @MERGE_INIT

mov pc asr; incpc
mov pm ar; mov pm ir // Use whatever value we're sorting to index GR at complete random :)))))))
mov pc asr; incpc; incpc
mov pm hr

// Shift AR and HR
brl; mov pm gr
brl
brl
brl
and HASH_MASK // Completely hash value from HR
mov ar asr
mov pm ar
add 1
mov ar pm
mov ar asr
mov gr pm

mov hr ar
and HASH_MASK // Completely hash value from AR
mov ar asr
mov pm ar
add 1
mov ar pm
mov ar asr
mov ir pm

bra @BUCKET_SORT




$MERGE_INIT


$END

$BREAK
halt
