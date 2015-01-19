class NumberSet
  include Enumerable

  def initialize(numbers: [])
    @set = numbers
  end

  def <<(number)
    @set << number unless @set.include? number
  end

  def size
    @set.size
  end

  def empty?
    @set.empty?
  end

  def each(&block)
    @set.each(&block)
  end

  def [](filter)
    NumberSet.new numbers: @set.select { |number| filter.approve? number }
  end
end

class Filter
  def initialize(&block)
    @condition = block
  end

  def approve?(number)
    @condition.call number
  end

  def &(other_filter)
    Filter.new { |number| approve? number and other_filter.approve? number }
  end

  def |(other_filter)
    Filter.new { |number| approve? number or other_filter.approve? number }
  end
end

class TypeFilter < Filter
  def initialize(number_type)
    case number_type
    when :integer
      super() { |number| number.integer? }
    when :complex
      super() { |number| not number.real? }
    else
      super() { |number| number.real? and not number.integer? }
    end
  end
end

class SignFilter < Filter
  def initialize(compared_to_zero)
    case compared_to_zero
    when :positive     then super() { |number| number >  0 }
    when :non_positive then super() { |number| number <= 0 }
    when :negative     then super() { |number| number <  0 }
    when :non_negative then super() { |number| number >= 0 }
    end
  end
end
