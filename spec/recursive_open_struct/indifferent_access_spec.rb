# frozen_string_literal: true

require_relative '../spec_helper'
require 'recursive_open_struct'

describe RecursiveOpenStruct do
  describe 'indifferent access' do
    subject(:hash_ros) { described_class.new(hash, hash_ros_opts) }

    let(:hash) { { :foo => value, 'bar' => :bar } }
    let(:hash_ros_opts) { {} }

    describe 'setting value with method' do
      let(:value) { 'foo' }

      before do
        hash_ros.foo = value
      end

      it('allows getting with method') { expect(hash_ros.foo).to be value }
      it('allows getting with symbol') { expect(hash_ros[:foo]).to be value }
      it('allows getting with string') { expect(hash_ros['foo']).to be value }
    end

    describe 'setting value with symbol' do
      let(:value) { 'foo' }

      before do
        hash_ros[:foo] = value
      end

      it('allows getting with method') { expect(hash_ros.foo).to be value }
      it('allows getting with symbol') { expect(hash_ros[:foo]).to be value }
      it('allows getting with string') { expect(hash_ros['foo']).to be value }
    end

    describe 'setting value with string' do
      let(:value) { 'foo' }

      before do
        hash_ros['foo'] = value
      end

      it('allows getting with method') { expect(hash_ros.foo).to be value }
      it('allows getting with symbol') { expect(hash_ros[:foo]).to be value }
      it('allows getting with string') { expect(hash_ros['foo']).to be value }
    end

    describe 'overwriting values' do
      let(:value) { 'foo' }
      let(:new_value) { 'bar' }

      describe 'set with method' do
        before do
          hash_ros.foo = value
        end

        it('overrides with symbol') do
          hash_ros[:foo] = new_value
          expect(hash_ros.foo).to be new_value
        end

        it('overrides with string') do
          hash_ros['foo'] = new_value
          expect(hash_ros.foo).to be new_value
        end
      end

      describe 'set with symbol' do
        before do
          hash_ros[:foo] = value
        end

        it('overrides with method') do
          hash_ros.foo = new_value
          expect(hash_ros[:foo]).to be new_value
        end

        it('overrides with string') do
          hash_ros['foo'] = new_value
          expect(hash_ros[:foo]).to be new_value
        end
      end

      describe 'set with string' do
        before do
          hash_ros['foo'] = value
        end

        it('overrides with method') do
          hash_ros.foo = new_value
          expect(hash_ros['foo']).to be new_value
        end

        it('overrides with symbol') do
          hash_ros[:foo] = new_value
          expect(hash_ros['foo']).to be new_value
        end
      end

      describe 'set with hash' do
        it('overrides with method') do
          hash_ros.foo = new_value
          expect(hash_ros[:foo]).to be new_value
          new_symbol = :foo
          hash_ros.bar = new_symbol
          expect(hash_ros['bar']).to be new_symbol
        end

        it('overrides with symbol') do
          new_symbol = :foo
          hash_ros[:bar] = new_symbol
          expect(hash_ros['bar']).to be new_symbol
        end

        it('overrides with string') do
          hash_ros['foo'] = new_value
          expect(hash_ros[:foo]).to be new_value
        end
      end

      context 'when preserve_original_keys is not enabled' do
        # rubocop:disable RSpec/MultipleMemoizedHelpers
        describe 'transforms original keys to symbols' do
          subject(:recursive) { described_class.new(recursive_hash, recurse_over_arrays: true) }

          let(:recursive_hash) { { foo: [{ 'bar' => [{ 'foo' => :bar }] }] } }
          let(:symbolized_recursive_hash) { { foo: [{ bar: [{ foo: :bar }] }] } }
          let(:symbolized_modified_hash) { { foo: [{ bar: [{ foo: :foo }] }] } }
          let(:symbolized_hash) { Hash[hash.map { |(k, v)| [k.to_sym, v] }] }

          specify 'after initialization' do
            expect(hash_ros.to_h).to eq symbolized_hash
          end

          specify 'in recursive hashes' do
            expect(recursive.to_h).to eq symbolized_recursive_hash
          end

          specify 'after resetting value' do
            recursive.foo.first[:bar].first[:foo] = :foo
            expect(recursive.to_h).to eq symbolized_modified_hash
          end
        end
        # rubocop:enable RSpec/MultipleMemoizedHelpers
      end

      context 'when preserve_original_keys is enabled' do
        # rubocop:disable RSpec/MultipleMemoizedHelpers
        describe 'preserves the original keys' do
          subject(:recursive) do
            described_class.new(recursive_hash, recurse_over_arrays: true, preserve_original_keys: true)
          end

          let(:recursive_hash) { { foo: [{ 'bar' => [{ 'foo' => :bar }] }] } }
          let(:modified_hash) { { foo: [{ 'bar' => [{ 'foo' => :foo }] }] } }

          let(:hash_ros_opts) { { preserve_original_keys: true } }

          specify 'after initialization' do
            expect(hash_ros.to_h).to eq hash
          end

          specify 'in recursive hashes' do
            expect(recursive.to_h).to eq recursive_hash
          end

          specify 'after resetting value' do
            recursive.foo.first[:bar].first[:foo] = :foo
            expect(recursive.to_h).to eq modified_hash
          end
        end
        # rubocop:enable RSpec/MultipleMemoizedHelpers
      end

      context 'when undefined method' do
        context 'when raise_on_missing is enabled' do
          subject(:recursive) { described_class.new(recursive_hash, raise_on_missing: true) }

          let(:recursive_hash) { { foo: [{ 'bar' => [{ 'foo' => :bar }] }] } }

          specify 'raises NoMethodError' do
            expect do
              recursive.undefined_method
            end.to raise_error(NoMethodError)
          end
        end

        context 'when raise_on_missing is disabled' do
          subject(:recursive) { described_class.new(recursive_hash) }

          let(:recursive_hash) { { foo: [{ 'bar' => [{ 'foo' => :bar }] }] } }

          specify 'returns nil' do
            expect(recursive.undefined_method).to be_nil
          end
        end
      end
    end
  end
end
