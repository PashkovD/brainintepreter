from braincompiler import compile_code

from interpreter import Interpreter


def decorate(data: str) -> str:
    data2 = ""
    codes = "0123456789ABCDEF"
    for i in data:
        data2 += r"\x00\x00"
        var = ord(i)
        data2 += fr"\x{codes[var // 16]}{codes[var % 16]}"
    return data2


def main():
    data = "\x05\xC7\xC0\x08\x72\x0F\x00\x0F\x08\x04\x08\x14\xC1\x04\x16\xC1\x04\x05\x89\x2E\x04\x91\x2C\x16\xC0\x04\x05\x81\x2E\x04\x91\x2B\x05\xC0\x2B\x04\x90\xFF\x10\x08\x10\x00\x12\x30\x30\x00\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39\x41\x42\x43\x44\x45\x46\x0F\x00\x05\xC0\x49\x04\x90\xFF\x10\x00\x12\x46\x49\x5A\x5A\x00\x0F\x00\x05\xC0\x59\x04\x90\xFF\x10\x00\x12\x42\x55\x5A\x5A\x00\x0F\x00\x05\xC0\x69\x04\x90\xFF\x10\x00\x12\x46\x49\x5A\x5A\x42\x55\x5A\x5A\x00\x01\xC0\x01\x11\x05\x01\xC0\x01\x11\x05\x01\xC0\x01\x11\x3E\x01\xC0\x01\x11\x05\x01\xC0\x01\x11\x4E\x01\xC0\x01\x11\x3E\x01\xC0\x01\x11\x05\x01\xC0\x01\x11\x05\x01\xC0\x01\x11\x3E\x01\xC0\x01\x11\x4E\x01\xC0\x01\x11\x05\x01\xC0\x01\x11\x3E\x01\xC0\x01\x11\x05\x01\xC0\x01\x11\x05\x01\xC0\x01\x11\x5E\x08\x72" + "\xff"
    data += "\0" * (256 - len(data))
    names = {
        "cell_size": 256,
        "data": decorate(data),
        "data_size": str(len(data)),

        "stop": "255",
        "out": "254",
        "in": "253",

        "add": "0",
        "addr": "1",
        "sub": "2",
        "subr": "3",
        "mov": "4",
        "movr": "5",

        "cmp": "6",
        "cmpr": "7",

        "jmp": "8",
        "je": "9",
        "jne": "10",
        "jl": "11",
        "jnl": "12",
        "jg": "13",
        "jng": "14",

        "push": "15",
        "pop": "16",
        "call": "17",
        "ret": "18",

        "shl": "19",
        "shlr": "20",
        "shr": "21",
        "shrr": "22",

        "and": "23",
        "andr": "24",
        "xor": "25",
        "xorr": "26",
        "or": "27",
        "orr": "28",
        "not": "29",
    }
    with open("code.sl") as f:
        code = f.read()

    code2 = ""
    while len(code) > 0:

        pos = code.find("`")
        if pos == -1:
            code2 += code[:]
            break
        code2 += code[:pos]
        code = code[pos + 1:]
        name = ""
        while len(code) > 0 and (code[0].isalpha() or code[0] == "_"):
            name += code[0]
            code = code[1:]
        code2 += names[name]

    data = compile_code(code2)
    print(f"len : {len(data)}")
    with open("out.bf", "w") as f:
        for i in range(0, len(data), 100):
            f.write(data[i:i + 100] + "\n")
    print("Done")
    intr = Interpreter(timeout=100)
    try:
        intr(data, "")
    except TimeoutError:
        pass
    out: bytearray = intr.out
    print(out.decode("utf-8"))


if __name__ == '__main__':
    main()
