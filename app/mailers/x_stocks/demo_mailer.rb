# frozen_string_literal: true

module XStocks
  # Test Mailer
  class DemoMailer < ApplicationMailer
    def notify
      @user = params[:user]
      mail(to: @user.email, subject: 'Demo Mail')
    end
  end
end
