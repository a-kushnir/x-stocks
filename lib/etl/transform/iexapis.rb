module Etl
  module Transform
    class Iexapis

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
          ::StocksTag.batch_update(stock, :company_tag, json['tags'])
        end
      end

    end
  end
end
