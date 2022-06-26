# frozen_string_literal: true

# Controller to provide user profile functions
class RegistrationsController < Devise::RegistrationsController
  def create
    super
    XStocks::User.new.save(resource) if resource.persisted?
  end

  protected

  # Security fix: Sign Up for existing users only
  def require_no_authentication
    authenticate_scope!
  end

  # The path used after sign up. You need to overwrite this method
  # in your own RegistrationsController.
  def after_sign_up_path_for(resource)
    root_url
  end
end
