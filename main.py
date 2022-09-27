from braincompiler.main import compile_code


def main():
    data = "\x01"+"\x01".join("Hello world!\n") + "\x02\x00"
    names = {
        "data": repr(bytes("\x00\x00" + "\x00\x00".join(data), "utf-8"))[2:-1],
        "data_size": str(len(data)),

        "stop": "0",
        "out": "1",
        "jmp": "2",
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
        code = code[pos+1:]
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
