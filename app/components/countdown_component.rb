# frozen_string_literal: true

# Component class to render a Countdown Timer
class CountdownComponent < ::ViewComponent::Base
  def initialize(datetime:)
    super
    @datetime = datetime
  end
end
