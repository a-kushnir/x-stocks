# frozen_string_literal: true

require 'x_stocks'

# Controller to provide user sign in/out functions
class SessionsController < Devise::SessionsController
  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: params[:back_url] || after_sign_in_path_for(resource)
  end
end
