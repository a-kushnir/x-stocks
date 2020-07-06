module Convert
  module Iexapis
    class Company

      def process(stock, json)
        if json
          add_company(stock, json)
        else
          remove_company(stock)
        end
      end

      private

      def add_company(stock, json)
        company = stock.company || ::Company.new(stock: stock)

        company.company_name = json['companyName']
        company.exchange = json['exchange']
        company.industry = json['industry']
        company.website = json['website']
        company.description = json['description']
        company.ceo = json['CEO']
        company.security_name = json['securityName']
        company.issue_type = json['issueType']
        company.sector = json['sector']
        company.primary_sic_code = json['primarySicCode']
        company.employees = json['employees']
        company.address = json['address']
        company.address2 = json['address2']
        company.state = json['state']
        company.city = json['city']
        company.zip = json['zip']
        company.country = json['country']
        company.phone = json['phone']

        if company.save
          updated_ids = []
          (json['tags'] || []).each do |tag|
            tag = ::Tag.find_or_create_by(name: tag)
            updated_ids << ::CompaniesTag.find_or_create_by(company: company, tag: tag).id
          end

          ::CompaniesTag
              .where(company_id: company.id)
              .where.not(id: updated_ids)
              .delete_all
        end
      end

      def remove_company(stock)
        stock.company&.destroy
      end

    end
  end
end
