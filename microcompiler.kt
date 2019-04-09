enum class ALU(val value: Int, val parameters: Int = 1) {
    NOP(0b0000, 0), // No operation
    MOV(0b0001),    // Move from bus to AR
    MVN(0b0010),    // Move inverse of bus to AR
    MVZ(0b0011, 0), // Set AR to zero
    ADD(0b0100),    // Add bus to AR
    SUB(0b0101),    // Subtract bus from AR
    AND(0b0110),    // Bitwise AND with bus and AR
    ORR(0b0111),    // Bitwise OR with bus and AR
    ADN(0b1000),    // Add bus to AR without setting flags
    LSL(0b1001, 0), // Logical shift left AR
    BSL(0b1010, 0), // Shift contents of (AR and HR) left (32-bit shift)
    ASR(0b1011, 0), // Arithmetic shift right
    BSR(0b1100, 0), // Signed big shift right
    LSR(0b1101, 0), // Logical shift right AR
    ROL(0b1110, 0), // Rotate AR left
    BRL(0b1111, 0); // Rotate ARHR left (32-bit rotate)

    companion object {
        fun locate(value: Int) = values().first{ it.value == value }
        fun matchName(name: String) = values().firstOrNull{ it.name.toLowerCase() == name.toLowerCase() }
    }
}


enum class ToBus(val value: Int) {
    NONE(0b000),
    IR(0b001),
    PM(0b010),
    PC(0b011),
    AR(0b100),
    HR(0b101),
    GR(0b110),
    CONST(0b111);

    companion object {
        fun locate(value: Int) = values().first{ it.value == value }
        fun matchName(name: String) = values().first{ it.name.toLowerCase() == name.toLowerCase() }
    }
}

enum class FromBus(val value: Int) {
    NONE(0b000),
    IR(0b001),
    PM(0b010),
    PC(0b011),
    // No AR
    HR(0b101),
    GR(0b110),
    ASR(0b111);

    companion object {
        fun locate(value: Int) = values().first{ it.value == value }
    }
}

enum class LoopCounter(val value: Int) {
    NONE(0b00),

    DEC(0b01),
    BUS(0b10),
    U(0b11);

    companion object {
        fun locate(value: Int) = values().first{ it.value == value }
    }
}

enum class SEQ(val value: Int) {
    INC(0b0000),
    CAL(0b0110),
    RET(0b0111),
    BRA(0b0101),
    BNZ(0b0100),
    BRZ(0b1000),
    BRN(0b1001),
    BRC(0b1010),
    BRO(0b1011),
    BLS(0b1100),
    BNC(0b1101),
    BNO(0b1110),
    HALT(0b1111);

    companion object {
        fun locate(value: Int) = values().first{ it.value == value }
        fun matchName(name: String) = values().firstOrNull{ it.name.toLowerCase() == name.toLowerCase() }
    }
}

open class MicroInstruction(private val _compiledValue: Int, val isConstInstr: Boolean = false) {
    constructor(
            aluOP: ALU,
            toBus: ToBus,
            fromBus: FromBus,
            muxControl: Boolean,
            increment: Boolean,
            lc: LoopCounter,
            seq: SEQ
    ): this((
            (aluOP.value shl 21) or
            (toBus.value shl 18) or
            (fromBus.value shl 15) or
            (muxControl.toBit() shl 14) or
            (increment.toBit() shl 13) or
            (lc.value shl 11) or
            (seq.value shl 7)
        ) and (-1 ushr 7))

    constructor(aluOP: ALU, toBus: ToBus): this(aluOP, toBus, FromBus.NONE, false, false, LoopCounter.NONE, SEQ.INC)
    constructor(aluOP: ALU, constant: Int): this((aluOP.value shl 21) or (ToBus.CONST.value shl 18) or (constant onlyBits 16), true)
    constructor(aluOP: ALU): this(aluOP, 0)
    constructor(toBus: ToBus, fromBus: FromBus): this(ALU.NOP, toBus, fromBus, false, false, LoopCounter.NONE, SEQ.INC)
    constructor(toBus: ToBus): this(ALU.NOP, toBus, FromBus.NONE, false, false, LoopCounter.BUS, SEQ.INC)
    
    var addressReference: AddressReference? = null

    val aluOP: ALU
        get() = ALU.locate(_compiledValue ushr 21 onlyBits 4)

    val toBus: ToBus
        get() = ToBus.locate(_compiledValue ushr 18 onlyBits 2)

    val fromBus: FromBus
        get() = FromBus.locate(_compiledValue ushr 15 onlyBits 2)
    
