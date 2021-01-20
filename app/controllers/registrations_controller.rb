# frozen_string_literal: true

# Controller to provide user profile functions
class RegistrationsController < Devise::RegistrationsController
  # POST /resource
  def create
    super
    XStocks::User.new.save(resource) if resource.persisted?
  end

  # POST /registrations/regenerate
  def regenerate
    XStocks::User.new.regenerate_api_key(current_user)
    redirect_to edit_user_registration_path
  end

  protected

  # Security fix: Sign Up for existing users only
  def require_no_authentication
    authenticate_scope!
  end
end
