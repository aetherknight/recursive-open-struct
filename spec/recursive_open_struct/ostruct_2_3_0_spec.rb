# frozen_string_literal: true

require_relative '../spec_helper'
require 'recursive_open_struct'

# rubocop:disable Style/SingleArgumentDig
describe RecursiveOpenStruct do
  describe 'OpenStruct 2.3.0+ methods' do
    describe '#dig' do
      # We only care when Ruby supports `#dig`.
      if OpenStruct.public_instance_methods.include? :dig
        context 'when recurse_over_arrays: false' do
          subject(:ros) { described_class.new(a: { b: 2, c: ['doo', 'bee', { inner: 'one' }] }) }

          describe 'OpenStruct-like behavior' do
            it { expect(ros.dig(:a, :b)).to eq 2 }
            it { expect(ros.dig(:a, :c, 0)).to eq 'doo' }
            it { expect(ros.dig(:a, :c, 2, :inner)).to eq 'one' }
          end

          describe 'recursive behavior' do
            it {
              expect(ros.dig(:a)).to eq described_class.new(
                { b: 2, c: ['doo', 'bee', { inner: 'one' }] }
              )
            }

            it { expect(ros.dig(:a, :c, 2)).to eq({ inner: 'one' }) }
          end
        end

        context 'when recurse_over_arrays: true' do
          subject(:ros) do
            described_class.new({ a: { b: 2, c: ['doo', 'bee', { inner: 'one' }] } }, recurse_over_arrays: true)
          end

          describe 'OpenStruct-like behavior' do
            it { expect(ros.dig(:a, :b)).to eq 2 }
            it { expect(ros.dig(:a, :c, 0)).to eq 'doo' }
            it { expect(ros.dig(:a, :c, 2, :inner)).to eq 'one' }
          end

          describe 'recursive behavior' do
            it {
              expect(ros.dig(:a)).to eq described_class.new(
                { b: 2, c: ['doo', 'bee', { inner: 'one' }] }
              )
            }

            it { expect(ros.dig(:a, :c, 2)).to eq described_class.new(inner: 'one') }
          end
        end
      end
    end # describe #dig
  end # describe OpenStruct 2.3+ methods
end
# rubocop:enable Style/SingleArgumentDig
