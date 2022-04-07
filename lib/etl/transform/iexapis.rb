# frozen_string_literal: true

require 'country_flag'

module Etl
  module Transform
    # Transforms data extracted from cloud.iexapis.com
    class Iexapis
      def initialize(exchange_class: XStocks::Exchange,
                     tag_class: XStocks::Tag,
                     dividend_frequencies: XStocks::Stock::Dividends::DIVIDEND_FREQUENCIES)
        @exchange_class = exchange_class
        @tag_class = tag_class
        @dividend_frequencies = dividend_frequencies
      end

      def company(stock, json)
        return if json.blank?

        stock.company_name = json['companyName']
        stock.exchange ||= exchange_class.new.search_by(:iexapis_code, json['exchange']) if json['exchange'].present?
        stock.industry = json['industry']
        stock.website = json['website']
        stock.description = json['description'] if stock.description.blank?
        stock.ceo = json['CEO']
        stock.security_name = json['securityName']
        stock.issue_type = json['issueType']
        stock.primary_sic_code = json['primarySicCode']
        stock.employees = json['employees']
        stock.address = json['address']
        stock.address2 = json['address2']
        stock.state = json['state']
        stock.city = json['city']
        stock.zip = json['zip']
        stock.country = json['country']
        stock.taxes ||= taxes(stock)
        stock.phone = json['phone']

        return unless stock.save

        tag_class.new.batch_update(stock, :company_tag, json['tags'])
      end

      def taxes(stock)
        taxes = []
        taxes << :foreign_tax if foreign?(stock)
        taxes << :schedule_k1 if limited_partnership?(stock)
        taxes
      end

      def foreign?(stock)
        stock.country.present? && CountryFlag.new.code(stock.country) != 'US'
      end

      def limited_partnership?(stock)
        stock.company_name.present? && stock.company_name.strip =~ /\s+L[. ]*P\.?$/i
      end

      def dividends(stock, json)
        return unless json

        json = Array(json)

        json = json.map do |row|
          {
            'ex_date' => row['exDate'],
            'payment_date' => row['paymentDate'],
            'record_date' => row['recordDate'],
            'declared_date' => row['declaredDate'],
            'amount' => row['amount'].to_d,
            'frequency' => row['frequency']
          }
        end

        stock.dividend_details ||= []
        stock.dividend_details += json
        stock.dividend_details.uniq! { |row| row['payment_date'] }
        stock.dividend_details.sort_by! { |row| row['payment_date'] }
        stock.dividend_details.reject! { |row| row['amount'].blank? || row['amount'].to_f.zero? }
        stock.dividend_details.each { |row| row['amount'] = row['amount'].to_f }

        last_div = stock.periodic_dividend_details.last
        stock.dividend_frequency = last_div&.dig('frequency')
        stock.dividend_frequency_num = dividend_frequencies[(stock.dividend_frequency || '').downcase]
        stock.dividend_amount = last_div&.dig('amount')
        stock.est_annual_dividend = (stock.dividend_frequency_num * stock.dividend_amount if stock.dividend_frequency_num && stock.dividend_amount)

        stock.save
      end

      def next_dividend(stock, json)
        return if json.blank?

        json = json.first if json.is_a?(Array)
        stock.next_div_ex_date = json&.dig('exDate')
        stock.next_div_payment_date = json&.dig('paymentDate')
        stock.next_div_amount = json&.dig('amount')

        stock.save
      end

      private

      attr_reader :exchange_class, :tag_class, :dividend_frequencies
    end
  end
end
