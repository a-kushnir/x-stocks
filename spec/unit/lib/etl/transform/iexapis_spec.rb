# frozen_string_literal: true

require 'unit/spec_helper'
require 'etl/transform/iexapis'

describe Etl::Transform::Iexapis do
  subject(:transformer) { described_class.new(exchange_class: exchange_class, tag_class: tag_class, dividend_frequencies: dividend_frequencies) }

  let(:exchange_class) { nil }
  let(:tag_class) { nil }
  let(:dividend_frequencies) { nil }
  let(:stock) { mock_model }

  describe '#company' do
    let(:exchange_class) { OpenStruct.new(new: mock_model) }
    let(:tag_class) { OpenStruct.new(new: mock_model) }
    let(:stock) { mock_model(exchange: nil) }

    let(:json) do
      {
        'symbol' => 'AAPL',
        'companyName' => 'Apple Inc.',
        'exchange' => 'NASDAQ',
        'industry' => 'Telecommunications Equipment',
        'website' => 'http://www.apple.com',
        'description' => 'Apple, Inc. engages in the design, manufacture, and marketing...',
        'CEO' => 'Timothy Donald Cook',
        'securityName' => 'Apple Inc.',
        'issueType' => 'cs',
        'sector' => 'Electronic Technology',
        'primarySicCode' => 3663,
        'employees' => 132_000,
        'tags' => [
          'Electronic Technology',
          'Telecommunications Equipment'
        ],
        'address' => 'One Apple Park Way',
        'address2' => nil,
        'state' => 'CA',
        'city' => 'Cupertino',
        'zip' => '95014-2083',
        'country' => 'US',
        'phone' => '1.408.974.3123'
      }
    end

    let(:expected_stock) do
      {
        company_name: 'Apple Inc.',
        exchange: [:iexapis_code, 'NASDAQ'],
        industry: 'Telecommunications Equipment',
        website: 'http://www.apple.com',
        description: 'Apple, Inc. engages in the design, manufacture, and marketing...',
        ceo: 'Timothy Donald Cook',
        security_name: 'Apple Inc.',
        issue_type: 'cs',
        primary_sic_code: 3663,
        employees: 132_000,
        address: 'One Apple Park Way',
        address2: nil,
        state: 'CA',
        city: 'Cupertino',
        zip: '95014-2083',
        country: 'US',
        phone: '1.408.974.3123',
        save: []
      }
    end

    it 'saves data into model' do
      transformer.company(stock, json)
      expect(stock).to eq(expected_stock)
    end

    it 'uses exchange model' do
      transformer.company(stock, json)
      expect(exchange_class.new).to eq({ search_by: [:iexapis_code, 'NASDAQ'] })
    end

    it 'uses tag model' do
      transformer.company(stock, json)
      calls = { batch_update: [expected_stock, :company_tag, ['Electronic Technology', 'Telecommunications Equipment']] }
      expect(tag_class.new).to eq(calls)
    end
  end

  context 'when json contains dividend data' do
    let(:json) do
      [
        {
          'amount' => 0.70919585493507512,
          'currency' => 'USD',
          'declaredDate' => '2020-10-19',
          'description' => 'Ordinary Shares',
          'exDate' => '2020-10-28',
          'flag' => 'Cash',
          'frequency' => 'quarterly',
          'paymentDate' => '2020-11-06',
          'recordDate' => '2020-10-28',
          'refid' => 2_096_218,
          'symbol' => 'AAPL',
          'id' => 'DIVIDENDS',
          'key' => 'AAPL',
          'subkey' => '2053393',
          'date' => 1_612_392_166_191,
          'updated' => 1_612_392_166_191
        }
      ]
    end

    let(:dividend_details) do
      [{
        'ex_date' => '2020-10-28',
        'payment_date' => '2020-11-06',
        'record_date' => '2020-10-28',
        'declared_date' => '2020-10-19',
        'amount' => 0.709195854935075,
        'frequency' => 'quarterly'
      }]
    end

    describe '#dividends' do
      let(:dividend_frequencies) { { 'quarterly' => 4 } }
      let(:stock) { mock_model(periodic_dividend_details: dividend_details) }

      it 'saves data into model' do
        transformer.dividends(stock, json)

        calls = {
          dividend_details: dividend_details,
          dividend_frequency: 'quarterly',
          dividend_frequency_num: 4,
          dividend_amount: 0.709195854935075,
          est_annual_dividend: 2.8367834197403,
          periodic_dividend_details: dividend_details,
          save: []
        }

        expect(stock).to eq(calls)
      end
    end

    describe '#next_dividend' do
      it 'saves data into model' do
        transformer.next_dividend(stock, json)

        calls = {
          next_div_ex_date: '2020-10-28',
          next_div_payment_date: '2020-11-06',
          next_div_amount: 0.7091958549350751,
          save: []
        }

        expect(stock).to eq(calls)
      end
    end
  end
end
