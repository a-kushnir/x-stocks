# frozen_string_literal: true

require 'unit/spec_helper'
require 'dividend'

describe Dividend do
  subject(:calculator) { described_class.new(date: date) }

  let(:date) { OpenStruct.new(today: Date.new(2020, 1, 11)) }

  describe '#date_range' do
    it 'returns date range' do
      from_date = date.today.at_beginning_of_month
      to_date = (from_date + 11.month).at_end_of_month
      expect(calculator.date_range).to eq([from_date, to_date])
    end
  end

  describe '#months' do
    it 'returns the next 12 months' do
      month = date.today.at_beginning_of_month
      months = (0..11).map { |i| month + i.month }
      expect(calculator.months).to eq(months)
    end
  end

  describe '#estimate' do
    let(:periodic_dividend_details) { [{ 'payment_date' => date.today.to_fs(:db), 'ex_date' => (date.today - 10).to_fs(:db), 'amount' => 7.123456 }] }
    let(:div_suspended?) { false }
    let(:dividend_frequency) { 'annual' }

    let(:stock) { mock_model(dividend_frequency: dividend_frequency, periodic_dividend_details: periodic_dividend_details, div_suspended?: div_suspended?) }

    context 'when no dividend information' do
      let(:periodic_dividend_details) { [] }

      it 'returns nil' do
        expect(calculator.estimate(stock)).to be_nil
      end
    end

    context 'when suspended dividends' do
      let(:div_suspended?) { true }

      it 'returns nil' do
        expect(calculator.estimate(stock)).to be_nil
      end
    end

    context 'when unknown dividends' do
      let(:dividend_frequency) { 'unknown' }

      it 'returns estimated dividends' do
        month = date.today.at_beginning_of_month
        today = date.today
        dividends = [
          { amount: 7.123456, month: month, ex_date: today - 10, payment_date: today }
        ]
        expect(calculator.estimate(stock)).to eq(dividends)
      end
    end

    context 'when annual dividends' do
      let(:dividend_frequency) { 'annual' }

      it 'returns estimated dividends' do
        month = date.today.at_beginning_of_month
        today = date.today
        dividends = [
          { amount: 7.123456, month: month, ex_date: today - 10, payment_date: today }
        ]
        expect(calculator.estimate(stock)).to eq(dividends)
      end
    end

    context 'when semi-annual dividends' do
      let(:dividend_frequency) { 'semi-annual' }

      it 'returns estimated dividends' do
        month = date.today.at_beginning_of_month
        today = date.today
        dividends = [
          { amount: 7.123456, month: month + 0.month, ex_date: today - 10 + 0.month, payment_date: today + 0.month },
          { amount: 7.123456, month: month + 6.month, ex_date: today - 10 + 6.month, payment_date: today + 6.month }
        ]
        expect(calculator.estimate(stock)).to eq(dividends)
      end
    end

    context 'when quarterly dividends' do
      let(:dividend_frequency) { 'quarterly' }

      it 'returns estimated dividends' do
        month = date.today.at_beginning_of_month
        today = date.today
        dividends = [
          { amount: 7.123456, month: month + 0.month, ex_date: today - 10 + 0.month, payment_date: today + 0.month },
          { amount: 7.123456, month: month + 3.month, ex_date: today - 10 + 3.month, payment_date: today + 3.month },
          { amount: 7.123456, month: month + 6.month, ex_date: today - 10 + 6.month, payment_date: today + 6.month },
          { amount: 7.123456, month: month + 9.month, ex_date: today - 10 + 9.month, payment_date: today + 9.month }
        ]
        expect(calculator.estimate(stock)).to eq(dividends)
      end
    end

    context 'when monthly dividends' do
      let(:dividend_frequency) { 'monthly' }

      it 'returns estimated dividends' do
        month = date.today.at_beginning_of_month
        today = date.today
        dividends = (0..11).map { |i| { amount: 7.123456, month: month + i.month, ex_date: today - 10 + i.month, payment_date: today + i.month } }
        expect(calculator.estimate(stock)).to eq(dividends)
      end
    end
  end
end
