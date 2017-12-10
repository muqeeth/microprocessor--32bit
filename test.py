from Tkinter import *
import re

from tkFileDialog import *
import os.path

import sys

filename = "firsttest.asm"
fileexists = False

def asmtoint(asm):
    asm_split = re.split(" |, |\(|\)", asm)
    args = []
    for i in range (len(asm_split)):
        if (asm_split[i] != ""):
            args.append(asm_split[i])
    opcode = 0
    func = 0
    rd = 0
    rs = 0
    rt = 0
    imm = 0
    if (args[0] == "add"):
        if (len(args) != 4):
            return 0,0,0,0,0,0
        opcode = 0
        func = 0
        rs = int(args[1][1:])
        rt = int(args[2][1:])
        rd = int(args[3][1:])
    elif (args[0] == "and"):
        if (len(args) != 4):
            return 0,0,0,0,0,0
        opcode = 2
        func = 0
        rs = int(args[1][1:])
        rt = int(args[2][1:])
        rd = int(args[3][1:])
    elif (args[0] == "lst"):
        if (len(args) != 4):
            return 0,0,0,0,0,0
        opcode = 4
        func = 0
        rs = int(args[1][1:])
        rt = int(args[2][1:])
        rd = int(args[3][1:])
    elif (args[0] == "rst"):
        if (len(args) != 4):
            return 0,0,0,0,0,0
        opcode = 5
        func = 0
        rs = int(args[1][1:])
        rt = int(args[2][1:])
        rd = int(args[3][1:])
    elif (args[0] == "sub"):
        if (len(args) != 4):
            return 0,0,0,0,0,0
        opcode = 1
        func = 0
        rs = int(args[1][1:])
        rt = int(args[2][1:])
        rd = int(args[3][1:])
    elif (args[0] == "or"):
        if (len(args) != 4):
            return 0,0,0,0,0,0
        opcode = 2
        func = 0
        rs = int(args[1][1:])
        rt = int(args[2][1:])
        rd = int(args[3][1:])
    elif (args[0] == "halt"):
        if (len(args) != 1):
            return 0,0,0,0,0,0
        opcode = 63
        func = 0
        # rs = int(args[1][1:])
        # rt = int(args[2][1:])
        # rd = int(args[3][1:])
        rs = 0
        rt = 0
        rd = 0
    elif (args[0] == "bez"):
        if (len(args) != 3):
            return 0,0,0,0,0,0
        opcode = 10
        func = 2
        rt = 0
        rs = int(args[1][1:])
        imm = int(args[2])
    elif (args[0] == "bnez"):
        if (len(args) != 3):
            return 0,0,0,0,0,0
        opcode = 11
        rt = 0
        func = 2
        rs = int(args[1][1:])
        imm = int(args[2])
    elif (args[0] == "lw"):
        if (args[-1] == ''):
            args = args[0:-1]
        if (len(args) != 3 and len(args) != 4):
            return 0,0,0,0,0,0
        opcode = 6
        func = 1
        rt = int(args[1][1:])
        if (len(args) == 3):
            imm = 0
            rs = int(args[2][1:])
        else:
            imm = int(args[2])
            rs = int(args[3][1:])
    elif (args[0] == "addi"):
        if (args[-1] == ''):
            args = args[0:-1]
        if (len(args) != 3 and len(args) != 4):
            return 0,0,0,0,0,0
        opcode = 8
        func = 2
        rt = int(args[1][1:])
        if (len(args) == 3):
            imm = 0
            rs = int(args[2][1:])
        else:
            imm = int(args[2])
            rs = int(args[3][1:])
    elif (args[0] == "subi"):
        if (args[-1] == ''):
            args = args[0:-1]
        if (len(args) != 3 and len(args) != 4):
            return 0,0,0,0,0,0
        opcode = 9
        func = 2
        rt = int(args[1][1:])
        if (len(args) == 3):
            imm = 0
            rs = int(args[2][1:])
        else:
            imm = int(args[2])
            rs = int(args[3][1:])
    elif (args[0] == "sw"):
        if (args[-1] == ''):
            args = args[0:-1]
        if (len(args) != 3 and len(args) != 4):
            return 0,0,0,0,0,0
        opcode = 7
        func = 1
        rt = int(args[1][1:])
        if (len(args) == 3):
            imm = 0
            rs = int(args[2][1:])
        else:
            imm = int(args[2])
            rs = int(args[3][1:])
    else:
        return 0,0,0,0,0,0
    return opcode, rs, rt, rd, func, imm

