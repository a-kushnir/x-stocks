# frozen_string_literal: true

require 'unit/spec_helper'
require 'etl/transform/slick_charts'

describe Etl::Transform::SlickCharts do
  subject(:transformer) { described_class.new(stock_class: stock) }

  let(:stock) do
    stock = OpenStruct.new(where: nil, pluck: nil, update_all: nil, not: nil)

    allow(stock).to receive(:where).with({ symbol: symbols }).and_return(stock)
    allow(stock).to receive(:pluck).with(:id).and_return(stock_ids)

    allow(stock).to receive(:where).with({ id: stock_ids }).and_return(stock)
    allow(stock).to receive(:update_all).with({ column => true })

    allow(stock).to receive(:where).and_return(stock)
    allow(stock).to receive(:not).with({ id: stock_ids }).and_return(stock)
    allow(stock).to receive(:update_all).with({ column => false })

    stock
  end

  describe '#sp500' do
    let(:column) { :sp500 }
    let(:symbols) { %w[AAPL MSFT] }
    let(:stock_ids) { [6, 32] }

    it 'saves data into model' do
      transformer.sp500(symbols)
      expect(stock).to have_received(:update_all).twice
    end
  end

  describe '#nasdaq100' do
    let(:column) { :nasdaq100 }
    let(:symbols) { %w[AAPL MSFT TSLA] }
    let(:stock_ids) { [6, 32, 78] }

    it 'saves data into model' do
      transformer.nasdaq100(symbols)
      expect(stock).to have_received(:update_all).twice
    end
  end

  describe '#dow_jones' do
    let(:column) { :dowjones }
    let(:symbols) { %w[AAPL] }
    let(:stock_ids) { [6] }

    it 'saves data into model' do
      transformer.dow_jones(symbols)
      expect(stock).to have_received(:update_all).twice
    end
  end
end
