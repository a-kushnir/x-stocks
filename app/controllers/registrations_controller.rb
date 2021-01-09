# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  def regenerate
    current_user.regenerate_api_key!
    redirect_to edit_user_registration_path
  end

  protected

  # Security fix: Sign Up for existing users only
  def require_no_authentication
    authenticate_scope!
  end
end
