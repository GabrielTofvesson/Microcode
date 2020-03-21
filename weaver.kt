import java.io.*

class MachineState {
    val programMemory = ShortArray(256)// PM
    val microMemory = IntArray(128)     // MyM
    val k1 = ByteArray(16)             // K1
    val k2 = ByteArray(4)              // K2
    var pc: Byte = 0.toByte()         // PC
    var asr: Byte = 0.toByte()        // ASR
    var ar: Short = 0.toShort()       // AR
    var hr: Short = 0.toShort()       // HR
    var gr0: Short = 0.toShort()      // GR0
    var gr1: Short = 0.toShort()      // GR0
    var gr2: Short = 0.toShort()      // GR0
    var gr3: Short = 0.toShort()      // GR0
    var ir: Byte = 0.toByte()         // IR
    var uPC: Byte = 0.toByte()        // MyPC
    var uSP: Byte = 0.toByte()        // SMyPC
    var lc: Byte = 0.toByte()         // LC

    override fun toString() = toString(false)
    fun toString(verilog: Boolean): String {
        val builder = StringBuilder()
        if(!verilog) builder.append("PM:\n")
        for(index in 0 until programMemory.size){
            if(verilog) builder.append("initial PM[").append(index).append("] = 16'h")
            else builder.append(index.toUHex()).append(": ")
            builder.append(programMemory[index].toUHex())
            if(verilog) builder.append(';')
            builder.append("\n")
        }
        
        if(!verilog) builder.append("\nMyM:\n")
        for(index in 0 until microMemory.size){
            if(verilog) builder.append("assign uPM[").append(index).append("] = 25'h")
            else builder.append(index.toUHex()).append(": ")
            builder.append(microMemory[index].toShortUHex())
            if(verilog) builder.append(';')
            builder.append("\n")
        }

        if(!verilog) builder.append("\nK1:\n")
        for(index in 0 until k1.size){
            if(verilog) builder.append("assign K1[").append(index).append("] = 7'h")
            else builder.append(index.toUHex()).append(": ")
            builder.append(k1[index].toUHex())
            if(verilog) builder.append(';')
            builder.append("\n")
        }
        
        if(!verilog) builder.append("\nK2:\n")
        for(index in 0 until k2.size){
            if(verilog) builder.append("assign K2[").append(index).append("] = 7'h")
            else builder.append(index.toUHex()).append(": ")
            builder.append(k2[index].toUHex())
            if(verilog) builder.append(';')
            builder.append("\n")
        }
        
        fun StringBuilder.regSet(name: String, value: Short) =
            if(verilog) append("initial ").append(name).append(" = ").append(value).append(";\n")
            else append('\n').append(name).append(":\n").append(value.toUHex())

        fun StringBuilder.regSet(name: String, value: Byte) =
            if(verilog) append("initial ").append(name).append(" = ").append(value).append(";\n")
            else append('\n').append(name).append(":\n").append(value.toUHex())

        fun StringBuilder.grSet(index: Int, value: Short) =
            if(verilog) append("initial GR[").append(index).append("] = ").append(value).append(";\n")
            else regSet("GR"+index, value)

        fun StringBuilder.irSet(value: Byte) =
            if(verilog) append("initial IR = ").append(value).append(";\n")
            else append("\nIR:\nb").append(value.toInt().or(1 shl 30).toString(2).substring(28))

        fun StringBuilder.uPCSet(value: Byte) =
            if(verilog) append("initial uPC = ").append(value).append(";\n")
            else append("\n\nMyPC:\n").append(value.toUHex())

        fun StringBuilder.uSPSet(value: Byte) =
            if(verilog) append("initial uSP = ").append(value).append(";\n")
            else append("\n\nSMyPC:\n").append(value.toUHex())

        fun StringBuilder.flagInit() =
            if(verilog) this
            else append("\n\nO_flag:\n\nC_flag:\n\nN_flag:\n\nZ_flag:\n\nL_flag:\nEnd_of_dump_file")

        return builder
            .regSet("PC", pc)
            .regSet("ASR", asr)
            .regSet("AR", ar)
            .regSet("HR", hr)
            .grSet(0, gr0)
            .grSet(1, gr1)
            .grSet(2, gr2)
            .grSet(3, gr3)
            .regSet("AR", ar)
            .irSet(ir)
            .uPCSet(uPC)
            .uSPSet(uSP)
            .append('\n').regSet("LC", lc)
            .flagInit()
            .toString()
    }

