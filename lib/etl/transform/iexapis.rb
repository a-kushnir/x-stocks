# frozen_string_literal: true

require 'country_flag'

module Etl
  module Transform
    # Transforms data extracted from cloud.iexapis.com
    class Iexapis
      def initialize(exchange_class: XStocks::Exchange,
                     tag_class: XStocks::Tag)
        @exchange_class = exchange_class
        @tag_class = tag_class
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

      private

      attr_reader :exchange_class, :tag_class
    end
  end
end
