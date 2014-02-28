import memory

proc runOp*(address: TWord) =

  #Various convience functions that are common on many ops

  var op = memory[address]
  var mem_addr = readword(address, 1,2)
  var index = readword(address, 3,3)
  if index > 0:
    mem_addr += rI[index]

  var field = readword(address, 4,4)
  var start = field div 8
  var stop = field mod 8
  var val = readword(mem_addr,start,stop)
  var cmd = readword(address, 5,5)

  case cmd
  of 8: #LDA
    rA = val
  of 9..14: #LDi
    rI[cmd-8] = val
  of 15: #LDX
    rX = val
  of 16: #LDAN
    rA = -val
  of 17..22: #LDiN
    rI[cmd-16] = -val
  of 23: #LDXN
    rX = -val
  of 24: #STA
    store(mem_addr, start, stop, rA)
  of 31: #STX
    store(mem_addr, start, stop, rX)
  of 25..30: #STi
    store(mem_addr, start, stop, rI[cmd-24])
  of 32: #STJ
    store(mem_addr, start, stop, rJ)
  of 33: #STZ
    store(mem_addr, start, stop, 0)
  

