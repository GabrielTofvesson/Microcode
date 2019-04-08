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


### BSL
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


### BSR
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


### BRL
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
Stop execution and set value int **uPC** to 0.


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

**NOTE**: Label names are case-insensitive; i.e. *@FOO* and *@foo* are
functionally indistinguishable to the compiler.


## Flags
Flags - *aside from L* - are set based on ALU operations, so they depend on
**AR** and the **BUS**. Henceforth, unless otherwise implied or stated, **AR**
will refer to the state/value of **AR** *after* an ALU operation.

### Z
Set if **AR** == **BUS**

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
