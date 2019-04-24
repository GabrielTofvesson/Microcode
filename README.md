# LMIA advanced development kit

This project was developed as a simple development kit for programming and
microprogramming the LMIA system.


## μASM instruction set

### NOP
No-operation. This wastes one clock cycle


### MOV [regA] \[regB\]
Move value in *regA* to *regB*

*This operation uses the bus*

*If regB is LC, no other LC operation can be specified in the same cycle*


### MVN {[reg] | [const]}
Move the inverse of a value (from register or constant) into register **AR**.

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*


### MVZ
Set **AR** to zero.

*Sets flags: Z, N*


### ADD {[reg] | [const]}
Add value (from register or constant) to register **AR**.

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*

*Sets flags: Z, N, O, C*


### SUB {[reg] | [const]}
Subtract value (from register or constant) from register **AR**.

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*

*Sets flags: Z, N, O, C*


### AND {[reg] | [const]}
Perform bitwise AND with given value (from register or constant) and register
**AR**. *reg* is ignored and only prevalent due to a microcompiler quirk;
expect it to be removed in future releases.

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*

*Sets flags: Z, N*


### ORR {[reg] | [const]}
Perform bitwise Or with given value (from register or constant) and register
**AR**.

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*

*Sets flags: Z, N*



### ADN {[reg] | [const]}
Add value (from register or constant) to register **AR** without updating
flags.

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*


### LSL
Performs a logical shift left of **AR**.

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*

*Sets flags: Z, N, C*


### ISL
Performs a logical shift left of **AR** and **HR** as if they were one 32-bit
register where **AR** corresponds to the most-significant bits.

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*

*Sets flags: Z, N, C*


### ASR
Performs an arithmetic shift right on **AR**.

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*

*Sets flags: Z, N, C*


### ISR
Performs an arithmetic shift right of **AR** and **HR** as if they were one
32-bit register where **AR** corresponds to the most-significant bits.

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*

*Sets flags: Z, N, C*


### LSR
Performs a logical shift right of **AR**.

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*

*Sets flags: Z, N, C*


### ROL
Performs an arithmetic rotate right on **AR**.

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*

*Sets flags: Z, N, C*


### IRL
Performs an arithmetic shift left of **AR** and **HR** as if they were one
32-bit register where **AR** corresponds to the most-significant bits.

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*

*Sets flags: Z, N, C*


### LCSET [const]
Set **LC** to value of constant.


### CONST [const]
Set **AR** to value of cosntant.

*This operation cannot be parallelized*


### INCPC
Increment value in **PC** by one.


### DECLC
Decrement value in **LC** by one.


### CALL [label]
Move value in **uPC** to **uSP** (**MySPC**) and set value in **uPC** to point
to the address of the given label.


### RET
Move value in **uSP** (**MySPC**) into **uPC**.


### HALT
Stop execution and set value in **uPC** to 0.


### BRA [label]
Perform an unconditional branch to the address of the given label.


### BNZ [label]
Branch to address of label if **Z-flag** is 0.


### BRZ [label]
Branch to address of label if **Z-flag** is 1.


### BRN [label]
Branch to address of label if **N-flag** is 1.


### BRC [label]
Branch to address of label if **C-flag** is 1.


### BRO [label]
Branch to address of label if **O-flag** is 1.


### BLS [label]
Branch to address of label if **L-flag** is 1.


### BNC [label]
Branch to address of label if **C-flag** is 0.


### BNO [label]
Branch to address of label if **O-flag** is 0.


### BOP
Branch to address specified by entry in optable pointed to by highest 4 bits
in IR.


### BAM
Branch to address specified by entry in addressing mode pointed to by M-bits in
IR.


### BST
Branch to start. This sets value in **uPC** to 0.


### RESET [reg]
Sets all bits in the specified register to 1.

*This operation uses the bus*


## Compiler/weaver directives

### \#define \[name] [const]
Define a compile-time constant. This will replace all (valid) constant
declarations with the given name with the value supplied here.

**NOTE**: Constant names are case-insensitive; i.e. *FOO* and *foo* are
functionally indistinguishable to the compiler.


### \#data \[address] [const]
Define an initial value in the program memory at the given address.


### $[label]
Define a compile-time label at the given position in the microprogram. Labels
can be referenced using an '@' symbol.

For example: *$BAR* would declare a label *BAR* which can be referenced with
*@BAR*.

**NOTE**: Label names are case-insensitive; i.e. @*FOO* and @*foo* are
functionally indistinguishable to the compiler.


### \#optable \[index] {[label] | [const]}
Declare an entry in the opcode jump table (K1).

