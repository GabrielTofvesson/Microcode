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

    override fun toString(): String {
        val builder = StringBuilder("PM:\n")
        for(index in 0 until programMemory.size)
            builder.append(index.toUHex()).append(": ").append(programMemory[index].toUHex()).append("\n")
        
        builder.append("\nMyM:\n")
        for(index in 0 until microMemory.size)
            builder.append(index.toUHex()).append(": ").append(microMemory[index].toShortUHex()).append("\n")

        builder.append("\nK1:\n")
        for(index in 0 until k1.size)
            builder.append(index.toUHex()).append(": ").append(k1[index].toUHex()).append("\n")
        
        builder.append("\nK2:\n")
        for(index in 0 until k2.size)
            builder.append(index.toUHex()).append(": ").append(k2[index].toUHex()).append("\n")
        
        return builder
            .append("\nPC:\n")
            .append(pc.toUHex())
            .append("\n\nASR:\n")
            .append(asr.toUHex())
            .append("\n\nAR:\n")
            .append(ar.toUHex())
            .append("\n\nHR:\n")
            .append(hr.toUHex())
            .append("\n\nGR0:\n")
            .append(gr0.toUHex())
            .append("\n\nGR1:\n")
            .append(gr1.toUHex())
            .append("\n\nGR2:\n")
            .append(gr2.toUHex())
            .append("\n\nGR3:\n")
            .append(gr3.toUHex())
            .append("\n\nIR:\nb")
            .append(ir.toInt().or(1 shl 30).toString(2).substring(28))
            .append("\n\nMyPC:\n")
            .append(uPC.toUHex())
            .append("\n\nSMyPC:\n")
            .append(uSP.toUHex())
            .append("\n\nLC:\n")
            .append(lc.toUHex())
            .append("\n\nO_flag:\n\nC_flag:\n\nN_flag:\n\nZ_flag:\n\nL_flag:\nEnd_of_dump_file")
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

inline fun error(message: String){
    System.err.println(message)
    println("Usage:\n\tkotlin WeaverKt [machineCodeFile] [outputFile]\nor\n\tkotlin WeaverKt [machineCodeFile] [inputState] [outputFile]")
    System.exit(1)
}

fun main(args: Array<String>){
    if(args.size > 3) error("Too many arguments!")
    if(args.size < 2) error("Too few arguments!")
    
    val weaveFile = File(args[0])
    if(!weaveFile.isFile) error("Given machine code file doesn't exist!")

    val state: MachineState

    if(args.size == 2) state = MachineState()
    else{
        val file = File(args[1])
        if(file.isFile) state = MachineState.parseState(file.readText())
        else{
            error("Machine state file (${args[1]}) doesn't exist!")
            state = MachineState()
        }
    }

    val weaveData = weaveFile.readText().replace("\r", "").split("\n").toTypedArray()
    var index = 0
    var weaveUCode = false
    for(rawValue in weaveData){
        val value = rawValue.replace(" ", "").replace("\t", "")
        
        if(value.length == 0 || value.startsWith("#")) continue
        else if((weaveUCode && index >= state.microMemory.size) || (!weaveUCode && index >= state.programMemory.size)) error("Program memory out of bounds! Did you pass too much data?")
        else if(value.startsWith("@")){
            if(value == "@u"){
                weaveUCode = true
                index = 0

            }
            else if(value.startsWith("@0x")) index = Integer.parseInt(value.substring(3), 16)
            else index = Integer.parseInt(value.substring(1), 10)
            --index
        }
        else if((weaveUCode && value.length != 7) || (!weaveUCode && value.length != 4)) error("Cannot weave data of bad length: $value")
        else try{
            if(weaveUCode) state.microMemory[index] = Integer.parseInt(value, 16)
            else state.programMemory[index] = Integer.parseInt(value, 16).toShort()
        }catch(e: NumberFormatException){
            error("Cannot weave non-hex data: $value")
        }
        ++index
    }

    val outputFile = if(args.size == 3) File(args[2]) else File(args[1])
    if(outputFile.isFile) outputFile.delete()
    outputFile.createNewFile()


    val machineData = state.toString()
    outputFile.bufferedWriter().use{ it.write(machineData, 0, machineData.length) }
}

fun Short.toUHex() = toInt().and(0xFFFF.toInt()).or(1.shl(30)).toString(16).substring(4)
fun Int.toUHex() = and(0xFF).or(1.shl(30)).toString(16).substring(6)
fun Int.toShortUHex() = and((-1 ushr 7)).or(1.shl(30)).toString(16).substring(1)
fun Byte.toUHex() = toInt().and(0xFF.toInt()).or(1.shl(30)).toString(16).substring(6)
