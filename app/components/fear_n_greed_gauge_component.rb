# frozen_string_literal: true

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

  def score_class(score)
    if score < 25
      'extreme fear'
    elsif score < 45
      'fear'
    elsif score <= 55
      'neutral'
    elsif score <= 75
      'greed'
    else
      'extreme greed'
    end
  end

  def score_label(score)
    if score < 25
      t('fear_n_greed_gauge_component.extreme_fear')
    elsif score < 45
      t('fear_n_greed_gauge_component.fear')
    elsif score <= 55
      t('fear_n_greed_gauge_component.neutral')
    elsif score <= 75
      t('fear_n_greed_gauge_component.greed')
    else
      t('fear_n_greed_gauge_component.extreme_greed')
    end
  end
end
