#!/usr/bin/env ruby
require 'set'
class Luhnybin
  RANGE = (14..16)
  SUMMED_DOUBLES = [0, 2, 4, 6, 8, 1, 3, 5, 7, 9].freeze

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
      value = char - char('0')
      digits.unshift(value)
      start += 1 if digits.length > RANGE.max
    elsif !separator?(char)
      start = index
      digits.clear
    end

    mask = filter(start, index + 1, digits,
      luhn_mask(start, index, digits, mask))
    @text[index] = char('X') if mask.include?(index) && digit
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
    char.between?(char('0'), char('9'))
  end

  def separator?(char)
    char == char('-') || char == char(' ')
  end

  def char(char)
    RUBY_VERSION =~ /^1\.8/ ? char[0] : char.ord
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
