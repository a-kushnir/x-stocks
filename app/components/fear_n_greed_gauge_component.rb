# Component class to render a Fear&Greed Gauge
class FearNGreedGaugeComponent < ::ViewComponent::Base
  delegate :label, to: :helpers

  def initialize(score:, previous_close:, previous_1_week:, previous_1_month:, previous_1_year:)
    super
    @score = score.round
    @angle = (@score * 1.8) - 90
    @previous_close = previous_close.round
    @previous_1_week = previous_1_week.round
    @previous_1_month = previous_1_month.round
    @previous_1_year = previous_1_year.round
  end

  def score_label(score)
    if score < 25
      'extreme fear'
    elsif score < 40
      'fear'
    elsif score <= 60
      'neutral'
    elsif score <= 75
      'greed'
    else
      'extreme greed'
    end
  end
end
