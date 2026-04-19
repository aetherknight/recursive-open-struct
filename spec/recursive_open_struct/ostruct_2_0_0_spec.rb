# frozen_string_literal: true

require_relative '../spec_helper'
require 'recursive_open_struct'

describe RecursiveOpenStruct do
  subject(:ros) { described_class.new(hash) }

  let(:hash) { { :foo => 'foo', 'bar' => :bar } }

  describe 'OpenStruct 2.0+ methods' do
    describe '#[]=' do
      it 'method exists' do
        expect(ros).to respond_to '[]='
      end

      it 'changes the value' do
        ros[:foo] = :foo
        expect(ros.foo).to be :foo
      end
    end

    describe '#delete_field' do
      before { ros.delete_field :foo }

      it 'removes the value' do
        expect(ros.foo).to be_nil
        expect(ros.to_h).not_to include(:foo)
      end

      it 'removes the getter method' do
        expect(ros).not_to respond_to :foo
      end

      it 'removes the setter method' do
        expect(ros).not_to respond_to 'foo='
      end

      it 'works with indifferent access' do
        expect(ros.delete_field(:bar)).to eq :bar
        expect(ros).not_to respond_to :bar
        expect(ros).not_to respond_to 'bar='
        expect(ros.to_h).to be_empty
      end
    end

    describe '#eql?' do
      subject(:new_ros) { ros.dup }

      context 'with identical ROS' do
        subject { ros }

        it { is_expected.to eql ros }
      end

      context 'with similar ROS' do
        subject { described_class.new(hash) }

        it { is_expected.to eql ros }
      end

      context 'with same Hash' do
        subject { described_class.new(hash, recurse_over_arrays: true) }

        it { is_expected.to eql ros }
      end

      context 'with duplicated ROS' do
        subject(:duped_ros) { ros.dup }

        it 'fails on different value' do
          duped_ros.foo = 'bar'
          expect(duped_ros).not_to eql ros
        end

        it 'fails on missing field' do
          duped_ros.delete_field :bar
          expect(duped_ros).not_to eql ros
        end

        it 'fails on added field' do
          duped_ros.baz = :baz
          expect(duped_ros).not_to eql ros
        end
      end
    end

    describe '#hash' do
      it 'calculates table hash' do
        expect(ros.hash).to eq(ros.instance_variable_get('@table').hash)
      end
    end

    describe '#each_pair' do
      it 'iterates over hash keys, with keys as symbol' do
        ros_pairs = []
        ros.each_pair { |k, v| ros_pairs << [k, v] }

        hash_pairs = []
        { foo: 'foo', bar: :bar }.each_pair { |k, v| hash_pairs << [k, v] }

        expect(ros_pairs).to match(hash_pairs)
      end
    end
  end # describe OpenStruct 2.0+ methods
end
