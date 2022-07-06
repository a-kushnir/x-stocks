# frozen_string_literal: true

# Component class to render a Confirmation Popup Window
class ConfirmationComponent < ::ViewComponent::Base
  def initialize(title:, description:, confirm:, cancel:)
    super
    @title = title
    @description = description
    @confirm = confirm
    @cancel = cancel
  end
end
