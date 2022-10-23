# frozen_string_literal: true

require 'x_stocks'

# Controller to provide user sign in/out functions
class SessionsController < Devise::SessionsController
  private

  def after_sign_in_path_for(_resource)
    params[:back_url] || super
  end
end
