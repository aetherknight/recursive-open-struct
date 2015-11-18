require_relative '../spec_helper'
require 'recursive_open_struct'

describe RecursiveOpenStruct do

  let(:hash) { {:foo => 'foo', 'bar' => :bar} }
  subject(:ros) { RecursiveOpenStruct.new(hash) }

  describe "OpenStruct 2.0 methods" do

    context "Hash style setter" do

      it "method exists" do
        expect(ros.respond_to?('[]=')).to be_truthy
      end

      it "changes the value" do
        ros[:foo] = :foo
        ros.foo = :foo
      end

    end

    context "delete_field" do

      before(:each) { ros.delete_field :foo }

      it "removes the value" do
        expect(ros.foo).to be_nil
        expect(ros.to_h).to_not include(:foo)
      end

      it "removes the getter method" do
        is_expected.to_not respond_to :foo
      end

      it "removes the setter method" do
        expect(ros.respond_to? 'foo=').to be_falsey
      end

      it "works with indifferent access" do
        expect(ros.delete_field :bar).to eq :bar
        is_expected.to_not respond_to :bar
        is_expected.to_not respond_to 'bar='
        expect(ros.to_h).to be_empty
      end

    end

    context "eql?" do
      subject(:new_ros) { ros.dup }

      context "with identical ROS" do
        subject { ros }
        it { is_expected.to be_eql ros }
      end

      context "with similar ROS" do
        subject { RecursiveOpenStruct.new(hash) }
        it { is_expected.to be_eql ros }
      end

      context "with same Hash" do
        subject { RecursiveOpenStruct.new(hash, recurse_over_arrays: true) }
        it { is_expected.to be_eql ros }
      end

      context "with duplicated ROS" do
        subject { ros.dup }

        it "fails on different value" do
          subject.foo = 'bar'
          is_expected.not_to be_eql ros
        end

        it "fails on missing field" do
          subject.delete_field :bar
          is_expected.not_to be_eql ros
        end

        it "fails on added field" do
          subject.baz = :baz
          is_expected.not_to be_eql ros
        end

      end

    end

    context "hash" do
      it "calculates table hash" do
        expect(ros.hash).to be ros.instance_variable_get('@table').hash
      end

    end

    context "each_pair" do
      it "iterates over hash keys" do
        expect(ros.each_pair).to match hash.each_pair
      end
    end

    context "marshal support" do
      let(:args) { {recurse_over_arrays: true, mutate_input_hash: false} }
      subject(:ros) { RecursiveOpenStruct.new(hash, args) }
      subject(:loaded_ros) do
        loaded = RecursiveOpenStruct.new
        loaded.marshal_load(ros.marshal_dump)
        loaded
      end

      it "dumps the data and arguments" do
        marshal_data, marshal_args = ros.marshal_dump
        expect(marshal_data).to eq hash
        expect(marshal_args).to eq args
      end

      it "loads the data and arguments" do
        expect(loaded_ros.each_pair).to match hash.each_pair
      end

      context "with nested data" do
        let(:hash) do
          {
            foo: 'foo',
            bar: { nested_foo: 'nested_foo' },
            list: [{ foo: :bar }, { bar: :foo }]
          }
        end
        it "can be accessed as a struct" do
          expect(loaded_ros.bar.nested_foo).to eq hash[:bar][:nested_foo]
          expect(loaded_ros.list[0].foo).to eq hash[:list][0][:foo]
        end
        it "can be yamlized and restored" do
          dump = Marshal.dump(ros)
          recreated = Marshal.load(dump)
          expect(recreated.bar.nested_foo).to eq hash[:bar][:nested_foo]
          expect(recreated.list[0].foo).to eq hash[:list][0][:foo]
        end
      end
    end

  end

end
