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
    data = "\x03\x00\x01\x00\x03\x01\x01\x01\x03\x02\x01\x02" + "\x00"
    names = {
        "cell_size": 256,
        "data": decorate(data),
        "data_size": str(len(data)),

        "stop": "0",
        "out": "1",
        "jmp": "2",
        "in": "3",
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
    with open("out.bf", "w") as f:
        for i in range(0, len(data), 100):
            f.write(data[i:i + 100] + "\n")


if __name__ == '__main__':
    main()
