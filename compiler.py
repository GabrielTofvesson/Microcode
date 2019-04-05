#!/usr/bin/python
#
# Compiles ED-Assembly to Machinecode
#

# LOAD    GRx, ADR
# STORE   GRx, ADR
# ADD     GRx, ADR
# SUB     GRx, ADR
# AND     GRx, ADR
# LSR     GRx, Y # STEG
# BRA     ADR
# BNE     ADR
# BEQ     ADR
# CMP     GRx, GRy

#
#   One machine instruction
#   OOOO  RR MM AAAA AAAA
#   PPPP  PPPP  PPPP PPPP
#
#   O - Opcode
#   R - Register
#   M - The address mode
#   A - The address (or zero if M is 01)
#   P - Operand (only there if M is 01)
#

from sys import stdin, stdout, argv, exit

class Data:
    def __init__(self, string):
        self.length = len(string) // 4
        if not (len(string) % 4):
            self.length += 1

        self.data = [int(x, base=16) for x in string] 

    def to_hex(self):
        """
        Convert the instruction to a hex string.
        """
        code = "".join(hex(x)[2:] for x in self.data)
        return ('0' * (self.length - len(code))) + code

    def to_bin(self):
        """
        Convert the instruction to a binary string.
        """
        result = []
        for x in self.data:
            c = bin(x)[2:]
            result.append(('0' * (4 - len(c))) + c)
        return "".join(result)


class Instruction:
    """
    Hold the information about each instruction in its
    raw and processed form, to make debugging easier.
    """

    tag = ""
    operand = 0
    address = 0

    def __init__(self, opcode, register, mode, value):
        self.opcode = opcode
        self.register = register
        self.mode = mode
        self.length = int(mode == ADDRESS_MODES["IMMEDIATE"]) + 1
        if type(value) == str:
            self.tag = value
        elif self.length == 2:
            self.operand = value
        else:
            self.address = value

    def bake(self, link_table):
        if self.tag:
            if not self.tag in link_table:
                raise SyntaxError("Cannot find definition of {}".format(self.tag))
            if self.length == 2:
                self.operand = link_table[self.tag]
            else:
                self.address = link_table[self.tag]
        
        assert (self.opcode & 0xFF)     == self.opcode
        assert (self.register & 0xF)    == self.register
        assert (self.mode & 0xF)        == self.mode
        assert (self.address & 0xFF)    == self.address
        assert (self.operand & 0xFFFF)  == self.operand

        self.instruction = self.opcode << 12 | self.register << 10 | self.mode << 8 | self.address
        if self.length == 2:
            self.instruction = self.instruction << 16 | self.operand
       
    def to_hex(self):
        """
        Convert the instruction to a hex string.
        """
        if self.length == 1:
            length = WORD_SIZE // 4
        else:
            length = WORD_SIZE // 2
        code = hex(self.instruction)[2:]
        return ('0' * (length - len(code))) + code

    def to_bin(self):
        """
        Convert the instruction to a binary string.
        """
        if self.length == 1:
            length = WORD_SIZE // 1
        else:
            length = WORD_SIZE * 2
        code = bin(self.instruction)[2:]
        return ('0' * (length - len(code))) + code


OPCODE_TABLE = {   
    "LOAD"  : 0b0000,
    "STORE" : 0b0001,
    "ADD"   : 0b0010,
    "SUB"   : 0b0011,
    "AND"   : 0b0100,
    "LSR"   : 0b0101,
    "BRA"   : 0b0110,
    "BNE"   : 0b0111,
    "CMP"   : 0b1000,
    "BEQ"   : 0b1001,
    "BLT"   : 0b1010,
    "CMI"   : 0b1011,
    "HALT"  : 0b1111,
}

ADDRESS_MODES = {
    "DIRECT"    : 0b00,
    "IMMEDIATE" : 0b01,
    "INDIRECT"  : 0b10,
    "INDEXED"   : 0b11,
}

REGISTERS = {
    "GR0" : 0,
    "GR1" : 1,
    "GR2" : 2,
    "GR3" : 3,
}

WORD_SIZE = 16

input_file = False
output_file = False
output_format = "hex"
newlines = True

#
# Parse the arguments
#

if argv[1:]:
    for arg in argv[1:]:
        if arg.startswith('-'):
            if "-h" == arg or "--hex" == arg:
                output_format = "hex"
                continue
            if "-b" == arg or "--bin" == arg:
                output_format = "bin"
                continue
            if "--new-lines" == arg:
                newlines = True
                continue
            if "--no-new-lines" == arg:
                newlines = False
                continue
        else:
            if not input_file:
                input_file = open(argv[1])
                continue
            if not output_file:
                output_file = open(argv[1])
                continue

if not input_file:
    input_file = stdin

if not output_file:
    output_file = stdout

#
# Parser 
#

def parse_number(string):
    """
    Parse the string as a number. 

    Accepts hexadecimal, decimal, binary and taggs, which
    are later parsed to a number when all tags are known.
    """
    if string[0] == "@":
        return string[1:] # It will be a number...
    try:
        if len(string) > 2 and string[1] == 'b':
            return int(string[2:], base=2)
        elif len(string) > 2 and string[1] == 'x':
            return int(string[2:], base=16)
        return int(string)
    except:
        raise SyntaxError("{} is not a valid number.".format(string))

