# frozen_string_literal: true

require 'unit/spec_helper'
require 'etl/extract/token_store'

describe Etl::Extract::TokenStore do
  subject(:token_store) { described_class.new('KEY', logger, env: env, kernel: kernel) }

  let(:logger) do
    logger = []
    def logger.log_info(log_line)
      self << log_line
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

  let(:kernel) do
    kernel = OpenStruct.new
    def kernel.rand(*_); end

    def kernel.sleep(*_); end
    kernel
  end

  describe '#try_token' do
    context "when block doesn't raise an exception" do
      before do
        allow(kernel).to receive(:rand).with(3).and_return(1)
      end

      it 'yields block with a token' do
        tokens = []
        token_store.try_token { |token| tokens << token }
        expect(tokens).to eq(['TOKEN_1'])
      end

      it 'leaves 3 keys' do
        token_store.try_token {}
        expect(token_store.tokens).to eq(%w[TOKEN TOKEN_1 TOKEN_2])
      end

      it 'logs events' do
        token_store.try_token {}
        expect(logger).to eq(['TokenStore: loaded 3 keys for KEY'])
      end

      it 'calls rand method' do
        token_store.try_token {}
        expect(kernel).to have_received(:rand)
      end
    end

    context 'when block raises an exception' do
      before do
        allow(kernel).to receive(:rand).with(3).and_return(1)
        allow(kernel).to receive(:rand).with(2).and_return(1)
        allow(kernel).to receive(:sleep).with(1)
      end

      it 'yields block twice with different tokens' do
        tokens = []
        token_store.try_token do |token|
          tokens << token
          raise 'Some error happened' if token == 'TOKEN_1'
        end
        expect(tokens).to eq(%w[TOKEN_1 TOKEN_2])
      end

      it 'leaves 2 keys' do
        token_store.try_token { |token| raise 'Some error happened' if token == 'TOKEN_1' }
        expect(token_store.tokens).to eq(%w[TOKEN TOKEN_2])
      end

      it 'logs events' do
        token_store.try_token { |token| raise 'Some error happened' if token == 'TOKEN_1' }
        expect(logger).to eq(['TokenStore: loaded 3 keys for KEY', 'TokenStore: TOKEN_1 disabled'])
      end

      it 'calls sleep method' do
        token_store.try_token { |token| raise 'Some error happened' if token == 'TOKEN_1' }
        expect(kernel).to have_received(:sleep)
      end
    end

    context 'when block raises exceptions' do
      before do
        allow(kernel).to receive(:rand).with(3).and_return(1)
        allow(kernel).to receive(:rand).with(2).and_return(1)
        allow(kernel).to receive(:rand).with(1).and_return(0)
        allow(kernel).to receive(:sleep).with(1)
      end

      it 'yields block twice with different tokens' do
        tokens = []

        safe_exec do
          token_store.try_token do |token|
            tokens << token
            raise 'Some error happened'
          end
        end

        expect(tokens).to eq(%w[TOKEN_1 TOKEN_2 TOKEN])
      end

      it 'leaves 0 keys' do
        safe_exec { token_store.try_token { raise 'Some error happened' } }
        expect(token_store.tokens).to eq(%w[])
      end

      it 'raises an error' do
        expect { token_store.try_token { raise 'Some error happened' } }.to raise_error('All tokens are disabled')
      end

      it 'logs events' do
        logged_events = [
          'TokenStore: loaded 3 keys for KEY',
          'TokenStore: TOKEN_1 disabled',
          'TokenStore: TOKEN_2 disabled',
          'TokenStore: TOKEN disabled'
        ]
        safe_exec { token_store.try_token { raise 'Some error happened' } }
        expect(logger).to eq(logged_events)
      end
    end
  end

  describe '#random_token' do
    context 'when 3 tokens loaded' do
      before do
        allow(kernel).to receive(:rand).with(3).and_return(1)
      end

      it 'returns a random token' do
        expect(token_store.random_token).to eq('TOKEN_1')
      end

      it 'logs events' do
        token_store.random_token
        expect(logger).to eq(['TokenStore: loaded 3 keys for KEY'])
      end

      it 'calls rand method' do
        token_store.random_token
        expect(kernel).to have_received(:rand)
      end
    end

    context 'when no tokens left' do
      let(:env) { { 'KEY' => 'TOKEN' } }

      it 'raises an exception' do
        token_store.disable_token('TOKEN')
        expect(token_store.random_token).to be_nil
      end

      it 'logs events' do
        token_store.disable_token('TOKEN')
        expect(logger).to eq(['TokenStore: loaded 1 keys for KEY', 'TokenStore: TOKEN disabled'])
      end
    end

    context 'when no tokens loaded' do
      let(:env) { {} }

      it 'raises an exception' do
        expect { token_store.random_token }.to raise_error('ENV[KEY] is required to use this API')
      end

      it 'logs events' do
        safe_exec { token_store.random_token }
        expect(logger).to eq(['TokenStore: loaded 0 keys for KEY'])
      end
    end
  end

  describe '#random_token!' do
    context 'when 3 tokens loaded' do
      before do
        allow(kernel).to receive(:rand).with(3).and_return(1)
      end

      it 'returns a random token' do
        expect(token_store.random_token!).to eq('TOKEN_1')
      end

      it 'calls rand method' do
        token_store.random_token!
        expect(kernel).to have_received(:rand)
      end

      it 'logs events' do
        token_store.random_token!
        expect(logger).to eq(['TokenStore: loaded 3 keys for KEY'])
      end
    end

    context 'when no tokens left' do
      let(:env) { { 'KEY' => 'TOKEN' } }

      it 'raises an exception' do
        token_store.disable_token('TOKEN')
        expect { token_store.random_token! }.to raise_error('All tokens are disabled')
      end

      it 'logs events' do
        token_store.disable_token('TOKEN')
        expect(logger).to eq(['TokenStore: loaded 1 keys for KEY', 'TokenStore: TOKEN disabled'])
      end
    end

    context 'when no tokens loaded' do
      let(:env) { {} }

      it 'raises an exception' do
        expect { token_store.random_token! }.to raise_error('ENV[KEY] is required to use this API')
      end

      it 'logs events' do
        safe_exec { token_store.random_token! }
        expect(logger).to eq(['TokenStore: loaded 0 keys for KEY'])
      end
    end
  end

  describe '#disable_token' do
    context 'when token exists' do
      it 'returns deleted token' do
        expect(token_store.disable_token('TOKEN_1')).to eq('TOKEN_1')
      end

      it 'logs events' do
        token_store.disable_token('TOKEN_1')
        expect(logger).to eq(['TokenStore: loaded 3 keys for KEY', 'TokenStore: TOKEN_1 disabled'])
      end
    end

    context "when token doesn't exist" do
      it 'return nil' do
        expect(token_store.disable_token('TOKEN_7')).to be_nil
      end

      it 'logs events' do
        token_store.disable_token('TOKEN_7')
        expect(logger).to eq(['TokenStore: loaded 3 keys for KEY', 'TokenStore: TOKEN_7 not found'])
      end
    end

    context 'when no tokens loaded' do
      let(:env) { {} }

      it 'raises an exception' do
        expect { token_store.disable_token('TOKEN_1') }.to raise_error('ENV[KEY] is required to use this API')
      end

      it 'logs events' do
        safe_exec { token_store.disable_token('TOKEN_1') }
        expect(logger).to eq(['TokenStore: loaded 0 keys for KEY'])
      end
    end
  end
end
