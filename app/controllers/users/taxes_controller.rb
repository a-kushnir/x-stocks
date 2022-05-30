# frozen_string_literal: true

module Users
  # Provides user taxes form
  class TaxesController < ApplicationController
    def create
      current_user.attributes = user_params
      current_user.save!
      redirect_to edit_user_registration_path
    end

    private

    def user_params
      (params[:user] || {}).permit(:taxes => {})
    end
  end
end
