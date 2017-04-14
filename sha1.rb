require 'digest'

def toBinStr(string)
  binaryStr = ''
  string.each_char do |c|
    binaryChar = '%b' % (c.ord)
    while (binaryChar.length < 8)
      binaryChar = '0' + binaryChar
    end
    binaryStr += binaryChar
  end
  return binaryStr
end

def leftrotate(value, shift)
  return ((value << shift) & 0xffffffff) | (value >> (32 - shift))
end

def main(string)
  h0,h1, h2, h3, h4 = 0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0

  binString = toBinStr(string) + '1'
  len = (binString.length - 1).to_s(2)
  
  while (binString.length % 512 != 448)
    binString = binString + '0'
  end

  binString = binString + '0' * (64 - len.length) + len
  counter = binString.length / 512

  array = []
  binString.scan(/.{1,32}/).each do |part|
    array << part.to_i(2)
  end

  counter.times do |x|
    (16..79).each do |i|
      array[i] = (array[i - 3] ^ array[i - 8] ^ array[i - 14]^ array[i - 16])
      array[i] = leftrotate(array[i], 1)
    end

    a, b, c, d, e = h0, h1, h2, h3, h4

    (0..79).each do |i|
      if (i >= 0 && i <= 19)
        f = d ^ (b & (c ^ d))   
        k = 0x5A827999
      elsif (i >= 20 && i <= 39)      
        f = (b ^ c ^ d)
        k = 0x6ED9EBA1
      elsif (i >= 40 && i <= 59)
        f = (b & c) | (b & d) | (c & d)
        k = 0x8F1BBCDC
      elsif (i >= 60 && i <= 79)
        f = b ^ c ^ d
        k = 0xCA62C1D6
      end

      temp = ((leftrotate(a, 5) + f + e + k + array[i])) & 0xffffffff
      e = d
      d = c
      c = leftrotate(b, 30)
      b = a
      a = temp
    end

    h0 = h0 + a & 0xffffffff
    h1 = h1 + b & 0xffffffff
    h2 = h2 + c & 0xffffffff
    h3 = h3 + d & 0xffffffff
    h4 = h4 + e & 0xffffffff
  end
  
  my_hash = h0.to_s(16) + h1.to_s(16) + h2.to_s(16) + h3.to_s(16) + h4.to_s(16)
  
  puts Digest::SHA1.hexdigest string
  puts my_hash
end

string = "The quick brown fox jumps over the lazy dog"
main(string)