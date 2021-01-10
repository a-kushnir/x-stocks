# frozen_string_literal: true

require 'unit/spec_helper'
require 'etl/extract/finnhub'

describe Etl::Extract::Finnhub do
  subject { described_class.new(data_loader, 'TOKEN', uri: uri) }

  let(:data_loader) do
    data_loader = OpenStruct.new(get_json: nil)
    allow(data_loader).to receive(:get_json).with(url).and_return({ result: true })
    data_loader
  end

  let(:uri) do
    uri = OpenStruct.new(escape: nil)
    allow(uri).to receive(:escape).with('SYMBOL').and_return('SYMBOL')
    uri
  end

  let(:stock) { OpenStruct.new(symbol: 'SYMBOL') }

  describe '#company' do
    let(:url) { 'https://finnhub.io/api/v1/stock/profile2?symbol=SYMBOL&token=TOKEN' }

    it 'returns a hash' do
      expect(subject.company(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      subject.company(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end

  describe '#peers' do
    let(:url) { 'https://finnhub.io/api/v1/stock/peers?symbol=SYMBOL&token=TOKEN' }

    it 'returns a hash' do
      expect(subject.peers(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      subject.peers(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end

  describe '#quote' do
    let(:url) { 'https://finnhub.io/api/v1/quote?symbol=SYMBOL&token=TOKEN' }

    it 'returns a hash' do
      expect(subject.quote(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      subject.quote(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end

  describe '#recommendation' do
    let(:url) { 'https://finnhub.io/api/v1/stock/recommendation?symbol=SYMBOL&token=TOKEN' }

    it 'returns a hash' do
      expect(subject.recommendation(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      subject.recommendation(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end

  describe '#price_target' do
    let(:url) { 'https://finnhub.io/api/v1/stock/price-target?symbol=SYMBOL&token=TOKEN' }

    it 'returns a hash' do
      expect(subject.price_target(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      subject.price_target(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end

  describe '#earnings' do
    let(:url) { 'https://finnhub.io/api/v1/stock/earnings?symbol=SYMBOL&token=TOKEN' }

    it 'returns a hash' do
      expect(subject.earnings(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      subject.earnings(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end

  describe '#metric' do
    let(:url) { 'https://finnhub.io/api/v1/stock/metric?symbol=SYMBOL&metric=all&token=TOKEN' }

    it 'returns a hash' do
      expect(subject.metric(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      subject.metric(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end

  describe '#earnings_calendar' do
    let(:url) { 'https://finnhub.io/api/v1/calendar/earnings?from=2020-01-01&to=2020-06-01&token=TOKEN' }

    it 'returns a hash' do
      expect(subject.earnings_calendar(Date.new(2020, 1, 1), Date.new(2020, 6, 1))).to eq({ result: true })
    end

    it 'calls get_json' do
      subject.earnings_calendar(Date.new(2020, 1, 1), Date.new(2020, 6, 1))
      expect(data_loader).to have_received(:get_json)
    end
  end
end
