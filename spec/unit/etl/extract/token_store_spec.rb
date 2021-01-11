# frozen_string_literal: true

require 'unit/spec_helper'
require 'etl/extract/token_store'

describe Etl::Extract::TokenStore do
  subject { described_class.new('KEY', logger, env: env) }

  let(:log_lines) { [] }

  let(:logger) do
    logger = OpenStruct.new(log_info: nil)
    log_lines.each do |log_line|
      allow(logger).to receive(:log_info).with(log_line)
    end
    logger
  end

  let(:env) do
    {
      'KEY' => 'TOKEN',
      'KEY_1' => 'TOKEN_1',
      'KEY_2' => 'TOKEN_2',
      'NON-KEY' => 'NON-TOKEN',
      'NON-KEY_2' => 'NON-TOKEN_2'
    }
  end

  describe '#try_token' do
    context "when block doesn't raise an exception" do
      let(:log_lines) { ['TokenStore: loaded 3 keys for KEY'] }

      before do
        allow(subject).to receive(:rand).with(3).and_return(1)
      end

      it 'yields block with a token' do
        tokens = []
        subject.try_token { |token| tokens << token }
        expect(tokens).to eq(['TOKEN_1'])
      end

      it 'leaves 3 keys' do
        subject.try_token {}
        expect(subject.tokens).to eq(%w[TOKEN TOKEN_1 TOKEN_2])
      end

      it 'calls rand method' do
        subject.try_token {}
        expect(subject).to have_received(:rand)
      end
    end

    context 'when block raises an exception' do
      let(:log_lines) { ['TokenStore: loaded 3 keys for KEY', 'TokenStore: TOKEN_1 disabled'] }

      before do
        allow(subject).to receive(:rand).with(3).and_return(1)
        allow(subject).to receive(:rand).with(2).and_return(1)
        allow(subject).to receive(:sleep).with(1)
      end

      it 'yields block twice with different tokens' do
        tokens = []
        subject.try_token do |token|
          tokens << token
          raise 'Some error happened' if token == 'TOKEN_1'
        end
        expect(tokens).to eq(%w[TOKEN_1 TOKEN_2])
      end

      it 'leaves 2 keys' do
        subject.try_token { |token| raise 'Some error happened' if token == 'TOKEN_1' }
        expect(subject.tokens).to eq(%w[TOKEN TOKEN_2])
      end

      it 'calls sleep method' do
        subject.try_token { |token| raise 'Some error happened' if token == 'TOKEN_1' }
        expect(subject).to have_received(:sleep)
      end
    end

    context 'when block raises exceptions' do
      let(:log_lines) { ['TokenStore: loaded 3 keys for KEY', 'TokenStore: TOKEN_1 disabled', 'TokenStore: TOKEN_2 disabled', 'TokenStore: TOKEN disabled'] }

      before do
        allow(subject).to receive(:rand).with(3).and_return(1)
        allow(subject).to receive(:rand).with(2).and_return(1)
        allow(subject).to receive(:rand).with(1).and_return(0)
        allow(subject).to receive(:sleep).with(1)
      end

      it 'yields block twice with different tokens' do
        tokens = []
        begin
          subject.try_token do |token|
            tokens << token
            raise 'Some error happened'
          end
        rescue StandardError
          nil
        end
        expect(tokens).to eq(%w[TOKEN_1 TOKEN_2 TOKEN])
      end

      it 'leaves 0 keys' do
        begin
          subject.try_token { raise 'Some error happened' }
        rescue StandardError
          nil
        end
        expect(subject.tokens).to eq(%w[])
      end

      it 'raises an error' do
        expect { subject.try_token { raise 'Some error happened' } }.to raise_error('All tokens are disabled')
      end
    end
  end

  describe '#random_token' do
    context 'when 3 tokens loaded' do
      let(:log_lines) { ['TokenStore: loaded 3 keys for KEY'] }

      before do
        allow(subject).to receive(:rand).with(3).and_return(1)
      end

      it 'returns a random token' do
        expect(subject.random_token).to eq('TOKEN_1')
      end

      it 'calls rand method' do
        subject.random_token
        expect(subject).to have_received(:rand)
      end
    end

    context 'when no tokens left' do
      let(:env) { { 'KEY' => 'TOKEN' } }
      let(:log_lines) { ['TokenStore: loaded 1 keys for KEY', 'TokenStore: TOKEN disabled'] }

      it 'raises an exception' do
        subject.disable_token('TOKEN')
        expect(subject.random_token).to be_nil
      end
    end

    context 'when no tokens loaded' do
      let(:env) { {} }
      let(:log_lines) { ['TokenStore: loaded 0 keys for KEY'] }

      it 'raises an exception' do
        expect { subject.random_token }.to raise_error('ENV[KEY] is required to use this API')
      end
    end
  end

  describe '#random_token!' do
    context 'when 3 tokens loaded' do
      let(:log_lines) { ['TokenStore: loaded 3 keys for KEY'] }

      before do
        allow(subject).to receive(:rand).with(3).and_return(1)
      end

      it 'returns a random token' do
        expect(subject.random_token!).to eq('TOKEN_1')
      end

      it 'calls rand method' do
        subject.random_token!
        expect(subject).to have_received(:rand)
      end
    end

    context 'when no tokens left' do
      let(:env) { { 'KEY' => 'TOKEN' } }
      let(:log_lines) { ['TokenStore: loaded 1 keys for KEY', 'TokenStore: TOKEN disabled'] }

      it 'raises an exception' do
        subject.disable_token('TOKEN')
        expect { subject.random_token! }.to raise_error('All tokens are disabled')
      end
    end

    context 'when no tokens loaded' do
      let(:env) { {} }
      let(:log_lines) { ['TokenStore: loaded 0 keys for KEY'] }

      it 'raises an exception' do
        expect { subject.random_token! }.to raise_error('ENV[KEY] is required to use this API')
      end
    end
  end

  describe '#disable_token' do
    context 'when token exists' do
      let(:log_lines) { ['TokenStore: loaded 3 keys for KEY', 'TokenStore: TOKEN_1 disabled'] }

      it 'returns deleted token' do
        expect(subject.disable_token('TOKEN_1')).to eq('TOKEN_1')
      end
    end

    context "when token doesn't exist" do
      let(:log_lines) { ['TokenStore: loaded 3 keys for KEY', 'TokenStore: TOKEN_7 not found'] }

      it 'return nil' do
        expect(subject.disable_token('TOKEN_7')).to be_nil
      end
    end

    context 'when no tokens loaded' do
      let(:env) { {} }
      let(:log_lines) { ['TokenStore: loaded 0 keys for KEY'] }

      it 'raises an exception' do
        expect { subject.disable_token('TOKEN_1') }.to raise_error('ENV[KEY] is required to use this API')
      end
    end
  end
end
