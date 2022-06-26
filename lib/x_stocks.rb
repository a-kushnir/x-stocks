# frozen_string_literal: true

# Application level module
module XStocks
  def self.protected_sign_up?
    %w[1 true].include?(ENV['PROTECTED_SIGN_UP']&.downcase)
  end
end
