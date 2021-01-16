# frozen_string_literal: true

require 'unit/spec_helper'
require 'etl/transform/dividend'

describe Etl::Transform::Dividend do
  subject(:data_saver) { described_class.new }

  let(:stock) { mock_model }

  describe '#data' do
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

    it 'saves data into model' do
      data_saver.data(stock, json)

      calls = {
        dividend_growth_3y: 5.6,
        dividend_growth_years: 17,
        dividend_rating: nil,
        save: []
      }

      expect(stock).to eq(calls)
    end
  end
end
