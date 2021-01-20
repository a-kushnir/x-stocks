# frozen_string_literal: true

module XStocks
  # User Business Model
  class User
    def save(user)
      user.api_key ||= generate_api_key if user.respond_to?(:api_key)
      user.save
    end

    def regenerate_api_key(user)
      user.api_key = generate_api_key if user.respond_to?(:api_key)
      user.save
    end

    private

    def generate_api_key
      Devise.friendly_token
    end
  end
end
