import java.io.*

enum class OpCode(val opcode: Int, val useM: Boolean, val useADR: Boolean, val useReg: Boolean = true) {
	LOAD(0, true, true),
	STORE(1, true, true),
	ADD(2, true, true),
	SUB(3, true, true),
	AND(4, true, true),
	LSR(5, true, true),
	BRA(6, false, true),
	BNE(7, false, true),
	CMP(8, true, false),
	BEQ(9, false, true),
	HALT(15, false, false, false);

    companion object {
        fun fromString(name: String) = OpCode.values().firstOrNull{ it.name == name }
    }
}

enum class Mode(val id: Int) {
	DIRECT(0), IMMEDIATE(1), INDIRECT(2), INDEXED(3)
}

abstract class Instruction(val words: Int) {
	abstract fun getData(insns: Iterable<Instruction>): ShortArray
}

class Label(val name: String): Instruction(0) {
	override fun getData(insns: Iterable<Instruction>) = ShortArray(0)
}

class Operation(val code: OpCode, val reg: Int, val m: Mode, val adr: AddressReference, val immediate: Short? = null): Instruction(if(m == Mode.IMMEDIATE) 2 else 1) {
	constructor(code: OpCode, reg: Int): this(code, reg, Mode.DIRECT, AddressReference(0)){
        if(code.useM || code.useADR)
            throw IllegalArgumentException("Not enough parameters specified for instruction: ${code.name}")
    }
    constructor(code: OpCode, m: Mode, adr: AddressReference, immediate: Short? = null): this(code, 0, m, adr, immediate){
        if(code.useReg)
            throw IllegalArgumentException("Not enough parameters specified for instruction: ${code.name}")
    }
    constructor(code: OpCode): this(code, 0, Mode.DIRECT, AddressReference(0)){
        if(code.useM || code.useADR || code.useReg)
            throw IllegalArgumentException("Not enough parameters specified for instruction: ${code.name}")
    }

    init {
        if(m == Mode.IMMEDIATE && immediate == null)
            throw IllegalArgumentException("No immediate argument passed!")
    }
	
	override fun getData(insns: Iterable<Instruction>): ShortArray {
		val array = ShortArray(words)
        array[0] = code.opcode
    			.and(0b1111)
    			.shl(12)
    			.or(
    				if(code.useReg) reg.and(0b11).shl(10)
    				else 0
    			)
    			.or(
    				if(code.useM) m.id.and(0b11).shl(8)
    				else 0
    			)
    			.or(
    				if(code.useADR) adr.getAddress(insns).and(0b11111111)
    				else 0
    			)
    			.toShort()
        if(m == Mode.IMMEDIATE) array[1] = immediate!!

        return array
	}
}

class AddressReference(private val label: Label?, private val absolute: Int?) {
	constructor(label: Label): this(label, null)
	constructor(absolute: Int): this(null, absolute)

	fun getAddress(insns: Iterable<Instruction>): Int {
		if(absolute != null) return absolute
		var addrOff = 0
        for(insn in insns)
			if(insn == label) return addrOff
			else addrOff += insn.words
		
        throw RuntimeException("Found reference to undeclared label!")
	}
}

class CompilationUnit {
    private val instructions = ArrayList<Instruction>()
    private val labels = ArrayList<Label>()

    fun declareLabel(name: String) {
        if(instructions.firstOrNull{ it is Label && it.name == name } != null)
            throw IllegalStateException("Attempt to declare the same label twice!")
        registerInstruction(getLabel(name))
    }
    
    fun getLabel(name: String): Label {
        if(labels.firstOrNull{ it.name == name } == null)
            labels.add(Label(name))
        return labels.first{ it.name == name }
    }

    fun registerInstruction(insn: Instruction){
        instructions.add(insn)
    }

    fun compile(): ShortArray {
        var dat = 0
        for(insn in instructions)
        	dat += insn.words
        
        if(dat > 256)
            throw RuntimeException("Instruction overflow")
    
        val rawData = ShortArray(dat)
        var index = 0
    
        for(insn in instructions)
            for(short in insn.getData(instructions))
                rawData[index++] = short
    
        return rawData
    }
}

