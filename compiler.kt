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
	HALT(15, false, false, false)
}

enum class Mode(val id: Int) {
	DIRECT(0), IMMEDIATE(1), INDIRECT(2), INDEXED(3)
}

interface Instruction {
	fun getData(insns: Iterable<Instruction>): Short
}

class Label(val name: String): Instruction {
	override fun getData(insns: Iterable<Instruction>) = 0.toShort()
}

class Immediate(val data: Short): Instruction {
	override fun getData(insns: Iterable<Instruction>) = data
}

class Operation(val code: OpCode, val reg: Int, val m: Mode, val adr: AddressReference): Instruction {
	constructor(val code: OpCode): this(code, 0, Mode.DIRECT, AddressReference(0))
	
	override fun getData(insns: Iterable<Instruction>): Short {
		return code.opcode
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
	}
}

class AddressReference(private val label: Label?, private val absolute: Int?) {
	constructor(label: Label): this(label, null)
	constructor(absolute: Int): this(null, absolute)

	fun getAddress(insns: Iterable<Instruction>): Int {
		if(absolute != null) return absolute
		insns.forEachIndexed{ index, insn ->
			if(insn == label)
				return@getAddress index*2
		}

		throw RuntimeException("Label cannot be found in set of instructions!")
	}
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

	val insns = ArrayList<Instruction>()
	insns.add(Operation(OpCode.LOAD, 0, Mode.DIRECT, AddressReference(1337)))
	insns.add(Operation(OpCode.HALT))

}


