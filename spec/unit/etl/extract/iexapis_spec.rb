# frozen_string_literal: true

require 'unit/spec_helper'
require 'etl/extract/iexapis'

describe Etl::Extract::Iexapis do
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
    let(:url) { 'https://cloud.iexapis.com/stable/stock/SYMBOL/company?token=TOKEN' }

    it 'returns a hash' do
      expect(subject.company(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      subject.company(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end

  describe '#dividends' do
    let(:url) { 'https://cloud.iexapis.com/stable/stock/SYMBOL/dividends?token=TOKEN' }

    it 'returns a hash' do
      expect(subject.dividends(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      subject.dividends(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end

  describe '#dividends_1m' do
    let(:url) { 'https://cloud.iexapis.com/stable/stock/SYMBOL/dividends/1m?token=TOKEN' }

    it 'returns a hash' do
      expect(subject.dividends_1m(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      subject.dividends_1m(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end

  describe '#dividends_3m' do
    let(:url) { 'https://cloud.iexapis.com/stable/stock/SYMBOL/dividends/3m?token=TOKEN' }

    it 'returns a hash' do
      expect(subject.dividends_3m(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      subject.dividends_3m(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end

  describe '#dividends_6m' do
    let(:url) { 'https://cloud.iexapis.com/stable/stock/SYMBOL/dividends/6m?token=TOKEN' }

    it 'returns a hash' do
      expect(subject.dividends_6m(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      subject.dividends_6m(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end

  describe '#dividends_next' do
    let(:url) { 'https://cloud.iexapis.com/stable/stock/SYMBOL/dividends/next?token=TOKEN' }

    it 'returns a hash' do
      expect(subject.dividends_next(stock)).to eq({ result: true })
    end

    it 'calls get_json' do
      subject.dividends_next(stock)
      expect(data_loader).to have_received(:get_json)
    end
  end
end
