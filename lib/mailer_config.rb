# frozen_string_literal: true

require 'uri'

# Configures Mailer
class MailerConfig
  def initialize(env: ENV)
    @env = env
  end

  def configure(action_mailer)
    action_mailer.default_url_options = { host: mailer_url.host, protocol: mailer_url.scheme, port: mailer_url.port } if mailer_url
    action_mailer.default_options = { from: mailer_from } if mailer_from
  end

  def mailer_url
    @mailer_url ||= begin
      mailer_url = @env['MAILER_URL']
      URI(mailer_url) if mailer_url.present?
    end
  end

  def mailer_from
    @env['MAILER_FROM'].presence
  end
end
