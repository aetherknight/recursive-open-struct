require_relative '../spec_helper'
require 'recursive_open_struct'

describe RecursiveOpenStruct do

  describe "recursive behavior" do
    let(:h) { { :blah => { :another => 'value' } } }
    subject { RecursiveOpenStruct.new(h) }

    it "can convert the entire hash tree back into a hash" do
      blank_obj = Object.new
      h = {:asdf => 'John Smith', :foo => [{:bar => blank_obj}, {:baz => nil}]}
      ros = RecursiveOpenStruct.new(h)

      expect(ros.to_h).to eq h
      expect(ros.to_hash).to eq h
    end

    it "returns accessed hashes as RecursiveOpenStructs instead of hashes" do
      expect(subject.blah.another).to eq 'value'
    end

    it "handles subscript notation the same way as dotted notation" do
      expect(subject.blah.another).to eq subject[:blah].another
    end

    it "uses #key_as_a_hash to return key as a Hash" do
      expect(subject.blah_as_a_hash).to eq({ :another => 'value' })
    end

    describe "handling loops in the original Hashes" do
      let(:h1) { { :a => 'a'} }
      let(:h2) { { :a => 'b', :h1 => h1 } }
      before(:each) { h1[:h2] = h2 }

      subject { RecursiveOpenStruct.new(h2) }

      it { expect(subject.h1.a).to eq 'a' }
      it { expect(subject.h1.h2.a).to eq 'b' }
      it { expect(subject.h1.h2.h1.a).to eq 'a' }
      it { expect(subject.h1.h2.h1.h2.a).to eq 'b' }
      it { expect(subject.h1).to eq subject.h1.h2.h1 }
      it { expect(subject.h1).to_not eq subject.h1.h2 }
    end # describe handling loops in the origin Hashes

    it "can modify a key of a sub-element" do
      h = {
        :blah => {
          :blargh => 'Brad'
        }
      }
      ros = RecursiveOpenStruct.new(h)
      ros.blah.blargh = "Janet"

      expect(ros.blah.blargh).to eq "Janet"
    end

    context "after a sub-element has been modified" do
      let(:hash) do
        { :blah => { :blargh => "Brad" }, :some_array => [ 1, 2, 3] }
      end
      let(:updated_hash) do
        { :blah => { :blargh => "Janet" }, :some_array => [ 1, 2, 3] }
      end

      subject { RecursiveOpenStruct.new(hash) }

      before(:each) { subject.blah.blargh = "Janet" }

      describe ".to_h" do
        it "returns a hash tree that contains those modifications" do
          expect(subject.to_h).to eq updated_hash
        end

        specify "modifying the returned hash tree does not modify the ROS" do
          subject.to_h[:blah][:blargh] = "Dr Scott"

          expect(subject.blah.blargh).to eq "Janet"
        end
      end

      it "does not mutate the original hash tree passed to the constructor" do
        expect(hash[:blah][:blargh]).to eq 'Brad'
      end

      it "limits the deep-copy to the initial hash tree" do
        subject.some_array[0] = 4

        expect(hash[:some_array][0]).to eq 4
      end

      describe "#dup" do
        let(:duped_subject) { subject.dup }

        it "preserves sub-element modifications" do
          expect(duped_subject.blah.blargh).to eq subject.blah.blargh
        end

        it "allows the copy's sub-elements to be modified independently from the original's" do
          expect(subject.blah.blargh).to eq "Janet"

          duped_subject.blah.blargh = "Dr. Scott"

          expect(subject.blah.blargh).to eq "Janet"
          expect(duped_subject.blah.blargh).to eq "Dr. Scott"
        end
      end
    end

    context "when memoizing and then modifying entire recursive structures" do
      subject do
        RecursiveOpenStruct.new(
          { :blah => original_blah }, :recurse_over_arrays => true)
      end

      before(:each) { subject.blah } # enforce memoization

      context "when modifying an entire Hash" do
        let(:original_blah) { { :a => 'A', :b => 'B' } }
        let(:new_blah) { { :something_new => "C" } }

        before(:each) { subject.blah = new_blah }

        it "returns the modified value instead of the memoized one" do
          expect(subject.blah.something_new).to eq "C"
        end

        specify "the old value no longer exists" do
          expect(subject.blah.a).to be_nil
        end
      end

      context "when modifying an entire Array" do
        let(:original_blah) { [1, 2, 3] }

        it "returns the modified value instead of the memoized one" do
          new_blah = [4, 5, 6]
          subject.blah = new_blah
          expect(subject.blah).to eq new_blah
        end
      end
    end

    describe 'recursing over arrays' do
      let(:blah_list) { [ { :foo => '1' }, { :foo => '2' }, 'baz' ] }
      let(:h) { { :blah => blah_list } }

      context "when recursing over arrays is enabled" do
        subject { RecursiveOpenStruct.new(h, :recurse_over_arrays => true) }

        it { expect(subject.blah.length).to eq 3 }
        it { expect(subject.blah[0].foo).to eq '1' }
        it { expect(subject.blah[1].foo).to eq '2' }
        it { expect(subject.blah_as_a_hash).to eq blah_list }
        it { expect(subject.blah[2]).to eq 'baz' }

        context "when an inner value changes" do
          let(:updated_blah_list) { [ { :foo => '1' }, { :foo => 'Dr Scott' }, 'baz' ] }
          let(:updated_h) { { :blah => updated_blah_list } }

          before(:each) { subject.blah[1].foo = "Dr Scott" }

          it "Retains changes across Array lookups" do
            expect(subject.blah[1].foo).to eq "Dr Scott"
          end

          it "propagates the changes through to .to_h across Array lookups" do
            expect(subject.to_h).to eq({
              :blah => [ { :foo => '1' }, { :foo => "Dr Scott" }, 'baz' ]
            })
          end

          it "deep-copies hashes within Arrays" do
            subject.to_h[:blah][1][:foo] = "Rocky"

            expect(subject.blah[1].foo).to eq "Dr Scott"
          end

          it "does not mutate the input hash passed to the constructor" do
            expect(h[:blah][1][:foo]).to eq '2'
          end

          it "the deep copy recurses over Arrays as well" do
            expect(h[:blah][1][:foo]).to eq '2'
          end

          describe "#dup" do
            let(:duped_subject) { subject.dup }

            it "preserves sub-element modifications" do
              expect(duped_subject.blah[1].foo).to eq subject.blah[1].foo
            end

            it "allows the copy's sub-elements to be modified independently from the original's" do
              duped_subject.blah[1].foo = "Rocky"

              expect(duped_subject.blah[1].foo).to eq "Rocky"
              expect(subject.blah[1].foo).to eq "Dr Scott"
            end
          end
        end

        context "when array is nested deeper" do
          let(:deep_hash) { { :foo => { :blah => blah_list } } }
          subject { RecursiveOpenStruct.new(deep_hash, :recurse_over_arrays => true) }

          it { expect(subject.foo.blah.length).to eq 3 }
          it "Retains changes across Array lookups" do
            subject.foo.blah[1].foo = "Dr Scott"
            expect(subject.foo.blah[1].foo).to eq "Dr Scott"
          end

        end

        context "when array is in an array" do
          let(:haah) { { :blah => [ blah_list ] } }
          subject { RecursiveOpenStruct.new(haah, :recurse_over_arrays => true) }

          it { expect(subject.blah.length).to eq 1 }
          it { expect(subject.blah[0].length).to eq 3 }
          it "Retains changes across Array lookups" do
            subject.blah[0][1].foo = "Dr Scott"

            expect(subject.blah[0][1].foo).to eq "Dr Scott"
          end

        end

      end # when recursing over arrays is enabled

      context "when recursing over arrays is disabled" do
        subject { RecursiveOpenStruct.new(h) }

        it { expect(subject.blah.length).to eq 3 }
        it { expect(subject.blah[0]).to eq({ :foo => '1' }) }
        it { expect(subject.blah[0][:foo]).to eq '1' }
      end # when recursing over arrays is disabled

    end # recursing over arrays
  end # recursive behavior
end
