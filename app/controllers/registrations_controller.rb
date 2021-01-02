class RegistrationsController < Devise::RegistrationsController

  # GET /resource/sign_up
  def new
    super
  end

  # POST /resource
  def create
    super
  end

  # GET /resource/edit
  def edit
    super
  end

  # PUT /resource
  # We need to use a copy of the resource because we don't want to change
  # the current user in place.
  def update
    super
  end

  # DELETE /resource
  def destroy
    super
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  def cancel
    super
  end

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