**NOTE**: The given index must be at most 15 and at least 0 and in the case of
a constant being supplied as the value, this value my not be negative nor be
greater than 127.


### \#amode \[index] {[label] | [const]}
Declare an entry in the addressing mode jump table (K2).

**NOTE**: The given index must be at most 3 and at least 0 and in the case of
a constant being supplied as the value, this value my not be negative nor be
greater than 127.


## Flags
Flags - *aside from L* - are set based on ALU operations, so they depend on
**AR** and the **BUS**. Henceforth, unless otherwise implied or stated, **AR**
will refer to the state/value of **AR** *after* an ALU operation.

### Z
Set if **AR** == **0**

### N
Set if sign bit in **AR** is set.

### O
Set if sign of **AR** differs from signs of both **AR** and **BUS** *before*
the arithmetic operation.

### C
Set if **AR** is less than or equal to **AR** *before* the arithmetic
operation.

### L
Set if **LC** == 0.


## Sorting algorithms
For the sorting competition, we have chosen to focus on implementing bucketsort
with an inline insertionsort when inserting values into corresponding buckets.

### bucksort.uc

This was the first attempt at a sorting implementation in uASM. It doesn't do
more than a simple hash and possibly updating some bucket-specific values.
Nonetheless, it formed a clear basis for future implementations.

Pros:
* N/A

Cons:
* N/A

Average cycle count: N/A


### bsrt.uc

The first successful uASM bucketsort implementation. It uses the aforementioned
inline insertionsort. Additionally, it employs a lookup table for pointing to
buckets; this had the benefit of significantly decreasing the cycles required
to hash values, as well as allowing for buckets of sizes other than even
exponents of 2 (as opposed to other implementations). On top of this, it used a
parallel-hashing system which allowed the rotation step of the hash algorithm
to be applied to two elements of the list (to be sorted) at once, further
decreasing the amount of cycles required to perform a hash (per element).

Pros:
* Variable bucket size
* Arbitrary bucket arrangement
* Parallel-hash implementation
* Uses the most recent merge algorithm (rated around 400 cycles)

Cons:
* Heavy bookkeeping due to lookup table paired with parallel-hash
* Inefficiency in merge due to lookup table (average loss of 80 cycles)

Average cycle count: 1250


### sort2.uc

A second iteration of the *bsrt* implementation, this one refines the dual-hash
by omitting the lookup table. This means that bookkeeping can be minimized, as
it was only necessary due to a lack of available registers. This, of course,
comes at the cost of not being able to have variable-sized buckets; i.e. their
sizes must an exponent of 2. A minor optimization that was created for this
algorithm was the hash-based bookkeeping, wherein a small optimization to
bookkeeping could be done during the hashing of the list elements. Any
bookkeeping which does not require the ALU can, in fact, be performed during the
hashing, since the rotation steps only require AR and HR to be untouched. All
other operations are permitted.

Pros:
* Merge: (320-330 cycles)
    * Direct addressing fits optimally due to register limitations
    * Optimized regster allocations
* Minimal bookkeeping since it is mostly performed during the hashing operation

Cons:
* Bucket sizes must be exponents of 2
* Fixed bucket indices based on hash
* Two merge operations required (negative + positive)
* 95 unused program-memory addresses

Average cycle count: 1100


### sort3.uc

A third iteration of the *bsrt* implementation: this time entirely scrapping
the bucket header, opting to delegate this behaviour to the lookup-table itself.
I.e. the lookup table no long points to the start of a bucket (as this can be
inferred later), but rather points to the last element of the bucket.
Additionally, this implementation scraps the insertion-sort performed in the
bucket sort, delegating this task to the merge stage of the sorting algorithm.

Pros:
* Constant-time bucket sort (406 cycles)
* More optimally used LUT
* No bookkeeping during bucket-sort

Cons:
* Non-constant-time merge
* Optimized LUT requires marginally more arithmetic operations over other variants

Average cycle count: N/A (not fully implemented)


### bsrt2.uc

A fourth iteration developed in parallel with *sort3* as a proof-of-concept of
the recently designed lookup-table replacement for hashing. This version is an
almost direct copy of *bsrt*, except without a LUT, a K1 jump-table and absolute
sizes in the bucket headers (as opposed to a pointer to the last element of a
bucket).

Pros:
* Highly optimized K1 jump-table
* Subroutined jump-table for possible reuse elsewhere
* 13 elements per bucket (+1 over *bsrt*)
* Low instruction count

Cons:
* Only sorts one element per iteration

Average cycle count: 1050
