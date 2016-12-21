require_relative '../spec_helper'
require 'recursive_open_struct'

describe RecursiveOpenStruct do
  let(:hash) { {} }
  subject(:ros) { RecursiveOpenStruct.new(hash) }

  describe "behavior it inherits from OpenStruct" do
    context 'when not initialized from anything' do
      subject(:ros) { RecursiveOpenStruct.new }
      it "can represent arbitrary data objects" do
        ros.blah = "John Smith"
        expect(ros.blah).to eq "John Smith"
      end

      it 'returns nil for missing attributes' do
        expect(ros.foo).to be_nil
      end
    end

    context 'when initialized with nil' do
      let(:hash) { nil }
      it 'returns nil for missing attributes' do
        expect(ros.foo).to be_nil
      end
    end

    context 'when initialized with an empty hash' do
      it 'returns nil for missing attributes' do
        expect(ros.foo).to be_nil
      end
    end

    context "when initialized from a hash" do
      let(:hash) { { :asdf => 'John Smith' } }

      context 'that contains symbol keys' do
        it "turns those symbol keys into method names" do
          expect(ros.asdf).to eq "John Smith"
        end
      end

      it "can modify an existing key" do
        ros.asdf = "George Washington"
        expect(ros.asdf).to eq "George Washington"
      end

      context 'that contains string keys' do
        let(:hash) { { 'asdf' => 'John Smith' } }
        it "turns those string keys into method names" do
          expect(ros.asdf).to eq "John Smith"
        end
      end

      context 'that contains keys that mirror existing private methods' do
        let(:hash) { { test: :foo, rand: 'not a number' } }

        # https://github.com/aetherknight/recursive-open-struct/issues/42
        it 'handles subscript notation without calling the method name first (#42)' do
          expect(ros['test']).to eq :foo
          expect(ros['rand']).to eq 'not a number'

          expect(ros.test).to eq :foo
          expect(ros.rand).to eq 'not a number'
        end
      end

      if [/\A([0-9]+)\.([0-9]+)\.([0-9]+)\z/.match(RUBY_VERSION)].tap { |l| m = l[0] ; l[0] = (m[1].to_i >= 2 && m[2].to_i >= 4) }.first
        context 'when Ruby 2.4.0 or newer' do
          specify 'new_ostruct_member! is private' do
            expect {
              ros.new_ostruct_member!(:bonsoir)
            }.to raise_error(NoMethodError)
              # OpenStruct.new().new_ostruct_member!(:foo)
          end
        end
      end

    end


    describe "handling of arbitrary attributes" do
      subject { RecursiveOpenStruct.new }
      before(:each) do
        subject.blah = "John Smith"
      end

      describe "#respond?" do
        it { expect(subject).to respond_to :blah }
        it { expect(subject).to respond_to :blah= }
        it { expect(subject).to_not respond_to :asdf }
        it { expect(subject).to_not respond_to :asdf= }
      end # describe #respond?

      describe "#methods" do
        it { expect(subject.methods.map(&:to_sym)).to include :blah }
        it { expect(subject.methods.map(&:to_sym)).to include :blah= }
        it { expect(subject.methods.map(&:to_sym)).to_not include :asdf }
        it { expect(subject.methods.map(&:to_sym)).to_not include :asdf= }
      end # describe #methods
    end # describe handling of arbitrary attributes
  end # describe behavior it inherits from OpenStruct
end
