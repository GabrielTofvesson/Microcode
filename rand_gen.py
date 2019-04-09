import random

def getRandomHex():
    return hex(random.randint(0, 0x10000) | (1 << 30))[-4:].upper()

if __name__ == "__main__":
    print("@p\n@0xE0")
    for i in range(0, 32):
        print(getRandomHex())
