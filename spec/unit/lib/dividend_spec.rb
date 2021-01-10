# frozen_string_literal: true

require 'unit/spec_helper'
require 'dividend'

describe Dividend do
  subject { described_class.new }

  describe '#date_range' do
    it 'returns date range' do
      from_date = Date.today.at_beginning_of_month
      to_date = (from_date + 11.month).at_end_of_month
      expect(subject.date_range).to eq([from_date, to_date])
    end
  end

  describe '#months' do
    it 'returns the next 12 months' do
      month = Date.today.at_beginning_of_month
      months = (0..11).map { |i| month + i.month }
      expect(subject.months).to eq(months)
    end
  end

  describe '#estimate' do
    let(:periodic_dividend_details) { [{ 'payment_date' => Date.today.to_s(:db), 'amount' => 7.123456 }] }
    let(:div_suspended?) { false }
    let(:dividend_frequency) { 'annual' }

    let(:stock) do
      OpenStruct.new(
        periodic_dividend_details: periodic_dividend_details,
        div_suspended?: div_suspended?,
        dividend_frequency: dividend_frequency
      )
    end

    context 'when no dividend information' do
      let(:periodic_dividend_details) { [] }

      it 'returns nil' do
        expect(subject.estimate(stock)).to be_nil
      end
    end

    context 'when suspended dividends' do
      let(:div_suspended?) { true }

      it 'returns nil' do
        expect(subject.estimate(stock)).to be_nil
      end
    end

    context 'when unknown dividends' do
      let(:dividend_frequency) { 'unknown' }

      it 'returns estimated dividends' do
        month = Date.today.at_beginning_of_month
        payment_date = Date.today
        dividends = [
          { amount: 7.123456, month: month, payment_date: payment_date }
        ]
        expect(subject.estimate(stock)).to eq(dividends)
      end
    end

    context 'when annual dividends' do
      let(:dividend_frequency) { 'annual' }

      it 'returns estimated dividends' do
        month = Date.today.at_beginning_of_month
        payment_date = Date.today
        dividends = [
          { amount: 7.123456, month: month, payment_date: payment_date }
        ]
        expect(subject.estimate(stock)).to eq(dividends)
      end
    end

    context 'when semi-annual dividends' do
      let(:dividend_frequency) { 'semi-annual' }

      it 'returns estimated dividends' do
        month = Date.today.at_beginning_of_month
        payment_date = Date.today
        dividends = [
          { amount: 7.123456, month: month, payment_date: payment_date },
          { amount: 7.123456, month: month + 6.month, payment_date: payment_date + 6.month }
        ]
        expect(subject.estimate(stock)).to eq(dividends)
      end
    end

    context 'When quarterly dividends' do
      let(:dividend_frequency) { 'quarterly' }

      it 'returns estimated dividends' do
        month = Date.today.at_beginning_of_month
        payment_date = Date.today
        dividends = [
          { amount: 7.123456, month: month, payment_date: payment_date },
          { amount: 7.123456, month: month + 3.month, payment_date: payment_date + 3.month },
          { amount: 7.123456, month: month + 6.month, payment_date: payment_date + 6.month },
          { amount: 7.123456, month: month + 9.month, payment_date: payment_date + 9.month }
        ]
        expect(subject.estimate(stock)).to eq(dividends)
      end
    end

    context 'when monthly dividends' do
      let(:dividend_frequency) { 'monthly' }

      it 'returns estimated dividends' do
        month = Date.today.at_beginning_of_month
        payment_date = Date.today
        dividends = (0..11).map { |i| { amount: 7.123456, month: month + i.month, payment_date: payment_date + i.month } }
        expect(subject.estimate(stock)).to eq(dividends)
      end
    end
  end
end
