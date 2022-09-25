
def main():
    data = "\x01"+"\x01".join("Hello!") + "\x00"
    names = {
        "data": repr(bytes("\x00\x00" + "\x00\x00".join(data), "utf-8"))[2:-1],
        "data_size": str(len(data)),
    }
    with open("code.txt") as f:
        code = f.read()

    pos = 0
    code2 = ""
    while len(code)>0:

        pos = code.find("`", pos)
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

    print(code2)


if __name__ == '__main__':
    main()
