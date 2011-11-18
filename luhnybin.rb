#!/usr/bin/env ruby
require 'set'
require 'forwardable'
class Mask
  extend Forwardable
  def_delegators :@set, :include?, :empty?

  def initialize(range=nil)
    @set = Set.new
    self << range
  end

  def <<(range)
    range.to_a.each { |n| @set << n }
  end
end

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
  def filter(start=0, index=0, digits=[], mask=Mask.new)
    return mask if index == @text.length

    char = @text[index]
    digit = digit?(char)

    if digit
      value = char - char('0')
      digits.unshift(value)
      start += 1 if digits.length > RANGE.max
    elsif !separator?(char)
      start = index
    end

    mask = filter(start, index + 1, digits, luhn_mask(start, index, digits, mask))
    @text[index] = char('X') if mask.include?(index) && digit
    return mask
  end

  def luhn_mask(start, index, digits, mask)
    digits = digits[0, RANGE.max]
    length = digits.length
    return mask if length < RANGE.min

    length.downto(RANGE.min) do |n|
      i = -1
      sum = digits.inject(0) do |tot, d|
        i += 1
        tot += i.odd? ? SUMMED_DOUBLES[d] : d
      end

      if sum % 10 == 0
        mask << (start..index)
        return mask
      end
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
