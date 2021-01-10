# frozen_string_literal: true

require 'unit/spec_helper'
require 'etl/extract/slick_charts'

describe Etl::Extract::SlickCharts do
  subject { described_class.new(data_loader) }

  let(:data_loader) do
    data_loader = OpenStruct.new(get_text: nil)
    allow(data_loader).to receive(:get_text).with(url).and_return(body_html)
    data_loader
  end

  describe '#sp500' do
    let(:url) { 'https://www.slickcharts.com/sp500' }
    let(:body_html) { File.read("#{File.dirname(__FILE__)}/examples/slick_chart_sp500.html") }

    it 'returns an array' do
      expect(subject.sp500).to be_kind_of(Array)
    end

    it 'returns 505 items' do
      expect(subject.sp500.size).to eq(505)
    end

    it 'returns AAPL as the first item' do
      expect(subject.sp500.first).to eq('AAPL')
    end

    it 'calls get_text' do
      subject.sp500
      expect(data_loader).to have_received(:get_text)
    end
  end

  describe '#nasdaq100' do
    let(:url) { 'https://www.slickcharts.com/nasdaq100' }
    let(:body_html) { File.read("#{File.dirname(__FILE__)}/examples/slick_chart_nasdaq100.html") }

    it 'returns an array' do
      expect(subject.nasdaq100).to be_kind_of(Array)
    end

    it 'returns 102 items' do
      expect(subject.nasdaq100.size).to eq(102)
    end

    it 'returns AAPL as the first item' do
      expect(subject.nasdaq100.first).to eq('AAPL')
    end

    it 'calls get_text' do
      subject.nasdaq100
      expect(data_loader).to have_received(:get_text)
    end
  end

  describe '#dowjones' do
    let(:url) { 'https://www.slickcharts.com/dowjones' }
    let(:body_html) { File.read("#{File.dirname(__FILE__)}/examples/slick_chart_dowjones.html") }

    it 'returns an array' do
      expect(subject.dowjones).to be_kind_of(Array)
    end

    it 'returns 30 items' do
      expect(subject.dowjones.size).to eq(30)
    end

    it 'returns UNH as the first item' do
      expect(subject.dowjones.first).to eq('UNH')
    end

    it 'calls get_text' do
      subject.dowjones
      expect(data_loader).to have_received(:get_text)
    end
  end
end
