# frozen_string_literal: true

require 'unit/spec_helper'
require 'etl/extract/finnhub'

describe Etl::Extract::Finnhub do
  subject(:extractor) { described_class.new(data_loader, 'TOKEN', cgi: cgi) }

  let(:data_loader) do
    data_loader = OpenStruct.new(get_json: nil)
    allow(data_loader).to receive(:get_json).with(url).and_return({ result: true })
    data_loader
  end

  let(:cgi) do
    cgi = OpenStruct.new(escape: nil)
    allow(cgi).to receive(:escape).with('SYMBOL').and_return('SYMBOL')
    cgi
  end

  let(:stock) { OpenStruct.new(symbol: 'SYMBOL') }

  describe '#company' do
    let(:url) { 'https://finnhub.io/api/v1/stock/profile2?symbol=SYMBOL&token=TOKEN' }

    it 'returns a hash' do
      expect(extractor.company(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      extractor.company(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end

  describe '#peers' do
    let(:url) { 'https://finnhub.io/api/v1/stock/peers?symbol=SYMBOL&token=TOKEN' }

    it 'returns a hash' do
      expect(extractor.peers(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      extractor.peers(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end

  describe '#quote' do
    let(:url) { 'https://finnhub.io/api/v1/quote?symbol=SYMBOL&token=TOKEN' }

    it 'returns a hash' do
      expect(extractor.quote(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      extractor.quote(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end

  describe '#recommendation' do
    let(:url) { 'https://finnhub.io/api/v1/stock/recommendation?symbol=SYMBOL&token=TOKEN' }

    it 'returns a hash' do
      expect(extractor.recommendation(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      extractor.recommendation(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end

  describe '#price_target' do
    let(:url) { 'https://finnhub.io/api/v1/stock/price-target?symbol=SYMBOL&token=TOKEN' }

    it 'returns a hash' do
      expect(extractor.price_target(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      extractor.price_target(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end

  describe '#earnings' do
    let(:url) { 'https://finnhub.io/api/v1/stock/earnings?symbol=SYMBOL&token=TOKEN' }

    it 'returns a hash' do
      expect(extractor.earnings(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      extractor.earnings(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end

  describe '#metric' do
    let(:url) { 'https://finnhub.io/api/v1/stock/metric?symbol=SYMBOL&metric=all&token=TOKEN' }

    it 'returns a hash' do
      expect(extractor.metric(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      extractor.metric(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end

  describe '#earnings_calendar' do
    let(:url) { 'https://finnhub.io/api/v1/calendar/earnings?from=2020-01-01&to=2020-06-01&token=TOKEN' }

    it 'returns a hash' do
      expect(extractor.earnings_calendar(Date.new(2020, 1, 1), Date.new(2020, 6, 1))).to eq({ result: true })
    end

    it 'calls get_json' do
      extractor.earnings_calendar(Date.new(2020, 1, 1), Date.new(2020, 6, 1))
      expect(data_loader).to have_received(:get_json)
    end
  end
end
