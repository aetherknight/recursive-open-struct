require_relative '../spec_helper'
require 'recursive_open_struct'

describe RecursiveOpenStruct do
  describe 'wrapping RecursiveOpenStruct' do
    let(:h) { { :blah => { :another => 'value' } } }
    subject(:ros) { RecursiveOpenStruct.new(RecursiveOpenStruct.new(h)) }

    it 'can convert the entire hash tree back into a hash' do
      expect(ros.to_h).to eq h
    end

    it 'can access the flat keys' do
      expect(ros.blah).to be_a(RecursiveOpenStruct)
    end

    it 'can access the nested keys' do
      expect(ros.blah.another).to eql('value')
    end

    it 'can be inspected' do
      expect(ros.inspect).to \
        eql('#<RecursiveOpenStruct blah={another: "value"}>')
    end
  end

  describe 'wrapping OpenStruct' do
    let(:h) { { :blah => { :another => 'value' } } }
    subject(:ros) { RecursiveOpenStruct.new(OpenStruct.new(h)) }

    it 'can convert the entire hash tree back into a hash' do
      expect(ros.to_h).to eq h
    end

    it 'can access the flat keys' do
      expect(ros.blah).to be_a(RecursiveOpenStruct)
    end

    it 'can access the nested keys' do
      expect(ros.blah.another).to eql('value')
    end

    it 'can be inspected' do
      expect(ros.inspect).to \
        eql('#<RecursiveOpenStruct blah={another: "value"}>')
    end
  end

  describe 'wrapping a subclass' do
    let(:h) { { :blah => { :another => 'value' } } }
    let(:subclass) { Class.new(RecursiveOpenStruct) }
    subject(:ros) { subclass.new(subclass.new(h)) }

    it 'can convert the entire hash tree back into a hash' do
      expect(ros.to_h).to eq h
    end

    it 'can access the flat keys' do
      expect(ros.blah).to be_a(RecursiveOpenStruct)
    end

    it 'can access the nested keys' do
      expect(ros.blah.another).to eql('value')
    end

    it 'can be inspected' do
      expect(ros.inspect).to \
        end_with(' blah={another: "value"}>')
    end
  end
end
