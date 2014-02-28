import strutils
#The MIX memory architecture consists of 4000 words, where each word is 5 6-bit values and a sign bit

type TWord* = int32

const 
  masks: array[0..5, int32] = [0b01_000000_000000_000000_000000_000000'i32,
    0b00_111111_000000_000000_000000_000000,
    0b00_000000_111111_000000_000000_000000,
    0b00_000000_000000_111111_000000_000000,
    0b00_000000_000000_000000_111111_000000,
    0b00_000000_000000_000000_000000_111111]
  data_mask = 0b00_111111_111111_111111_111111_111111

type comp = enum lt, eq, gt

var memory*: array[0..3999, TWord]
var rA*: TWord
var rX*: TWord
var rJ*: TWord
var rI*: array[1..6, TWord]
var rC*: comp
var rO* = False

converter toInt32*(x: TWord): int32 = 
  var sign = (x and masks[0])
  if sign == 0:
    return x and data_mask
  return -(x and data_mask)

converter toTWord(x: int32): TWord =
  if abs(x) > data_mask:
    raise newexception(EInvalidValue,"Value will not fit in a 30 bit word")
  var t: TWord = data_mask and x
  if x < 0:
    t = t or masks[0]
  return t

proc writeword *(address, value: TWord) = 
  if address < 4000:
    if int32(value) < 0:
      memory[address] = TWord(abs(value)) or masks[0]
    else: 
      memory[address] = value
  else:
    raise newexception(EAccessViolation, "Address our of range")

proc parseword* (word: TWord, start, stop: int): int32 =
  var mask = 0 
  if start == 0 and stop == 0:
    return (word and masks[0]) shr 30
  for x in countup(max(start,1), stop):
    mask = mask or masks[x]
  var data = Int32((word and mask) shr (6 * (5 - stop)))
  
  if start > 0:
    return data
  if (word and masks[0]) != 0:
    return -data
  return data

proc readword *(address: TWord, start, stop: int): int32 = 
  return parseword(memory[address],start, stop)
  

proc `$`(x: TWord): string =
  return join([intToStr(parseword(x,0,0), 1),
     " ", intToStr(parseword(x,1,1),2),
     " ", intToStr(parseword(x,2,2),2),
     " ", intToStr(parseword(x,3,3),2),
     " ", intToStr(parseword(x,4,4),2),
     " ", intToStr(parseword(x,5,5),2)])


proc printmemory* () =
  for x in countup(0,3999):
    if memory[x] != 0:
      echo intToStr(x,4),": ", $memory[x]


proc store(address: TWord, start, stop: int,value: TWord) =
  var newval = (data_mask and value) shl (6 * (5-stop))

  var oldval = readword(address, 0,5) 
  for i in countup(start, stop):
    oldval = oldval and (not (data_mask and masks[i]))
  newval += oldval
  if start == 0 and value < 0:
    newval = -newval
  memory[address] = TWord(newval)






