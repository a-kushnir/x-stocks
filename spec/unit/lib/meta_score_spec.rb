# frozen_string_literal: true

require 'unit/spec_helper'
require 'meta_score'

describe MetaScore do
  subject { described_class.new }

  describe '#calculate' do
    context 'when no data available' do
      let(:stock) { OpenStruct.new }

      it 'returns nils' do
        score = nil
        details = nil
        expect(subject.calculate(stock)).to eq([score, details])
      end
    end

    context 'when all data available' do
      let(:stock) do
        OpenStruct.new(yahoo_rec: 1.7, finnhub_rec: 2.1, payout_ratio: 31.1, dividend_rating: 4.3)
      end

      it 'returns score and details' do
        score = 87
        details = {
          div_safety: {
            score: 86,
            value: 4.3,
            weight: 4
          },
          finnhub_rec: {
            score: 80,
            value: 2.1,
            weight: 2
          },
          payout_ratio: {
            score: 91,
            value: 31.1,
            weight: 2
          },
          yahoo_rec: {
            score: 93,
            value: 1.7,
            weight: 2
          }
        }

        expect(subject.calculate(stock)).to eq([score, details])
      end

      context 'when payout is negative' do
        let(:stock) { OpenStruct.new(payout_ratio: -31.1) }

        it 'returns score and details' do
          score = 11
          details = {
            payout_ratio: {
              score: 11,
              value: -31.1,
              weight: 2
            }
          }

          expect(subject.calculate(stock)).to eq([score, details])
        end
      end

      context 'when payout is over a hundred percent' do
        let(:stock) { OpenStruct.new(payout_ratio: 131.1) }

        it 'returns score and details' do
          score = 20
          details = {
            payout_ratio: {
              score: 20,
              value: 131.1,
              weight: 2
            }
          }

          expect(subject.calculate(stock)).to eq([score, details])
        end
      end
    end
  end
end
