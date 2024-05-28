require_relative '../spec_helper'
require 'recursive_open_struct'

describe RecursiveOpenStruct do
  let(:value) { 'foo' }
  let(:symbol) { :bar }
  let(:new_value) { 'bar' }
  let(:new_symbol) { :foo }

  describe 'indifferent access' do
    let(:hash) { {:foo => value, 'bar' => symbol} }
    let(:hash_ros_opts) { {} }
    subject(:hash_ros) { RecursiveOpenStruct.new(hash, hash_ros_opts) }

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

      context 'when preserve_original_keys is not enabled' do
        context 'transforms original keys to symbols' do
          subject(:recursive) { RecursiveOpenStruct.new(recursive_hash, recurse_over_arrays: true) }
          let(:recursive_hash) { {:foo => [ {'bar' => [ { 'foo' => :bar} ] } ] } }
          let(:symbolized_recursive_hash) { {:foo => [ {:bar => [ { :foo => :bar} ] } ] } }
          let(:symbolized_modified_hash) { {:foo => [ {:bar => [ { :foo => :foo} ] } ] } }
          let(:symbolized_hash) { Hash[hash.map{|(k,v)| [k.to_sym,v]}] }

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
      end

      context 'when preserve_original_keys is enabled' do
        context 'preserves the original keys' do
          subject(:recursive) { RecursiveOpenStruct.new(recursive_hash, recurse_over_arrays: true, preserve_original_keys: true) }
          let(:recursive_hash) { {:foo => [ {'bar' => [ { 'foo' => :bar} ] } ] } }
          let(:modified_hash) { {:foo => [ {'bar' => [ { 'foo' => :foo} ] } ] } }

          let(:hash_ros_opts) { { preserve_original_keys: true }}

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
      end

      context 'when undefined method' do
        context 'when raise_on_missing is enabled' do
          subject(:recursive) { RecursiveOpenStruct.new(recursive_hash, raise_on_missing: true) }
          let(:recursive_hash) { {:foo => [ {'bar' => [ { 'foo' => :bar} ] } ] } }

          specify 'raises NoMethodError' do
            expect {
              recursive.undefined_method
            }.to raise_error(NoMethodError)
          end
        end

        context 'when raise_on_missing is disabled' do
          context 'preserves the original keys' do
            subject(:recursive) { RecursiveOpenStruct.new(recursive_hash) }
            let(:recursive_hash) { {:foo => [ {'bar' => [ { 'foo' => :bar} ] } ] } }

            specify 'returns nil' do
              expect(recursive.undefined_method).to be_nil
            end
          end
        end
      end

    end

  end
end