    companion object {
        fun parseState(rawState: String): MachineState {
            val state = MachineState()
            val lines = rawState.replace("\r", "").split("\n").toTypedArray()

            // Read PM
            for(index in 0 until 256)
                state.programMemory[index] = Integer.parseInt(lines[index + 1].substring(4), 16).toShort()

            // Read MyM
            for(index in 0 until 128)
                state.microMemory[index] = Integer.parseInt(lines[index + 3 + 256].substring(4), 16)
            
            // Read K1
            for(index in 0 until 16)
                state.k1[index] = Integer.parseInt(lines[index + 5 + 256 + 128].substring(4), 16).toByte()

            // Read K2
            for(index in 0 until 4)
                state.k2[index] = Integer.parseInt(lines[index + 7 + 256 + 128 + 16].substring(4), 16).toByte()
            
            state.pc = Integer.parseInt(lines[413], 16).toByte()
            state.asr = Integer.parseInt(lines[416], 16).toByte()
            state.ar = Integer.parseInt(lines[419], 16).toShort()
            state.hr = Integer.parseInt(lines[422], 16).toShort()
            state.gr0 = Integer.parseInt(lines[425], 16).toShort()
            state.gr1 = Integer.parseInt(lines[428], 16).toShort()
            state.gr2 = Integer.parseInt(lines[431], 16).toShort()
            state.gr3 = Integer.parseInt(lines[434], 16).toShort()
            state.ir = Integer.parseInt(lines[437].substring(1), 2).toByte()
            state.uPC = Integer.parseInt(lines[440], 16).toByte()
            state.uSP = Integer.parseInt(lines[443], 16).toByte()
            state.lc = Integer.parseInt(lines[446], 16).toByte()

            return state
        }
    }
}

fun error(message: String){
    System.err.println(message)
    println("Usage:\n\tkotlin WeaverKt [machineCodeFile] [outputFile]\nor\n\tkotlin WeaverKt [machineCodeFile] [inputState] [outputFile]")
    System.exit(1)
}

fun main(args: Array<String>){
    if(args.size > 4) error("Too many arguments!")
    if(args.size < 2) error("Too few arguments!")
    
    val weaveFile = File(args[0])
    if(!weaveFile.isFile) error("Given machine code file doesn't exist!")

    val state: MachineState

    val verilogOutput = args[args.size - 1] == "-v"

    if(args.size == 2 || (verilogOutput && args.size == 3)) state = MachineState()
    else{
        val file = File(args[1])
        if(file.isFile) state = MachineState.parseState(file.readText())
        else{
            System.err.println("Machine state file (${args[1]}) doesn't exist! Starting from scratch...")
            state = MachineState()
        }
    }

    val weaveData = weaveFile.readText().replace("\r", "").split("\n").toTypedArray()
    var weaveUCode = false
    var pIndex = 0
    var uIndex = 0
    fun index()= if(weaveUCode) uIndex else pIndex
    fun iIdx() {
        if(weaveUCode) ++uIndex
        else ++pIndex
    }
    fun sIdx(value: Int){
        if(weaveUCode) uIndex = value
        else pIndex = value
    }
    for(rawValue in weaveData){
        val value = {
            var v = rawValue.replace(" ", "").replace("\t", "")
            
            // Return
            if(v.indexOf("#") > 0) v.substring(0, v.indexOf("#")) else v
        }()
        
        if(value.length == 0) continue
        else if(value.startsWith("@")){
            if(value == "@u") weaveUCode = true
            else if(value == "@p") weaveUCode = false
            else if(value.startsWith("@k1")){
                // Parse K1 table entry
                if(value.length != 6)
                    error("Badly formatted K1 declaration: $rawValue")
                val index = value.substring(3, 4).toInt(16)
                val k1Value = value.substring(4, 6).toInt(16).toByte()
                if(k1Value < 0)
                    error("Invalid K1 address pointer (must be in range 00-7F): $rawValue")

                state.k1[index] = k1Value
            }
            else if(value.startsWith("@k2")){
                // Parse K2 table entry
                if(value.length != 6)
                    error("Badly formatted K2 declaration: $rawValue")

                val index = value.substring(3, 4).toInt(16)
                if(index > 4)
                    error("Invalid K2 index value (must be in range 0-3): $rawValue")


                val k2Value = value.substring(4, 6).toInt(16).toByte()
                if(k2Value < 0)
                    error("Invalid K2 address pointer (must be in range 00-7F): $rawValue")

                state.k2[index] = k2Value
            }
            else if(value.startsWith("@0x")) sIdx(Integer.parseInt(value.substring(3), 16))
            else sIdx(Integer.parseInt(value.substring(1), 10))

            continue
        }
        else if((weaveUCode && index() >= state.microMemory.size) || (!weaveUCode && index() >= state.programMemory.size)) error("Memory out of bounds: ${index()}! Did you pass too much data?")
        else if((weaveUCode && value.length != 7) || (!weaveUCode && value.length != 4)) error("Cannot weave data of bad length: $value")
        else try{
            if(weaveUCode) state.microMemory[index()] = Integer.parseInt(value, 16)
            else state.programMemory[index()] = Integer.parseInt(value, 16).toShort()
        }catch(e: NumberFormatException){
            error("Cannot weave non-hex data: $value")
        }
        iIdx()
    }

    val outputFile = if(!verilogOutput && args.size == 3) File(args[2]) else File(args[1])
    if(outputFile.isFile) outputFile.delete()
    outputFile.createNewFile()


    val machineData = state.toString(verilogOutput)
    outputFile.bufferedWriter().use{
        it.write(machineData, 0, machineData.length)
        it.flush()
    }
}

fun Short.toUHex() = toInt().and(0xFFFF.toInt()).or(1.shl(30)).toString(16).substring(4)
fun Int.toUHex() = and(0xFF).or(1.shl(30)).toString(16).substring(6)
fun Int.toShortUHex() = and((-1 ushr 7)).or(1.shl(30)).toString(16).substring(1)
fun Byte.toUHex() = toInt().and(0xFF.toInt()).or(1.shl(30)).toString(16).substring(6)
