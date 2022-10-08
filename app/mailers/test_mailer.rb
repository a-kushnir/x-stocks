# frozen_string_literal: true

class TestMailer < ApplicationMailer
  def notify
    @user = params[:user]
    mail(to: @user.email, subject: 'Test Mail')
  end
end
