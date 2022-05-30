# frozen_string_literal: true

module Users
  # Provides user API form
  class ApisController < ApplicationController
    def create
      XStocks::User.new.regenerate_api_key(current_user)
      redirect_to edit_user_registration_path
    end
  end
end
