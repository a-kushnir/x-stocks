# frozen_string_literal: true

# The Math module contains module functions for basic
# trigonometric and transcendental functions. See class
# Float for a list of constants that
# define Ruby's floating point accuracy.
#
# Domains and codomains are given only for real (not complex) numbers.
module Math
  def self.lerp(min, max, value)
    value = 0 if value.negative?
    value = 1 if value > 1
    min + ((max - min) * value.to_f)
  end

  def self.inv_lerp(min, max, value)
    if min < max
      return 0 if value <= min
      return 1 if value >= max
    else
      return 0 if value >= min
      return 1 if value <= max
    end

    (value - min).to_f / (max - min)
  end

  def self.moving_average(array, length, precision)
    array.each_cons(length).map { |e| e.sum.fdiv(length).round(precision) }
  end
end
