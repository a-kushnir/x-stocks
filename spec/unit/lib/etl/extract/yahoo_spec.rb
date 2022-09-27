# frozen_string_literal: true

require 'unit/spec_helper'
require 'etl/extract/yahoo'

describe Etl::Extract::Yahoo do
  subject(:extractor) { described_class.new(data_loader, cgi: cgi) }

  let(:body_html) { File.read("#{File.dirname(__FILE__)}/examples/yahoo.html") }

  let(:data_loader) do
    url = 'https://finance.yahoo.com/quote/SYMBOL?p=SYMBOL'
    headers = {
      'user-agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.183 Safari/537.36'
    }

    data_loader = OpenStruct.new(get_text: nil)
    allow(data_loader).to receive(:get_text).with(url, headers).and_return(body_html)
    data_loader
  end

  let(:cgi) do
    cgi = OpenStruct.new(escape: nil)
    allow(cgi).to receive(:escape).with('SYMBOL').and_return('SYMBOL')
    cgi
  end

  let(:symbol) { 'SYMBOL' }

  describe '#summary' do
    it 'returns a hash' do
      expect(extractor.summary(symbol)).to be_a(Hash)
    end

    it 'returns a hash with 2 keys' do
      expect(extractor.summary(symbol).keys).to eq(%w[context plugins])
    end

    it 'calls get_text' do
      extractor.summary(symbol)
      expect(data_loader).to have_received(:get_text)
    end
  end
end
