# frozen_string_literal: true

require 'unit/spec_helper'
require 'etl/extract/fear_n_greed'

describe Etl::Extract::FearNGreed do
  subject { described_class.new(data_loader) }

  let(:body_html) { File.read("#{File.dirname(__FILE__)}/examples/fear_n_greed.html") }

  let(:data_loader) do
    url = 'https://money.cnn.com/data/fear-and-greed/'

    data_loader = OpenStruct.new(get_text: nil)
    allow(data_loader).to receive(:get_text).with(url).and_return(body_html)
    data_loader
  end

  describe '#image_url' do
    it 'returns a hash' do
      url = 'http://markets.money.cnn.com/Marketsdata/uploadhandler/z678f7d0azf0418f2a1cdc44b58068df6f8eaed267.png'
      expect(subject.image_url).to eq(url)
    end

    it 'calls get_text' do
      subject.image_url
      expect(data_loader).to have_received(:get_text)
    end
  end
end
