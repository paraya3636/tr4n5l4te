require 'spec_helper'

module Tr4n5l4te
  RSpec.describe Translator do
    let(:translator) { described_class.new }

    if ENV.fetch('INTEGRATION', false)
      context '.translate' do
        it 'translates a string' do
          expect(translator.translate('hello', :en, :es)).to match(/hola/i)
        end

        it 'translates another string' do
          expect(translator.translate('how are you', :en, :es)).to match(/cómo estás/i)
        end
      end
    end

    context '#new' do
      it 'returns the proper thing' do
        expect(translator).to be_a(described_class)
      end
    end

    context '.translate' do
      it 'returns an empty string if the argument is empty' do
        expect(translator).to_not receive(:load_cookies)
        expect(translator.translate('', :en, :es)).to eq('')
      end
    end
  end
end
