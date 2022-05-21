# frozen_string_literal: true

# Calculates the current progress on a scale from 0 to 100%
class ProgressBar
  class Range
    attr_reader :min, :max

    def initialize(min, max)
      @min = min.to_f
      @max = max.to_f
    end

    def size
      max - min
    end
  end

  attr_reader :object, :progress, :weight

  def initialize(object = nil, weight: 1, progress: Range.new(0, 100))
    @object = object
    @weight = weight
    @progress = progress
  end

  def loop(objects)
    @value = progress.min
    increment = progress.size / objects.count
    objects.each do |object|
      yield ProgressBar.new(object, progress: Range.new(@value, @value += increment))
    end
  end

  def steps
    steps = Steps.new
    yield steps

    @value = progress.min
    increment = progress.size / steps.total_weight

    steps.steps.each do |step|
      step.instance_variable_set(:@progress, Range.new(@value, @value += increment * step.weight))
      step.object.call(step)
    end
  end

  class Steps
    attr_reader :steps

    def initialize
      @steps = []
    end

    def step(weight: 1, &block)
      @steps << ProgressBar.new(block, weight: weight, progress: nil)
    end

    def total_weight
      @steps.sum(&:weight)
    end
  end
end