def parse_operand(operand):
    """
    Parse out the argument of the operation.
    """
    if operand[0] == '*':
        if operand[1] == '*':
            n = parse_number(operand[2:])
            mode = ADDRESS_MODES["INDIRECT"]
        else:
            n = parse_number(operand[1:])
            mode = ADDRESS_MODES["DIRECT"]
        if type(n) == str or (n & 0xFF) == n:
            return n, mode
        raise SyntaxError("{} does not fit in 16 bits.".format(n))
    if operand[0] == '[' and operand[-1] == ']':
        return parse_number(operand[1:-1]), ADDRESS_MODES["INDEXED"]
    n = parse_number(operand)
    if type(n) == str or (n & 0xFFFF) == n:
        return n, ADDRESS_MODES["IMMEDIATE"]
    raise SyntaxError("{} does not fit in 32 bits.".format(n))

def parse_instruction(args):
    """ 
    Parse an assembly instruction into an instruction object.
    """
    if args[0] in ["HALT"]:
        return Instruction(OPCODE_TABLE[args[0]], 0, 0, 0)
    if args[0] in ["LOAD", "STORE", "ADD", "SUB", "AND", "LSR"]:
        return parse_tripple_instuction(args)
    if args[0] in ["BRA", "BNE", "BEQ", "BLT"]:
        return parse_jump(args)
    if args[0] in ["CMP"]:
        return parse_dual_registers(args)
    if args[0] in ["CMI"]:
        return parse_compare_imediate(args)
    else:
        print("Foregotten instruction: ", args[0])
        assert False

def parse_compare_imediate(args):
    if len(args) < 3:
        raise SyntaxError("Not enough arguments.")
    if len(args) > 3:
        raise SyntaxError("Trash at end of line \"{}\"".format(" ".join(args[3:])))
    opcode = OPCODE_TABLE[args[0]]
    if args[1].upper() not in REGISTERS:
        raise SyntaxError("Invalid register name" + args[1])
    register = REGISTERS[args[1].upper()]
    address, mode = parse_operand(args[2])
    return Instruction(opcode, register, ADDRESS_MODES["DIRECT"], address)
    

def parse_tripple_instuction(args):
    if len(args) < 3:
        raise SyntaxError("Not enough arguments.")
    if len(args) > 3:
        raise SyntaxError("Trash at end of line \"{}\"".format(" ".join(args[3:])))
    opcode = OPCODE_TABLE[args[0]]
    if args[1].upper() not in REGISTERS:
        raise SyntaxError("Invalid register name" + args[1])
    register = REGISTERS[args[1].upper()]
    address, mode = parse_operand(args[2])
    return Instruction(opcode, register, mode, address)

def parse_jump(args):
    if len(args) < 2:
        raise SyntaxError("Not enough arguments.")
    if len(args) > 2:
        raise SyntaxError("Trash at end of line \"{}\"".format(" ".join(args[3:])))
    opcode = OPCODE_TABLE[args[0]]
    address, mode = parse_operand(args[1])
    return Instruction(opcode, 0, ADDRESS_MODES["DIRECT"], address)

def parse_dual_registers(args):
    if len(args) < 3:
        raise SyntaxError("Not enough arguments.")
    if len(args) > 3:
        raise SyntaxError("Trash at end of line \"{}\"".format(" ".join(args[3:])))
    opcode = OPCODE_TABLE[args[0]]
    if args[1].upper() not in REGISTERS:
        raise SyntaxError("Invalid register name" + args[1])
    register_a = REGISTERS[args[1].upper()]
    register_b = REGISTERS[args[2].upper()]
    return Instruction(opcode, register_a, register_b, 0)

def main():
    success = True
    line_number = 0 # The line in the source file
    word = 0 # The current word
    instructions = []
    tag_table = {}

    # Parse
    for line in input_file:
        line_number += 1
        if "#" in line:
            line = line[:line.index("#")]
        args = line.replace(",", "").replace("_", "").strip().split()
        if not args: continue
        OP = args[0].upper()
        if OP in OPCODE_TABLE:
            # It's an op!
            try:
                inst = parse_instruction(args)
                instructions.append(inst)
                word += inst.length
            except SyntaxError as e:
                success = False
                print("ERROR:{} {}".format(line_number, str(e)))
        elif OP.endswith(":"):
            # Tags for jumps
            tag = args[0][:-1]
            if tag not in tag_table:
                tag_table[tag] = word
            else:
                print("ERROR:{} Multiple instances of tag \"{}\"".format(line_number, tag))
                success = False
        elif OP == ".":
            # Data fields
            data = Data("".join(args[1:]).replace(" ", "").replace("\t", ""))
            instructions.append(data)
            word += data.length
        else:
            print("ERROR:{} Unknown symbol \"{}\"".format(line_number, line))
            success = False

    # Link instructions
    for instruction in instructions:
        try:
            if type(instruction) == Instruction:
                instruction.bake(tag_table)
        except SyntaxError as e:
            print("LINKING ERROR: {}".format(e))
            success = False

    # Exit on error
    if not success:
        return 1

    # Write out the program
    def print_as_hex(out, inst, newlines):
        string = instruction.to_hex()
        if newlines:
            while string:
                out.write(string[:WORD_SIZE // 4])
                out.write("\n")
                string = string[WORD_SIZE // 4:]
        out.write(string)

    def print_as_bin(out, inst, newlines):
        string = instruction.to_bin()
        if newlines:
            while string:
                out.write(string[:WORD_SIZE])
                out.write("\n")
                string = string[WORD_SIZE:]
        out.write(string)

    if output_format == "hex":
        print_func = print_as_hex
    else:
        print_func = print_as_bin 

    for instruction in instructions:
        print_func(output_file, instruction, newlines)

    output_file.flush()
    output_file.close()
    return 0


if __name__ == "__main__":
    exit(main())
        