enum class ArgType {
    REG, LABEL, INDEX, NUMBER
}

fun parseRegister(arg: String): Int? {
    if(!arg.toUpperCase().startsWith("GR")) return null
    try{
        val reg = Integer.parseInt(arg.substring(2))
        if(reg > 3 || reg < 0)
            throw IllegalArgumentException("Register index out of range!")
        return reg
    }catch(e: NumberFormatException){
        throw IllegalArgumentException("Invalid register value")
    }
}

fun parseLabelReference(arg: String, unit: CompilationUnit): Pair<Label, Mode>? {
    if(arg.length < 2 || Character.isDigit(arg[1])) return null
    if(arg.startsWith("@")) return unit.getLabel(arg.substring(1)) to Mode.DIRECT
    if(arg.startsWith("*")) return unit.getLabel(arg.substring(1)) to Mode.INDIRECT
    return null
}

fun parseIndex(arg: String): Pair<Int, Mode>? {
    if(arg.startsWith("[") && arg.endsWith("]")){
        val literal = arg.substring(1, arg.length - 1)
        return parseNumber(literal) to Mode.INDEXED
    }
    return null
}

fun parseNumber(literal: String): Int {
    return if(literal.startsWith("0") && literal.length > 1){
                    when(literal[1]){
                        'x' -> Integer.parseInt(literal.substring(2), 16)
                        'b' -> Integer.parseInt(literal.substring(2), 2)
                        else -> Integer.parseInt(literal.substring(2), 8)
                    }
                }else{
                    Integer.parseInt(literal)
                }
}

fun checkProperSize(number: Int, max: Int): Int {
    if(number > max || number < 0)
        throw IllegalArgumentException("Parsed value out of range!")
    return number
}

fun parseNumberLiteral(arg: String): Pair<Int, Mode>? {
    if(arg.startsWith("$")) return checkProperSize(parseNumber(arg.substring(1)), 65535) to Mode.IMMEDIATE
    if(arg.startsWith("*")) return checkProperSize(parseNumber(arg.substring(1)), 255) to Mode.INDIRECT
    return try{
        checkProperSize(parseNumber(arg), 255) to Mode.DIRECT
    }catch(e: NumberFormatException){
        null
    }
}

fun parseInstruction(line: String, unit: CompilationUnit): Instruction? {
    if(line.length == 0) return null
    if(line.replace(" ", "").endsWith(":")){
        val label = line.substring(0, line.length - 1)
        if(label.toUpperCase().startsWith("GR") || label.startsWith("$") || label.startsWith("*") || label.startsWith("@"))
            throw IllegalArgumentException("Label uses reserved prefix")
        return unit.getLabel(label)
    }
    val firstSpace = line.indexOf(" ")
    if(firstSpace == -1){
        val opcode = OpCode.fromString(line.toUpperCase())
        if(opcode == null)
            throw IllegalArgumentException("Unknown instruction: $line")
        if(opcode.useReg || opcode.useADR || opcode.useM)
            throw IllegalArgumentException("Not enough arguments passed to $line")
        return Operation(opcode)
    }else{
        val opcode = OpCode.fromString(line.substring(0, firstSpace).toUpperCase())
        if(opcode == null)
            throw IllegalArgumentException("Unknown instruction: $line")
        val args = line.substring(firstSpace + 1).replace(" ", "").split(",").toTypedArray()
        when(args.size){
            1 -> {
                var arg = parseArguments(args[0], null, unit)
                return when(arg.first.first){
                    ArgType.REG -> Operation(opcode, arg.first.second as Int)
                    ArgType.LABEL -> Operation(opcode, (arg.first.second as Pair<Label, Mode>).second, AddressReference((arg.first.second as Pair<Label, Mode>).first))
                    ArgType.INDEX -> Operation(opcode, (arg.first.second as Pair<Int, Mode>).second, AddressReference((arg.first.second as Pair<Int, Mode>).first))
                    ArgType.NUMBER -> if((arg.first.second as Pair<Int, Mode>).second == Mode.IMMEDIATE)
                                            Operation(opcode, (arg.first.second as Pair<Int, Mode>).second, AddressReference(0), (arg.first.second as Pair<Int, Mode>).first.toShort())
                                        else Operation(opcode, (arg.first.second as Pair<Int, Mode>).second, AddressReference((arg.first.second as Pair<Int, Mode>).first))
                }
            }
            2 -> {
                val arg = parseArguments(args[0], args[1], unit)
                val first = arg.first
                val second = arg.second!!
                
                if(first.first != ArgType.REG)
                    throw IllegalArgumentException("First argument must be a register")

                return when(second.first){
                    ArgType.REG -> Operation(opcode, first.second as Int, Mode.values()[second.second as Int], AddressReference(0), 0)
                    ArgType.LABEL -> Operation(opcode, first.second as Int, (second.second as Pair<Label, Mode>).second, AddressReference((second.second as Pair<Label, Mode>).first))
                    ArgType.NUMBER -> if((second.second as Pair<Int, Mode>).second == Mode.IMMEDIATE)
                                            Operation(opcode, first.second as Int, (second.second as Pair<Int, Mode>).second, AddressReference(0), (second.second as Pair<Int, Mode>).first.toShort())
                                        else Operation(opcode, first.second as Int, (second.second as Pair<Int, Mode>).second, AddressReference((second.second as Pair<Int, Mode>).first))
                    ArgType.INDEX -> Operation(opcode, first.second as Int, (second.second as Pair<Int, Mode>).second, AddressReference((second.second as Pair<Int, Mode>).first))
                }
            }
            else -> throw IllegalArgumentException("Too many arguments specified")
        }
    }
}

