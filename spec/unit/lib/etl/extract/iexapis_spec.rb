# frozen_string_literal: true

require 'unit/spec_helper'
require 'etl/extract/iexapis'

describe Etl::Extract::Iexapis do
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
    let(:url) { 'https://cloud.iexapis.com/stable/stock/SYMBOL/company?token=TOKEN' }

    it 'returns a hash' do
      expect(extractor.company(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      extractor.company(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end

  describe '#dividends' do
    let(:url) { 'https://cloud.iexapis.com/stable/stock/SYMBOL/dividends?token=TOKEN' }

    it 'returns a hash' do
      expect(extractor.dividends(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      extractor.dividends(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end

  describe '#dividends_1m' do
    let(:url) { 'https://cloud.iexapis.com/stable/stock/SYMBOL/dividends/1m?token=TOKEN' }

    it 'returns a hash' do
      expect(extractor.dividends_1m(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      extractor.dividends_1m(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end

  describe '#dividends_3m' do
    let(:url) { 'https://cloud.iexapis.com/stable/stock/SYMBOL/dividends/3m?token=TOKEN' }

    it 'returns a hash' do
      expect(extractor.dividends_3m(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      extractor.dividends_3m(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end

  describe '#dividends_6m' do
    let(:url) { 'https://cloud.iexapis.com/stable/stock/SYMBOL/dividends/6m?token=TOKEN' }

    it 'returns a hash' do
      expect(extractor.dividends_6m(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      extractor.dividends_6m(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end

  describe '#dividends_next' do
    let(:url) { 'https://cloud.iexapis.com/stable/stock/SYMBOL/dividends/next?token=TOKEN' }

    it 'returns a hash' do
      expect(extractor.dividends_next(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      extractor.dividends_next(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end
end
