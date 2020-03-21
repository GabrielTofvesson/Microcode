# LMIA advanced development kit

This project was developed as a simple development kit for programming and
microprogramming the LMIA system.


## μASM instruction set

### NOP
No-operation. This wastes one clock cycle.


### MOV [regA] \[regB\]
Move value in *regA* to *regB*

*This operation uses the bus*

*If regB is [**LC**](#lc), no other [**LC**](#lc) operation can be specified in the
same cycle*


### MVN {[reg] | [const]}
Move the inverse of a value (from register or constant) into register
[**AR**](#ar).

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*


### MVZ
Set [**AR**](#ar) to zero.

*Sets flags: [**Z**](#z), [**N**](#n)*


### ADD {[reg] | [const]}
Add value (from register or constant) to register [**AR**](#ar).

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*

*Sets flags: [**Z**](#z), [**N**](#n), [**O**](#o), [**C**](#c)*


### SUB {[reg] | [const]}
Subtract value (from register or constant) from register [**AR**](#ar).

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*

*Sets flags: [**Z**](#z), [**N**](#n), [**O**](#o), [**C**](#c)*


### AND {[reg] | [const]}
Perform bitwise AND with given value (from register or constant) and register
**AR**. *reg* is ignored and only prevalent due to a microcompiler quirk;
expect it to be removed in future releases.

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*

*Sets flags: [**Z**](#z), [**N**](#n)*


### ORR {[reg] | [const]}
Perform bitwise Or with given value (from register or constant) and register
**AR**.

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*

*Sets flags: [**Z**](#z), [**N**](#n)*



### ADN {[reg] | [const]}
Add value (from register or constant) to register [**AR**](#ar) without
updating flags.

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*


### LSL
Performs a logical shift left of [**AR**](#ar).

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*

*Sets flags: [**Z**](#z), [**N**](#n), [**C**](#c)*


### ISL
Performs a logical shift left of [**AR**](#ar) and [**HR**](#hr) as if they
were one 32-bit register where [**AR**](#ar) corresponds to the
most-significant bits.

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*

*Sets flags: [**Z**](#z), [**N**](#n), [**C**](#c)*


### ASR
Performs an arithmetic shift right on [**AR**](#ar).

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*

*Sets flags: [**Z**](#z), [**N**](#n), [**C**](#c)*


### ISR
Performs an arithmetic shift right of [**AR**](#ar) and [**HR**](#hr) as if
they were one 32-bit register where [**AR**](#ar) corresponds to the
most-significant bits.

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*

*Sets flags: [**Z**](#z), [**N**](#n), [**C**](#c)*


### LSR
Performs a logical shift right of [**AR**](#ar).

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*

*Sets flags: [**Z**](#z), [**N**](#n), [**C**](#c)*


### ROL
Performs an arithmetic rotate right on [**AR**](#ar).

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*

*Sets flags: [**Z**](#z), [**N**](#n), [**C**](#c)*


### IRL
Performs an arithmetic shift left of [**AR**](#ar) and [**HR**](#hr) as if they
were one 32-bit register where [**AR**](#ar) corresponds to the
most-significant bits.

*This operation uses the bus*

*If a constant is passed, this operation cannot be parallellized*

*Sets flags: [**Z**](#z), [**N**](#n), [**C**](#c)*


### LCSET [const]
Set [**LC**](#lc) to value of constant.


### CONST [const]
Set [**AR**](#ar) to value of cosntant.

*This operation cannot be parallelized*


### INCPC
Increment value in [**PC**](#pc) by one.


### DECLC
Decrement value in [**LC**](#lc) by one.


### CALL [label]
Move value in [**uPC**](#upc) to [**uSP**](#usp) and set value in [**uPC**](#upc) to point
to the address of the given label.


### RET
Move value in [**uSP**](#usp) into [**uPC**](#upc).


### HALT
Stop execution and set value in [**uPC**](#upc) to **0**.


### BRA [label]
Perform an unconditional branch to the address of the given label.


### BNZ [label]
Branch to address of label if [**Z-flag**](#z) is **0**.


### BRZ [label]
Branch to address of label if [**Z-flag**](#z) is **1**.


### BRN [label]
Branch to address of label if [**N-flag**](#n) is **1**.


### BRC [label]
Branch to address of label if [**C-flag**](#c) is **1**.


### BRO [label]
Branch to address of label if [**O-flag**](#o) is **1**.


### BLS [label]
Branch to address of label if [**L-flag**](#l) is **1**.


### BNC [label]
Branch to address of label if [**C-flag**](#c) is **0**.


### BNO [label]
Branch to address of label if [**O-flag**](#o) is **0**.


### BOP
Branch to address specified by entry in optable pointed to by highest **4** bits
in [**IR**](#ir).


### BAM
Branch to address specified by entry in addressing mode pointed to by M-bits in
[**IR**](#ir).


### BST
Branch to start. This sets value in [**uPC**](#upc) to **0**.


### RESET [reg]
Sets all bits in the specified register to **1**.

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

For example: `$BAR` would declare a label *BAR* which can be referenced with
`@BAR`.

**NOTE**: Label names are case-insensitive; i.e. `@FOO` and `@foo` are
functionally indistinguishable to the compiler.


### \#optable \[index] {[label] | [const]}
Declare an entry in the opcode jump table (**K1**).

**NOTE**: The given index must be at most 15 and at least 0 and in the case of
a constant being supplied as the value, this value my not be negative nor be
greater than 127.


### \#amode \[index] {[label] | [const]}
Declare an entry in the addressing mode jump table (**K2**).

**NOTE**: The given index must be at most 3 and at least 0 and in the case of
a constant being supplied as the value, this value my not be negative nor be
greater than 127.


### \#pmgen [python]
Define a script to be run for each address in program memory. This can be used
to generate program memory value mappings more efficiently than manually
defining values. The script is run in a for-loop with the index variable
`address`. I.e. the variable `address` can be used in the specified script to
refer to the current program memory address. To emit a value, simply print a
string in the format "\[address] [value]" where the value can be in the range
-32768 to 65535 (inclusive).


### \#emit
Define a script to emit uASM code at compile-time. Each following line preceded
by a `>` will be included in the script; the first line not preceded by `>`
(or EOF) will define the end of the script. To emit code, simply print the code
that should be emitted.

Example:

```
mov ar asr
#emit
>for i in range(4):
>  print("lsl; mov ar ir")
>  print("add pm")
sub gr
```

the above code will be converted into the the following code by the preprocessor:

```
mov ar asr
lsl; mov ar ir
add pm
lsl; mov ar ir
add pm
lsl; mov ar ir
add pm
lsl; mov ar ir
add pm
sub gr
```


## Flags
Flags - *aside from [**L**](#l)* - are set based on ALU operations, so they depend
on [**AR**](#ar) and the **BUS**. Henceforth, unless otherwise implied or
stated, [**AR**](#ar) will refer to the state/value of [**AR**](#ar) *after* an
ALU operation. Flags retain their state until an instruction which is declared
as modifying said flag is executed.

### Z
Set if [**AR**](#ar) == **0**.

### N
Set if sign bit in [**AR**](#ar) is set.

### O
Set if sign of [**AR**](#ar) differs from signs of both [**AR**](#ar) *before*
the arithmetic operation and of the **BUS**.

### C
Set if [**AR**](#ar) is less than or equal to [**AR**](#ar) *before* the
arithmetic operation.

### L
Set if [**LC**](#lc) == **0**.


## Registers
Available registers for read/write operations are documented below. Unless
otherwise specified, the registers are directly accessible via the bus for read
and write operations.

### AR
The accumulator register. This register can only be written to as the result of
an ALU operation. This is to say, that AR is indirectly writable via the ALU,
but is nonetheless directly readable via the bus.

### PM
The program-memory pseudo-register allows you to read/write values from the
currently accessed program memory address (see [**ASR**](#asr-1)).

### ASR
The address register; this register is used to specify which address of
program-memory to be accessible via [**PM**](#pm).

**NOTE**: This register cannot be read.

### HR
The help register. This is a general-purpose register which is useful for
storing ephemeral or intermediate values during a computation.

### IR
The instruction register. This register offers extra functionality such as
**K1**- and **K2**-table addressing via the **OP** and **M** bits respectively.
The **GRx** and **M** bits can also be used to address a specific general
register via the **GR** multiplexer (see [**GR**](#gr)).

The bit-level layout of IR (from MSB to LSB) is as follows:

* **OP** : 4 bits (machine instruction). Can be used to jump to a
microinstruction address given by **K1** at the index specified by **OP**

* **GRx**: 2 bits (GR multiplexer selector)

* **M**  : 2 bits (Addressing mode)

* **ADR**: 8 bits (ASR address argument)

### GR
This is a shorthand for accessing the general register currently made available
by the GR multiplexer when said MUX is controlled by the **GRx** bits in
[**IR**](#ir).

**NOTE**: Only one GR can be accessed per cycle. Which register this is (of
the four available registers) is determined by the value in [**IR**](#ir).

### GRM
This is a shorthand for accessing the general register currently made available
by the GR multiplexer when said MUX is controlled by the **M** bits in
[**IR**](#ir).

**NOTE**: Only one GR can be accessed per cycle. Which register this is (of
the four available registers) is determined by the value in [**IR**](#ir).

### LC
The loopcounter register is a special register that can only be modified in
three ways: all three ways are dictated by the L-field in the microprogram.
Additionally, the counter can remain unchanged by simply not specifying an
action to take for the register. The three ways of modifying it are as follows:

* Decrement counter by one. The corresponding uASM instruction for this is
`declc`
* Load value from bus. The uASM instruction being `mov [reg] LC`
* Load a 7-bit constant from micromemory. The uASM instruction for this is
`lcset [const]`

**NOTE**: LC cannot be read and can only be written to as detailed above. The
value in LC can, though, to some degree be inferred from the [**L-flag**](#l)
(see [*Flags*](#flags)).

### PC
The program counter. This register is only 8 bits wide. Writing a value larger
than 8 bits to this register will simply truncate the binary string to 8 bits.
Attemping to read a value from PC to a register of a larger width will result
in the value in PC populating the lowesr 8 bits and the rest being filled with
0's.

### uPC
The microprogram counter; sometimes also referred to as **MyPC**. This register
cannot directly be read. It can, though, be written to in a variety of ways.
These have been specified as *branch* instructions (such as [`BRA`](#bra-label)), as
well as subroutine instructions (such as [`ret`](#ret)).

**NOTE**: This register is not connected to the bus.

### uSP
The microstack pointer; sometimes also referred to as **MySPC**. This register
cannot be directly read or written to. To write to it, a call to a subroutine
must be issued (using [`call [label]`](#call-label)). The only way to "read" this
register is to issue a subroutine-return instruction ([`ret`](#ret)) which
copies the value in this register to [**uPC**](#upc).

**NOTE**: This register is not connected to the bus. The value in this register
cannot be directly acted upon insofar as it cannot be directly read or copied
to any other register than [**uPC**](#upc), meaning that the actual value in
this register (and consequently in [**uPC**](#upc) aswell) cannot be directly
accessed or transformed. I.e. the value in this register cannot be copied to,
for example, a general register and thus, its value can only be inferred, not
directly measured.


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

**Average cycle count: N/A**


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

**Average cycle count: 1250**


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

**Average cycle count: 1100**


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

**Average cycle count: N/A (not fully implemented)**


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

**Average cycle count: 1050**


### sort4.uc

A fifth iteration of the common bucketsort algorithm. This one is, as its name
implies, based on the *sort2* algorithm. It improves upon it by making heavy
use of the `call` and `ret` instructions. I.e. by moving the entire bucketsort
implementation to a subroutine, it effectively allows 16 calls to sort values
per iteration of the outermost loop. This conversion to a subroutine is done at
zero cost to performance, as it exploits the fact that a call to a jumptable-
based hashing algorithm is made and rather than returning to the algorithm
after the hashing has taken place, the hash-table simply jumps to the
insertionsort immediately, after which a `ret` is used to return back to normal
execution. This has the effect of reducing a bucketsort of a single value be
two instructions to dereference the value to sort, during which a call to the
subroutine is made and after sorting, it continues execution at the instruction
immediately after the dereference.

Pros:
* Optimized K1 jump-table with inline bucketsort
* Highly un-rollable bucketsort implementation
* Highly efficient bus use (almost always saturated)
* Dynamic bucket placement, allowing for very fast merge operations
* Efficient use of general registers to reduce arithmetic operations requiring
constant values

Cons:
* Maximum of 6 elements per bucket
* 96 unused program-memory addresses (+1 per bucket)

**Average cycle count: 758**
