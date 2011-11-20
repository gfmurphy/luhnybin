#!/usr/bin/env ruby
def char_as_int(c)
  RUBY_VERSION =~ /^1\.8/ ? c[0] : c.ord
end

require 'set'
class Luhnybin
  RANGE = (14..16)
  SUMMED_DOUBLES = [0, 2, 4, 6, 8, 1, 3, 5, 7, 9].freeze

  DASH  = char_as_int('-')
  SPACE = char_as_int(' ')
  ZERO  = char_as_int('0')
  NINE  = char_as_int('9')
  MASK  = char_as_int('X')

  def initialize(text)
    @text = text.unpack('c*')
    filter
  end

  def text
    @text.pack('c*')
  end

  private
  def filter(start=0, index=0, digits=[], mask=Set.new)
    return mask if index == @text.length

    char = @text[index]
    digit = digit?(char)

    if digit
      value = char - ZERO
      digits.unshift(value)
      start += 1 if digits.length > RANGE.max
    elsif !separator?(char)
      start = index
      digits.clear
    end

    mask = filter(start, index + 1, digits,
      luhn_mask(start, index, digits, mask))
    @text[index] = MASK if mask.include?(index) && digit
    return mask
  end

  def luhn_mask(start, index, digits, mask)
    digits = digits[0, RANGE.max]
    length = digits.length
    return mask if length < RANGE.min

    i = -1
    sum = digits.reduce(0) do |tot, d|
      i += 1
      tot += i.odd? ? SUMMED_DOUBLES[d] : d
    end

    if sum % 10 == 0
      index.downto(start) { |i| mask << i }
      return mask
    else
      luhn_mask(start, index, digits[0, length - 1], mask)
    end

    return mask
  end

  def digit?(char)
    char.between?(ZERO, NINE)
  end

  def separator?(char)
    char == DASH || char == SPACE
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
    STDOUT.flush
  end
end