fun parseArgument(arg: String, unit: CompilationUnit): Pair<ArgType, Any>? {
    var resolve: Any? = parseRegister(arg)
    if(resolve != null)  return ArgType.REG to resolve
    resolve = parseIndex(arg)
    if(resolve != null)  return ArgType.INDEX to resolve
    resolve = parseLabelReference(arg, unit)
    if(resolve != null)  return ArgType.LABEL to resolve
    resolve = parseNumberLiteral(arg)
    if(resolve != null)  return ArgType.NUMBER to resolve

    return null // Unresolved
}

fun parseArguments(arg0: String, arg1: String?, unit: CompilationUnit): Pair<Pair<ArgType, Any>, Pair<ArgType, Any>?> {
    val resolve0 = parseArgument(arg0, unit)
    if(resolve0 == null) throw IllegalArgumentException("Invalid argument: $arg0")
    
    val resolve1 = if(arg1 != null) parseArgument(arg1, unit) else null
    if(arg1 != null && resolve1 == null) throw IllegalArgumentException("Invalid argument: $arg0")
    
    return resolve0 to resolve1
}

fun parseInstructions(fileData: String): ShortArray {
    val unit = CompilationUnit()
    val lines = fileData.replace("\r", "").replace("\t", "").split('\n').toTypedArray()
    for(index in lines.indices){
        val commentIndex = lines[index].indexOf("#")
        if(commentIndex > 0)
            lines[index] = lines[index].substring(0, commentIndex)
        try{
            val insn = parseInstruction(lines[index], unit)
            if(insn != null) unit.registerInstruction(insn)
        }catch(e: Exception){
            print("An error occurred when compiling (line $index)")
            val message = e.message
            if(message != null) print(":\n\t$message")
            println()
        }
    }
    return unit.compile()
}

fun main(args: Array<String>){
	// Ensure correct argument length 'n stuff
	if(args.size != 1){
		System.err.println("Invalid argument length!")
		System.exit(-1)
	}

	val file = File(args[0])

	// Make sure we have a valid file
	if(!file.isFile){
		System.err.println("Given file doesn't exist!")
		System.exit(-2)
	}
    for(insn in parseInstructions(file.readText()))
        println(insn.toUHex())
}


fun Short.toUHex() = toInt().and(0xFFFF.toInt()).or(1.shl(30)).toString(16).substring(4)
