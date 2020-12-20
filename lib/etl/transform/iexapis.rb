module Etl
  module Transform
    class Iexapis < Base

      def company(stock, json)
        return if json.blank?

        stock.company_name = json['companyName']
        stock.exchange ||= Exchange.find_by(iexapis_code: json['exchange']) if json['exchange'].present?
        stock.industry = json['industry']
        stock.website = json['website']
        stock.description = json['description'] if stock.description.blank?
        stock.ceo = json['CEO']
        stock.security_name = json['securityName']
        stock.issue_type = json['issueType']
        stock.sector = json['sector']
        stock.primary_sic_code = json['primarySicCode']
        stock.employees = json['employees']
        stock.address = json['address']
        stock.address2 = json['address2']
        stock.state = json['state']
        stock.city = json['city']
        stock.zip = json['zip']
        stock.country = json['country']
        stock.phone = json['phone']

        if stock.save
          ::Tag.batch_update(stock, :company_tag, json['tags'])
        end
      end

      def dividends(stock, json)
        return unless json

        json = [json] unless json.is_a?(Array)

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

        stock.dividend_frequency = last_div['frequency'] rescue nil
        num = Stock::DIVIDEND_FREQUENCIES[(stock.dividend_frequency || '').downcase]
        stock.dividend_frequency_num = num

        stock.dividend_amount = last_div['amount'] rescue nil
        stock.est_annual_dividend = stock.dividend_frequency_num * stock.dividend_amount rescue nil
        stock.update_dividends!
      end

      def next_dividend(stock, json)
        return if json.blank?

        json = json.first if json.is_a?(Array)
        stock.next_div_ex_date = json&.dig('exDate')
        stock.next_div_payment_date = json&.dig('paymentDate')
        stock.next_div_amount = json&.dig('amount')

        stock.save!
      end

    end
  end
end
