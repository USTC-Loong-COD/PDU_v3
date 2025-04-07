import sys, getopt
from elftools.elf.elffile import ELFFile

def main(argv):
    # parse arguments
    inputfile = "a.elf"
    outputfile = "a.coe"
    baseAddress = 0
    size = 0
    try:
        opts, args = getopt.getopt(argv, "", ["help", "elf=", "coe=", "base=", "size="])
    except getopt.GetoptError:
        print("python3 elf2coe.py --elf <inputfile> --coe <outputfile> --base <base address>")
        sys.exit(2)
    for opt, arg in opts:
        if opt == "--help":
            print("python3 elf2coe.py --elf <inputfile> --coe <outputfile> --base <base address>")
            sys.exit(0)
        elif opt == "--elf":
            inputfile = arg
        elif opt == "--coe":
            outputfile = arg
        elif opt == "--base":
            baseAddress = eval(arg)
        elif opt == "--size":
            size = eval(arg)

    content = [[0, 0, 0, 0] for i in range(0, int(size / 4))]

    with open(inputfile, "rb") as istream:
        elffile = ELFFile(istream)
        for sectionName in [".text", ".data", ".rodata", ".bss"]:
            section = elffile.get_section_by_name(sectionName)
            if section != None:
                sectionAddress = section.header["sh_addr"]
                sectionSize = section.header["sh_size"]
                sectionData = section.data()
                for i in range(0, sectionSize):
                    if sectionAddress + i >= baseAddress and sectionAddress + i < baseAddress + size:
                        word = int((sectionAddress + i - baseAddress) / 4)
                        offset = (sectionAddress + i - baseAddress) % 4
                        content[word][offset] = int(sectionData[i])

    with open(outputfile, "w") as ostream:
        for line in content:
            for byte in reversed(line):
                ostream.write("{:02x}".format(byte))
            ostream.write("\n")

if __name__ == "__main__":
    main(sys.argv[1:])
