module Etl
  module Transform
    class Iexapis < Base

      def company(stock, json)
        json ||= {}

        stock.company_name = json['companyName']
        stock.exchange = Exchange.search(json['exchange'])
        stock.industry = json['industry']
        stock.website = json['website']
        stock.description = json['description']
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
        json = (json || []).map do |row|
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
        stock.dividend_details.uniq!
        stock.dividend_details.sort_by! { |row| row['payment_date'] }
        stock.dividend_details.reject! { |row| row['amount'].blank? || row['amount'].to_f.zero? }
        stock.dividend_details.each { |row| row['amount'] = row['amount'].to_f }

        last_div = stock.dividend_details.last
        stock.dividend_frequency = last_div['frequency'] rescue nil
        num = {
            'annual' => 1,
            'semi-annual' => 2,
            'quarterly' => 4,
            'monthly' => 12
        }[(stock.dividend_frequency || '').downcase]
        stock.dividend_frequency_num = num

        stock.dividend_amount = last_div['amount'] rescue nil
        stock.est_annual_dividend = stock.dividend_frequency_num * stock.dividend_amount rescue nil
        stock.update_dividends!
      end

    end
  end
end
