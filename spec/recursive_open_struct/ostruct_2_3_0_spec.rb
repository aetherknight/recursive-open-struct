require_relative '../spec_helper'
require 'recursive_open_struct'

describe RecursiveOpenStruct do
  describe "OpenStruct 2.3.0+ methods" do
    describe "#dig" do
      # We only care when Ruby supports `#dig`.
      if OpenStruct.public_instance_methods.include? :dig
        context "recurse_over_arrays: false" do
          subject { RecursiveOpenStruct.new(a: { b: 2, c: ["doo", "bee", { inner: "one"}]}) }

          describe "OpenStruct-like behavior" do
            it { expect(subject.dig(:a, :b)).to eq 2 }
            it { expect(subject.dig(:a, :c, 0)).to eq "doo" }
            it { expect(subject.dig(:a, :c, 2, :inner)).to eq "one" }
          end

          describe "recursive behavior" do
            it {
              expect(subject.dig(:a)).to eq RecursiveOpenStruct.new(
                { b: 2, c: ["doo", "bee", { inner: "one"}]}
              )
            }
            it { expect(subject.dig(:a, :c, 2)).to eq({inner: "one"}) }
          end
        end

        context "recurse_over_arrays: true" do
          subject { RecursiveOpenStruct.new({a: { b: 2, c: ["doo", "bee", { inner: "one"}]}}, recurse_over_arrays: true) }

          describe "OpenStruct-like behavior" do
            it { expect(subject.dig(:a, :b)).to eq 2 }
            it { expect(subject.dig(:a, :c, 0)).to eq "doo" }
            it { expect(subject.dig(:a, :c, 2, :inner)).to eq "one" }
          end

          describe "recursive behavior" do
            it {
              expect(subject.dig(:a)).to eq RecursiveOpenStruct.new(
                { b: 2, c: ["doo", "bee", { inner: "one"}]}
              )
            }
            it { expect(subject.dig(:a, :c, 2)).to eq RecursiveOpenStruct.new(inner: "one") }
          end
        end
      end
    end # describe #dig
  end # describe OpenStruct 2.3+ methods
end