def inttohex(opcode, rs, rt, rd, func, imm):
    if (func ==0):
        opstr = format(opcode, '06b')
        rsstr = format(rs, '05b')
        rtstr = format(rt, '05b')
        rdstr = format(rd, '05b')
        immstr = format(imm, '011b')
        instruction = opstr + rsstr + rtstr + rdstr + immstr
    if(func ==2) :
        opstr = format(opcode, '06b')
        rtstr = format(rt, '05b')
        rsstr = format(rs, '05b')
        if (imm < 0):
            imm2s = ((-imm) ^ 65535) + 1
            immstr = format(imm2s, '016b')
        else :
            immstr = format(imm, '016b')
        instruction = opstr + rsstr + rtstr + immstr
    if(func==1):
        opstr = format(opcode,'06b')
        rtstr = format(rt,'05b')
        rsstr = format(rs,'05b')
        immstr = format(imm,'016b')
        instruction = opstr+rsstr+rtstr+immstr
    return format(int(instruction,2), '032b')

def decode(asm):
    opcode, rs, rt, rd, func, imm = asmtoint(asm)
    instruction = inttohex(opcode, rs, rt, rd, func, imm)
    return instruction

def openFile():
    global filename
    openfilename = askopenfilename()
    if openfilename is not None:
        filename = openfilename
        asmfile = open(filename, "r")
        asmfile.seek(0)
        asmdata = asmfile.read()
        textArea.delete("1.0", "end - 1c")
        textArea.insert("1.0", asmdata)
        asmfile.close()
        filemenu.entryconfig(filemenu.index("Save"), state = NORMAL)
        frame.title("muCPU Assembler [" + filename + "]")
        frame.focus()
    
def saveFile():
    global filename
    asmdata = textArea.get("1.0", "end - 1c")
    asmfile = open(filename, "w")
    asmfile.seek(0)
    asmfile.truncate()
    asmfile.write(asmdata)
    asmfile.close()

def saveFileAs():
    global filename
    global fileexists
    saveasfilename = asksaveasfilename()
    if saveasfilename is not None:
        filename = saveasfilename
        fileexists = True
        asmdata = textArea.get("1.0", "end - 1c")
        asmfile = open(filename, "w")
        asmfile.seek(0)
        asmfile.truncate()
        asmfile.write(asmdata)
        asmfile.close()
        filemenu.entryconfig(filemenu.index("Save"), state = NORMAL)
        frame.title("muCPU Assembler [" + filename + "]")
        frame.focus()
    
        
def exitApp():
    frame.destroy()
    sys.exit()
    
def compileASM():
    global filename
    cpu_out = ""
    asm_in = textArea.get("1.0", END)
    asmlines = re.split("\n", asm_in)
    for i in range (len(asmlines)):
        if (asmlines[i] != ""):
            cpu_out += decode(asmlines[i]) + "\n"
    name, ext = os.path.splitext(filename)
    hexfilename = name + ".hex"
    hexfile = open(hexfilename, "w")
    hexfile.seek(0)
    hexfile.truncate()
    hexfile.write(cpu_out)
    hexfile.close()
    
Tk().withdraw()
frame = Toplevel()

scrollbar = Scrollbar(frame)
scrollbar.pack(side = RIGHT, fill = Y)
frame.title("muCPU Assembler [" + filename + "]")
textArea = Text(frame, height = 30, width = 100, padx = 3, pady = 3, yscrollcommand = scrollbar.set)
textArea.pack(side=RIGHT)
scrollbar.config(command=textArea.yview)

menubar = Menu(frame)
filemenu = Menu(menubar, tearoff=0)
filemenu.add_command(label="Open", command=openFile)
filemenu.add_command(label="Save", command=saveFile, state = DISABLED)
filemenu.add_command(label="Save as...", command=saveFileAs)
filemenu.add_command(label="Exit", command=exitApp)
menubar.add_cascade(label="File", menu=filemenu)
runmenu = Menu(menubar, tearoff=0)
runmenu.add_command(label="Compile", command=compileASM)
menubar.add_cascade(label="Run", menu=runmenu)
frame.config(menu=menubar)

frame.minsize(750, 450)
frame.maxsize(750, 450)
frame.mainloop()
