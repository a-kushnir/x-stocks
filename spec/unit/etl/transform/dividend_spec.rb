# frozen_string_literal: true

require 'unit/spec_helper'
require 'etl/transform/dividend'

describe Etl::Transform::Dividend do
  subject(:data_saver) { described_class.new }

  let(:stock) do
    stock = {}

    def stock.method_missing(*args)
      self[args.shift] = args
    end

    def stock.respond_to_missing?(*_)
      nil
    end

    stock
  end

  let(:json) do
    {
      'thead' =>
        [
          {
            'dars_overall' => 'N/A',
            'growth_over_years' => '5.6',
            'consective_year_of_growth' => '17'
          }
        ]
    }
  end

  describe '#data' do
    it 'returns a hash' do
      data_saver.data(stock, json)

      calls = {
        'dividend_growth_3y=': [5.6],
        'dividend_growth_years=': [17],
        'dividend_rating=': [nil],
        save: []
      }

      expect(stock).to eq(calls)
    end
  end
end
