from braincompiler import compile_code


def decorate(data: str) -> str:
    data2 = ""
    codes = "0123456789ABCDEF"
    for i in data:
        data2 += r"\x00\x00"
        var = ord(i)
        data2 += fr"\x{codes[var // 16]}{codes[var % 16]}"
    return data2


def main():
    data = "\x05\xC0\x07\x04\x90\xFF\xFF\x46\x49\x5A\x5A\x42\x55\x5A\x5A\x00" + "\xff"
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

        "shl": "19",
        "shlr": "20",
        "shr": "21",
        "shrr": "22",
    }
    with open("code.txt") as f:
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


if __name__ == '__main__':
    main()
