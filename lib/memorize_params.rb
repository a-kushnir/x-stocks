# frozen_string_literal: true

# Memorises params into cookie and restores them when the same page is opened
module MemorizeParams
  def self.included(base)
    base.extend ClassMethods
  end

  # Class methods for MemorizeParams module
  module ClassMethods
    def memorize_params(code, options = {}, &block)
      etag { @_memorized_params&.to_json }

      before_action(options) do
        data = cookies[code]
        if params.except(:action, :controller).blank? && data.present?
          data = Base64.decode64(data)
          data = JSON.parse(data)
          request.params.merge!(data)
          params.merge!(data)
          @_memorized_params = data
        end
      rescue StandardError
        # Ignore
      end

      after_action(options) do
        data = instance_eval(&block)
        if data.present?
          data = data.to_json
          data = Base64.encode64(data)
          cookies[code] = data
        end
      end
    end
  end
end