    val muxControl = _compiledValue.getBitAt(14)
    val increment = _compiledValue.getBitAt(13)

    val lc: LoopCounter
        get() = LoopCounter.locate(_compiledValue ushr 11 onlyBits 2)

    val seq: SEQ
        get() = SEQ.locate(_compiledValue ushr 7 onlyBits 4)

    val address = _compiledValue onlyBits 7

    val usesBus = isConstInstr || toBus != ToBus.NONE
    val readsBus = isConstInstr || fromBus != FromBus.NONE

    val needsUADR = isConstInstr || (lc == LoopCounter.U) || (seq.value in 0b0100..0b1110)
    private val rawValue: Int = _compiledValue onlyBits 25 or (if(addressReference == null || addressReference!!.actualAddress == -1) 0 else addressReference!!.actualAddress)
    val compiledValue: Int
        get(){
            if(addressReference != null && addressReference!!.actualAddress == -1)
                throw RuntimeException("Unresolved label reference: ${addressReference!!.labelName}")
            return _compiledValue onlyBits 25 or (if(addressReference == null) 0 else addressReference!!.actualAddress)
        }


    infix fun withReference(ref: AddressReference): MicroInstruction {
        addressReference = ref
        return this
    }
    
    infix fun withReference(name: String): MicroInstruction {
        addressReference = AddressReference.makeReference(name)
        return this
    }

    infix fun merge(uInstr: MicroInstruction?): MicroInstruction? {
        if(uInstr == null) return this
        if(isConstInstr || uInstr.isConstInstr) throw RuntimeException("CONST-instructions are fundamentally un-parallellizable")
        if(usesBus && uInstr.usesBus && (toBus != uInstr.toBus)) throw RuntimeException("Instructions cannot share bus (output)") // Instructions can't share bus
        if(readsBus && uInstr.readsBus && (fromBus != uInstr.fromBus)) throw RuntimeException("Instructions cannot share bus (input)") // Instructions cannot both read from bus to differing outputs
        if(seq != SEQ.INC && uInstr.seq != SEQ.INC && seq != uInstr.seq) throw RuntimeException("SEQ mismatch") // We can merge an INC with something else, but we cannot merge more than this
        if(needsUADR && uInstr.needsUADR && address != uInstr.address) throw RuntimeException("uADR mismatch") // Instructions cannot depend on differing uADR values

        val newInstr = MicroInstruction(rawValue or uInstr.rawValue)

        val adrRef = if(needsUADR) addressReference else if(uInstr.needsUADR) uInstr.addressReference else null
        if(adrRef != null && newInstr.needsUADR) newInstr withReference adrRef

        return newInstr
    }
}

enum class Register(val busValue: Int, val canRead: Boolean = true) {
    ASR(0b111, false),
    IR(0b001),
    PM(0b010),
    PC(0b011),
    AR(0b100),
    HR(0b101),
    GR(0b110);

    companion object {
        fun lookup(name: String) = values().firstOrNull{ it.name.toLowerCase() == name.toLowerCase() }
    }
}

class AddressReference{
    private val address: Int
    val labelName: String?

    private constructor(address: Int?, labelName: String?){
        this.address = address ?: -1
        actualAddress = this.address
        this.labelName = labelName
        if(address == null && labelName == null) throw RuntimeException("Reference must be accessible by name or address")
    }

    var actualAddress: Int
        private set

    private fun checkResolved(){
        if(actualAddress != -1) throw RuntimeException("Address already resolved")
    }

    fun resolveConstant(value: Int){
        checkResolved()
        actualAddress = value
    }

    fun resolveAddress(target: Int){
        if(target > 128 || target < 0) throw RuntimeException("Invalid target address")
        checkResolved()
        actualAddress = target
    }

    companion object {
        private val registry = ArrayList<AddressReference>()
        fun makeReference(address: Int) = AddressReference(address, null)
        fun makeReference(labelName: String): AddressReference {
            val ref = registry.firstOrNull{ it.labelName == labelName }
            if(ref != null) return ref
            val reference = AddressReference(null, labelName)
            registry.add(reference)
            return reference
        }
    }
}

fun Boolean.toBit() = if(this) 1 else 0
fun Int.toInstruction() = or(0x10000000).toString(16).substring(1)
infix fun Int.onlyBits(bits: Int) = and(-1 ushr (32 - bits))
fun Int.getBitAt(index: Int) = ushr(index).and(1) == 1

