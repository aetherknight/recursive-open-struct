# frozen_string_literal: true

require_relative '../spec_helper'
require 'recursive_open_struct'

describe RecursiveOpenStruct do
  describe 'wrapping RecursiveOpenStruct' do
    subject(:ros) { described_class.new(described_class.new(h)) }

    let(:h) { { blah: { another: 'value' } } }

    it 'can convert the entire hash tree back into a hash' do
      expect(ros.to_h).to eq h
    end

    it 'can access the flat keys' do
      expect(ros.blah).to be_a(described_class)
    end

    it 'can access the nested keys' do
      expect(ros.blah.another).to eql('value')
    end

    it 'can be inspected' do
      expect(ros.inspect).to \
        match(/#<RecursiveOpenStruct blah={:?another(: |=>)"value"}>/)
    end
  end

  describe 'wrapping OpenStruct' do
    subject(:ros) { described_class.new(OpenStruct.new(h)) }

    let(:h) { { blah: { another: 'value' } } }

    it 'can convert the entire hash tree back into a hash' do
      expect(ros.to_h).to eq h
    end

    it 'can access the flat keys' do
      expect(ros.blah).to be_a(described_class)
    end

    it 'can access the nested keys' do
      expect(ros.blah.another).to eql('value')
    end

    it 'can be inspected' do
      expect(ros.inspect).to \
        match(/#<RecursiveOpenStruct blah={:?another(: |=>)"value"}>/)
    end
  end

  describe 'wrapping a subclass' do
    subject(:ros) { subclass.new(subclass.new(h)) }

    let(:h) { { blah: { another: 'value' } } }
    let(:subclass) { Class.new(described_class) }

    it 'can convert the entire hash tree back into a hash' do
      expect(ros.to_h).to eq h
    end

    it 'can access the flat keys' do
      expect(ros.blah).to be_a(described_class)
    end

    it 'can access the nested keys' do
      expect(ros.blah.another).to eql('value')
    end

    it 'can be inspected' do
      expect(ros.inspect).to match(/ blah={:?another(: |=>)"value"}>$/)
    end
  end
end
