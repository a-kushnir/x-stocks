# frozen_string_literal: true

module Etl
  module Extract
    # Extracts data from VettaFi (etfdb.com)
    class VettaFi
      BASE_URL = 'https://etfdb.com'

      def initialize(data_loader, cgi: CGI)
        @data_loader = data_loader
        @cgi = cgi
      end

      def etf_data(stock)
        return unless stock.etf?

        fields = {
          website: ->(html) { html.scan(%r{<span>ETF Home Page</span>\n<span class='truncate-index'><a href="([^>]+)">Home page</a></span>})&.dig(0, 0)&.strip },
          expense_ratio: ->(html) { html.scan(%r{<span>Expense Ratio</span>\n<span class='text-right'>(\d.\d+)%</span>})&.dig(0, 0)&.to_f },
          segment: ->(html) { html.scan(%r{<td[^<]+id='Segment'>([^<]+)</td>})&.dig(0, 0)&.strip }
        }

        html = data_loader.get_text(etf_data_url(stock.symbol))
        fields.transform_values { |proc| proc.call(html) }
      end

      private

      def etf_data_url(symbol)
        "#{BASE_URL}/etf/#{cgi.escape(symbol)}/"
      end

      attr_reader :data_loader, :token, :cgi
    end
  end
end