fun parseMOV(instr: String): MicroInstruction {
    val args = instr.split(" ")
    if(args.size != 3) throw RuntimeException("MOV instruction requires two arguments: $instr")
    if(args[1] == args[2]) throw RuntimeException("Cannot move from register being moved to: $instr")

    val a = Register.lookup(args[1])!!
    if(!a.canRead) throw RuntimeException("Cannot read from register: $instr")
    
    
    if(args[2] == "lc") return MicroInstruction(ToBus.locate(a.busValue))

    val b = Register.lookup(args[2])!!
    if(b == Register.AR) return MicroInstruction(ALU.MOV, ToBus.locate(a.busValue))

    return MicroInstruction(ToBus.locate(a.busValue), FromBus.locate(b.busValue))
}

fun readNumber(literal: String, max: Int): Int {
    val number = if(literal.startsWith("0") && literal.length > 1){ // Parse special number
        if(literal[1] == 'x') Integer.parseInt(literal.substring(2), 16)
        else if(literal[1] == 'b') Integer.parseInt(literal.substring(2), 2)
        else Integer.parseInt(literal.substring(1), 8)
    }else{
        Integer.parseInt(literal, 10)
    }

    if(number > max || number < 0) throw RuntimeException("Value out of range: $literal")

    return number
}

fun parseCONST(instr: String): MicroInstruction {
    val args = instr.split(" ").toTypedArray()
    if(args.size != 2) throw RuntimeException("Unexpected arguments: $instr")

    return MicroInstruction(ALU.MOV) withReference try{ AddressReference.makeReference(readNumber(args[1], 65535)) } catch(e: NumberFormatException){ AddressReference.makeReference(args[1]) }
}

fun parseALU(instr: String): MicroInstruction {
    val args = instr.split(" ")

    val aluOperation = ALU.matchName(args[0])!!

    if(args.size != (1 + aluOperation.parameters)) throw RuntimeException("Unexpected arguments: $instr")

    if(aluOperation.parameters == 0) return MicroInstruction(aluOperation, ToBus.NONE, FromBus.NONE, false, false, LoopCounter.NONE, SEQ.INC)

    try{
        val num = readNumber(args[1], 65535)
        return MicroInstruction(aluOperation, num)
    }catch(e: NumberFormatException){
        // NaN
    }

    val source = Register.lookup(args[1])
    if(source == null) return MicroInstruction(aluOperation) withReference AddressReference.makeReference(args[1])
    if(!source.canRead) throw RuntimeException("Cannot read from source: $instr")

    return MicroInstruction(aluOperation, ToBus.locate(source.busValue))
}

fun parseLabelReference(ref: String): AddressReference? {
    return if(ref.startsWith("@")) AddressReference.makeReference(ref.substring(1)) else null
}

fun parseCALL(instr: String): MicroInstruction {
    val args = instr.split(" ")
    if(args.size != 2) throw RuntimeException("Unexpected arguments: $instr")

    return MicroInstruction(ALU.NOP, ToBus.NONE, FromBus.NONE, false, false, LoopCounter.NONE, SEQ.CAL) withReference parseAddressReference(args[1])
}

fun parseBranch(instr: String): MicroInstruction {
    val args = instr.split(" ")
    if(args.size != 2) throw RuntimeException("Unexpected arguments: $instr")

    return MicroInstruction(ALU.NOP, ToBus.NONE, FromBus.NONE, false, false, LoopCounter.NONE, SEQ.matchName(args[0])!!) withReference parseAddressReference(args[1])
}

fun parseLCSet(instr: String): MicroInstruction {
    val args = instr.split(" ")
    if(args.size != 2) throw RuntimeException("Unexpected arguments: $instr")

    val ref = try{
        AddressReference.makeReference(readNumber(args[1], 0xFF))
    }catch(e: NumberFormatException){
        AddressReference.makeReference(args[1])
    }

    return MicroInstruction(ALU.NOP, ToBus.NONE, FromBus.NONE, false, false, LoopCounter.U, SEQ.INC) withReference ref
}

fun parseAddressReference(arg: String): AddressReference {
    return parseLabelReference(arg) ?: AddressReference.makeReference(readNumber(arg, 0xFF))
}

