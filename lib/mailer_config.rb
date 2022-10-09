# frozen_string_literal: true

require 'uri'

# Configures Mailer
class MailerConfig
  def initialize(env: ENV)
    @env = env
  end

  def configure(action_mailer)
    action_mailer.default_url_options = default_url_options if default_url_options
    action_mailer.default_options = default_options if default_options
    action_mailer.smtp_settings = smtp_settings if smtp_settings
    action_mailer.perform_deliveries = true
  end

  def mailer_url
    @mailer_url ||= begin
      mailer_url = env['MAILER_URL']
      URI(mailer_url) if mailer_url.present?
    end
  end

  def default_url_options
    return nil unless mailer_url

    { host: mailer_url.host, protocol: mailer_url.scheme, port: mailer_url.port }
  end

  def default_options
    mailer_from = env['MAILER_FROM'].presence
    return nil unless mailer_from

    { from: mailer_from }
  end

  def smtp_settings
    smtp_server = env['SMTP_SERVER'].presence
    return nil unless smtp_server

    {
      address: smtp_server,
      port: env['SMTP_PORT'],
      domain: env['SMTP_DOMAIN'],
      authentication: :plain,
      user_name: env['SMTP_USER'],
      password: env['SMTP_PASSWORD'],
      enable_starttls_auto: true
    }
  end

  attr_reader :env
end
