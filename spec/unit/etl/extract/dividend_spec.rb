# frozen_string_literal: true

require 'unit/spec_helper'
require 'etl/extract/dividend'

describe Etl::Extract::Dividend do
  subject(:extractor) { described_class.new(data_loader, uri: uri) }

  let(:data_loader) do
    url = 'https://www.dividend.com/api/data_set/'
    body = {
      'default_tab' => 'best-dividend-stocks',
      'only' => %w[meta data thead],
      'r' => 'ES::DividendStock::Stock#SYMBOL--DIV_CODE',
      'selected_symbols' => ['SYMBOL--DIV_CODE'],
      'tm' => '3-comparison-center'
    }

    data_loader = OpenStruct.new(post_json: nil)
    allow(data_loader).to receive(:post_json).with(url, body).and_return({ result: true })
    data_loader
  end

  let(:uri) do
    uri = OpenStruct.new(escape: nil)
    allow(uri).to receive(:escape).with('SYMBOL--DIV_CODE').and_return('SYMBOL--DIV_CODE')
    uri
  end

  let(:exchange) { OpenStruct.new(dividend_code: 'DIV_CODE') }
  let(:stock) { OpenStruct.new(symbol: 'SYMBOL', exchange: exchange) }

  describe '#data' do
    it 'returns a hash' do
      expect(extractor.data(stock)).to eq({ result: true })
    end

    it 'calls post_json' do
      extractor.data(stock)
      expect(data_loader).to have_received(:post_json)
    end
  end
end