fun parseInstruction(line: String): MicroInstruction? {
    val subInstructions = line.split(";")
    if(subInstructions.size == 1){
        var shave = subInstructions[0].toLowerCase()
        while(shave.startsWith(" ") || shave.startsWith("\t")) shave = shave.substring(1)
        while(shave.endsWith(" ") || shave.endsWith("\t")) shave = shave.substring(0, shave.length - 1)

        if(shave.length == 0) return null

        if(shave.startsWith("mov ")) return parseMOV(shave)
        else if(shave.startsWith("const ")) return parseCONST(shave)
        else if(shave == "incpc") return MicroInstruction(ALU.NOP, ToBus.NONE, FromBus.NONE, false, true, LoopCounter.NONE, SEQ.INC)
        else if(ALU.matchName(shave.substring(0, if(shave.indexOf(" ") == -1) shave.length else shave.indexOf(" "))) != null) return parseALU(shave)
        else if(shave.startsWith("call ")) return parseCALL(shave)
        else if(shave == "ret") return MicroInstruction(ALU.NOP, ToBus.NONE, FromBus.NONE, false, false, LoopCounter.NONE, SEQ.RET)
        else if(shave.startsWith("b") && shave.indexOf(" ") != -1 && SEQ.matchName(shave.substring(0, shave.indexOf(" "))) != null) return parseBranch(shave)
        else if(shave == "halt") return MicroInstruction(ALU.NOP, ToBus.NONE, FromBus.NONE, false, false, LoopCounter.NONE, SEQ.HALT)
        else if(shave.startsWith("lcset")) return parseLCSet(shave)
        else if(shave == "declc") return MicroInstruction(ALU.NOP, ToBus.NONE, FromBus.NONE, false, false, LoopCounter.DEC, SEQ.INC)
        else throw RuntimeException("Unknown instruction: $shave")
    }else{
        var result: MicroInstruction? = null
        for(rawInstruction in subInstructions){
            val parsed = parseInstruction(rawInstruction)
            if(parsed == null) continue
            result = parsed merge result
            if(result == null) throw RuntimeException("Instructions ($line) could not be merged!")
        }
        return result!!
    }
}

fun error(message: String, line: Int){
    System.err.println("Error on line $line:\n\t$message")
    System.exit(1)
}

fun main(args: Array<String>){
    if(args.size != 1) throw RuntimeException("Bad arguments :(")
    val file = java.io.File(args[0])

    if(!file.isFile) throw RuntimeException("File not found :(")
    val builder = StringBuilder("@u\n")
    var currentLine = 0
    var lineCount = 0
    val insns = ArrayList<MicroInstruction>()
    println("@p")
    for(line in file.readText().replace("\r", "").split("\n")){
        ++lineCount
        try{
            val actualCode = (if(line.indexOf("//") != -1) line.substring(0, line.indexOf("//")) else line).toLowerCase()
            if(actualCode.length == 0) continue
    
            if(actualCode.startsWith("$")){
                AddressReference.makeReference(actualCode.substring(1)).resolveAddress(currentLine)
                continue
            }
    
            // Define compile-time constant
            if(actualCode.startsWith("#define ")){
                val substr = actualCode.substring(8)
                if(substr.indexOf(" ") == -1) throw RuntimeException("Bad compile-time constant definition: $actualCode")
                val name = substr.substring(0, substr.indexOf(" "))
                val value = substr.substring(substr.indexOf(" ") + 1).replace(" ", "").replace("\t", "")
                try{
                    val constant = readNumber(value, 65535)
                    
                    AddressReference.makeReference(name).resolveConstant(constant)
                    continue
                }catch(e: NumberFormatException){
                    throw RuntimeException("Cannot parse constant: $actualCode")
                }
            }

            // Define Program-Memory constants
            if(actualCode.startsWith("#data ")){
                fun err(): Nothing = throw RuntimeException("Bad program-memory state definition: $actualCode")
                val substr = actualCode.substring(6)
                if(substr.indexOf(" ") == -1) err()

                val address = substr.substring(0, substr.indexOf(" "))
                val constant = substr.substring(substr.indexOf(" ") + 1).replace(" ", "").replace("\t", "")

                try{
                    println("@0x${readNumber(address, 255).toString(16)}\n${readNumber(constant, 65535).or(1 shl 30).toString(16).substring(4)}")
                }catch(e: NumberFormatException){
                    err()
                }
                continue
            }
    
            val instr = parseInstruction(actualCode)
            if(instr == null) continue // Blank line
            insns.add(instr)
    
            ++currentLine
        }catch(e: Throwable){
            error(e.message ?: "Compilation failed with an unknown error", lineCount)
        }
    }
    if(currentLine > 127){
        System.err.println("Instruction count overflow: $currentLine instructions")
        System.exit(1)
    }

    System.err.println("INFO: Microcompilation succeeded! Instruction count: $currentLine")

    for(instr in insns)
        builder.append(instr.compiledValue.toInstruction()).append("\n")
    print(builder.toString())
}



