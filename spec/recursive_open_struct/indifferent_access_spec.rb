require_relative '../spec_helper'
require 'recursive_open_struct'

describe RecursiveOpenStruct do
  let(:value) { 'foo' }
  let(:symbol) { :bar }
  let(:new_value) { 'bar' }
  let(:new_symbol) { :foo }

  describe 'indifferent access' do
    let(:hash) { {:foo => value, 'bar' => symbol} }
    subject(:hash_ros) { RecursiveOpenStruct.new(hash) }
    context 'setting value with method' do

      before(:each) do
        subject.foo = value
      end

      it('allows getting with method') { expect(subject.foo).to be value }
      it('allows getting with symbol') { expect(subject[:foo]).to be value }
      it('allows getting with string') { expect(subject['foo']).to be value }

    end

    context 'setting value with symbol' do

      before(:each) do
        subject[:foo] = value
      end

      it('allows getting with method') { expect(subject.foo).to be value }
      it('allows getting with symbol') { expect(subject[:foo]).to be value }
      it('allows getting with string') { expect(subject['foo']).to be value }

    end

    context 'setting value with string' do

      before(:each) do
        subject['foo'] = value
      end

      it('allows getting with method') { expect(subject.foo).to be value }
      it('allows getting with symbol') { expect(subject[:foo]).to be value }
      it('allows getting with string') { expect(subject['foo']).to be value }

    end

    context 'overwriting values' do

      context 'set with method' do

        before(:each) do
          subject.foo = value
        end

        it('overrides with symbol') do
          subject[:foo] = new_value
          expect(subject.foo).to be new_value
        end

        it('overrides with string') do
          subject['foo'] = new_value
          expect(subject.foo).to be new_value
        end

      end

      context 'set with symbol' do

        before(:each) do
          subject[:foo] = value
        end

        it('overrides with method') do
          subject.foo = new_value
          expect(subject[:foo]).to be new_value
        end

        it('overrides with string') do
          subject['foo'] = new_value
          expect(subject[:foo]).to be new_value
        end

      end

      context 'set with string' do

        before(:each) do
          subject['foo'] = value
        end

        it('overrides with method') do
          subject.foo = new_value
          expect(subject['foo']).to be new_value
        end

        it('overrides with symbol') do
          subject[:foo] = new_value
          expect(subject['foo']).to be new_value
        end

      end

      context 'set with hash' do

        it('overrides with method') do
          hash_ros.foo = new_value
          expect(hash_ros[:foo]).to be new_value

          hash_ros.bar = new_symbol
          expect(hash_ros['bar']).to be new_symbol
        end

        it('overrides with symbol') do
          hash_ros[:bar] = new_symbol
          expect(hash_ros['bar']).to be new_symbol
        end

        it('overrides with string') do
          hash_ros['foo'] = new_value
          expect(hash_ros[:foo]).to be new_value
        end

      end

      context 'keeps original keys' do
        subject(:recursive) { RecursiveOpenStruct.new(recursive_hash, recurse_over_arrays: true) }
        let(:recursive_hash) { {:foo => [ {'bar' => [ { 'foo' => :bar} ] } ] } }
        let(:modified_hash) { {:foo => [ {'bar' => [ { 'foo' => :foo} ] } ] } }

        it 'after initialization' do
          expect(hash_ros.to_h).to eq hash
        end

        it 'in recursive hashes' do
          expect(recursive.to_h).to eq recursive_hash
        end

        it 'after resetting value' do
          recursive.foo.first[:bar].first[:foo] = :foo
          expect(recursive.to_h).to eq modified_hash
        end

      end

    end

  end
end
