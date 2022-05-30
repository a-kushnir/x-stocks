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
end
