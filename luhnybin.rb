#!/usr/bin/env ruby
class Luhnybin
  MINIMUM = 14
  SUMMED_DOUBLES = [0, 2, 4, 6, 8, 1, 3, 5, 7, 9].freeze

  def initialize(text)
    @text = text.unpack('c*')
    filter
  end

  def text
    @text.pack('c*')
  end

  private
  def filter(start=0, index=0, digits=[])
    return 0 if index == @text.length || digits.length > 16

    count = luhn(digits)
    return count if count > 0

    char = @text[index]
    digit = digit?(char)

    if digit
      value = char - ?0
      digits.unshift(value)
    elsif !separator?(char)
      start = index
      digits.clear
    end

    lc = filter(start, index + 1, digits)
    if lc > 0 && digit
      @text[index] = ?X
      lc -= 1
    end
    return lc
  end

  def luhn(digits)
    length = digits.length
    return 0 if length < MINIMUM

    length.downto(MINIMUM) do |n|
      i = 0
      sum = digits[0,n].reduce(0) do |tot, d|
        tot += i.even? ? d : SUMMED_DOUBLES[d]
        i += 1
        tot
      end
      return n if sum % 10 == 0
    end
    return 0
  end

  def digit?(char)
    char.between?(?0, ?9)
  end

  def separator?(char)
    char == ?- || char == 32
  end
end

class String
  def mask_cc_number
    Luhnybin.new(self).text
  end
end

if __FILE__ == $0
  STDIN.each do |line|
    STDOUT << line.mask_cc_number
  end
end
