# frozen_string_literal: true

require 'x_stocks'

# Controller to provide user profile functions
class RegistrationsController < Devise::RegistrationsController
  def create
    super
    XStocks::User.new.save(resource) if resource.persisted?
  end

  protected

  # Security fix: Sign Up for existing users only
  def require_no_authentication
    XStocks.protected_sign_up? ? authenticate_scope! : super
  end

  # The path used after sign up. You need to overwrite this method
  # in your own RegistrationsController.
  def after_sign_up_path_for(_resource)
    root_url
  end
end
