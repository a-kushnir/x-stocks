module Etl
  module Extract
    class Base

      protected

      def load_text(url)
        response = Net::HTTP.get_response(URI(url))
        if response.is_a?(Net::HTTPSuccess)
          response.body
        end
      end

      def load_json(url)
        response = Net::HTTP.get_response(URI(url))
        if response.is_a?(Net::HTTPSuccess)
          JSON.parse(response.body)
        end
      end

    end
  end
end
