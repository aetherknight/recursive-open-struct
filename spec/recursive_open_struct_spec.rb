require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'recursive_open_struct'

describe RecursiveOpenStruct do

  describe "behavior it inherits from OpenStruct" do

    it "can represent arbitrary data objects" do
      ros = RecursiveOpenStruct.new
      ros.blah = "John Smith"
      ros.blah.should == "John Smith"
    end

    it "can be created from a hash" do
      h = { :asdf => 'John Smith' }
      ros = RecursiveOpenStruct.new(h)
      ros.asdf.should == "John Smith"
    end

    it "can modify an existing key" do
      h = { :blah => 'John Smith' }
      ros = RecursiveOpenStruct.new(h)
      ros.blah = "George Washington"
      ros.blah.should == "George Washington"
    end

    describe "handling of arbitrary attributes" do
      subject { RecursiveOpenStruct.new }
      before(:each) do
        subject.blah = "John Smith"
      end

      describe "#respond?" do
        it { subject.should respond_to :blah }
        it { subject.should respond_to :blah= }
        it { subject.should_not respond_to :asdf }
        it { subject.should_not respond_to :asdf= }
      end # describe #respond?

      describe "#methods" do
        it { subject.methods.map(&:to_sym).should include :blah }
        it { subject.methods.map(&:to_sym).should include :blah= }
        it { subject.methods.map(&:to_sym).should_not include :asdf }
        it { subject.methods.map(&:to_sym).should_not include :asdf= }
      end # describe #methods
    end # describe handling of arbitrary attributes
  end # describe behavior it inherits from OpenStruct

  describe "improvements on OpenStruct" do
    it "can be converted back to a hash" do
      blank_obj = Object.new
      h = {:asdf => 'John Smith', :foo => [{:bar => blank_obj}, {:baz => nil}]}
      ros = RecursiveOpenStruct.new(h)
      ros.to_h.should == h
      ros.to_hash.should == h
    end
  end

  describe "recursive behavior" do
    let(:h) { { :blah => { :another => 'value' } } }
    subject { RecursiveOpenStruct.new(h) }

    it "returns accessed hashes as RecursiveOpenStructs instead of hashes" do
      subject.blah.another.should == 'value'
    end

    it "handles subscript notation the same way as dotted notation" do
      subject.blah.another.should == subject[:blah].another
    end

    it "uses #key_as_a_hash to return key as a Hash" do
      subject.blah_as_a_hash.should == { :another => 'value' }
    end

    describe "handling loops in the origin Hashes" do
      let(:h1) { { :a => 'a'} }
      let(:h2) { { :a => 'b', :h1 => h1 } }
      before(:each) { h1[:h2] = h2 }

      subject { RecursiveOpenStruct.new(h2) }

      it { subject.h1.a.should == 'a' }
      it { subject.h1.h2.a.should == 'b' }
      it { subject.h1.h2.h1.a.should == 'a' }
      it { subject.h1.h2.h1.h2.a.should == 'b' }
      it { subject.h1.should == subject.h1.h2.h1 }
      it { subject.h1.should_not == subject.h1.h2 }
    end # describe handling loops in the origin Hashes

    it "can modify a key of a sub-element" do
      h = {
        :blah => {
          :blargh => 'Brad'
        }
      }
      ros = RecursiveOpenStruct.new(h)
      ros.blah.blargh = "Janet"
      ros.blah.blargh.should == "Janet"
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
          subject.to_h.should == updated_hash
        end

        specify "modifying the returned hash tree does not modify the ROS" do
          subject.to_h[:blah][:blargh] = "Dr Scott"

          subject.blah.blargh.should == "Janet"
        end
      end

      it "does not mutate the original hash tree passed to the constructor" do
        hash[:blah][:blargh].should == 'Brad'
      end

      it "limits the deep-copy to the initial hash tree" do
        subject.some_array[0] = 4

        hash[:some_array][0].should == 4
      end

      describe "#dup" do
        let(:duped_subject) { subject.dup }

        it "preserves sub-element modifications" do
          duped_subject.blah.blargh.should == subject.blah.blargh
        end

        it "allows the copy's sub-elements to be modified independently from the original's" do
          subject.blah.blargh.should == "Janet"
          duped_subject.blah.blargh = "Dr. Scott"

          duped_subject.blah.blargh.should == "Dr. Scott"
          subject.blah.blargh.should == "Janet"
        end
      end
    end

    describe 'recursing over arrays' do
      let(:blah_list) { [ { :foo => '1' }, { :foo => '2' }, 'baz' ] }
      let(:h) { { :blah => blah_list } }

      context "when recursing over arrays is enabled" do
        subject { RecursiveOpenStruct.new(h, :recurse_over_arrays => true) }

        it { subject.blah.length.should == 3 }
        it { subject.blah[0].foo.should == '1' }
        it { subject.blah[1].foo.should == '2' }
        it { subject.blah_as_a_hash.should == blah_list }
        it { subject.blah[2].should == 'baz' }

        context "when an inner value changes" do
          let(:updated_blah_list) { [ { :foo => '1' }, { :foo => 'Dr Scott' }, 'baz' ] }
          let(:updated_h) { { :blah => updated_blah_list } }

          before(:each) { subject.blah[1].foo = "Dr Scott" }

          it "Retains changes across Array lookups" do
            subject.blah[1].foo.should == "Dr Scott"
          end

          it "propagates the changes through to .to_h across Array lookups" do
            subject.to_h.should == {
              :blah => [ { :foo => '1' }, { :foo => "Dr Scott" }, 'baz' ]
            }
          end

          it "deep-copies hashes within Arrays" do
            subject.to_h[:blah][1][:foo] = "Rocky"

            subject.blah[1].foo.should == "Dr Scott"
          end

          it "does not mutate the input hash passed to the constructor" do
            h[:blah][1][:foo].should == '2'
          end

          it "the deep copy recurses over Arrays as well" do
            h[:blah][1][:foo].should == '2'
          end

          describe "#dup" do
            let(:duped_subject) { subject.dup }

            it "preserves sub-element modifications" do
              duped_subject.blah[1].foo.should == subject.blah[1].foo
            end

            it "allows the copy's sub-elements to be modified independently from the original's" do
              duped_subject.blah[1].foo = "Rocky"

              duped_subject.blah[1].foo.should == "Rocky"
              subject.blah[1].foo.should == "Dr Scott"
            end
          end
        end

        context "when array is nested deeper" do
          let(:deep_hash) { { :foo => { :blah => blah_list } } }
          subject { RecursiveOpenStruct.new(deep_hash, :recurse_over_arrays => true) }

          it { subject.foo.blah.length.should == 3 }
          it "Retains changes across Array lookups" do
            subject.foo.blah[1].foo = "Dr Scott"
            subject.foo.blah[1].foo.should == "Dr Scott"
          end

        end

        context "when array is in an array" do
          let(:haah) { { :blah => [ blah_list ] } }
          subject { RecursiveOpenStruct.new(haah, :recurse_over_arrays => true) }

          it { subject.blah.length.should == 1 }
          it { subject.blah[0].length.should == 3 }
          it "Retains changes across Array lookups" do
            subject.blah[0][1].foo = "Dr Scott"
            subject.blah[0][1].foo.should == "Dr Scott"
          end

        end

      end # when recursing over arrays is enabled

      context "when recursing over arrays is disabled" do
        subject { RecursiveOpenStruct.new(h) }

        it { subject.blah.length.should == 3 }
        it { subject.blah[0].should == { :foo => '1' } }
        it { subject.blah[0][:foo].should == '1' }
      end # when recursing over arrays is disabled

    end # recursing over arrays
  end # recursive behavior

  describe "additionnel features" do

    before(:each) do
      h1 = { :a => 'a'}
      h2 = { :a => 'b', :h1 => h1 }
      h1[:h2] = h2
      @ros = RecursiveOpenStruct.new(h2)
    end

    it "should have a simple way of display" do
      @output = <<-QUOTE
a = "b"
h1.
  a = "a"
  h2.
    a = "b"
    h1.
      a = "a"
      h2.
        a = "b"
        h1.
          a = "a"
          h2.
            a = "b"
            h1.
              a = "a"
              h2.
                a = "b"
                h1.
                  a = "a"
                  h2.
                    a = "b"
                    h1.
                      a = "a"
                      h2.
                        (recursion limit reached)
QUOTE
      @io = StringIO.new
      @ros.debug_inspect(@io)
      @io.string.should match /^a = "b"$/
      @io.string.should match /^h1\.$/
      @io.string.should match /^  a = "a"$/
      @io.string.should match /^  h2\.$/
      @io.string.should match /^    a = "b"$/
      @io.string.should match /^    h1\.$/
      @io.string.should match /^      a = "a"$/
      @io.string.should match /^      h2\.$/
      @io.string.should match /^        a = "b"$/
      @io.string.should match /^        h1\.$/
      @io.string.should match /^          a = "a"$/
      @io.string.should match /^          h2\.$/
      @io.string.should match /^            a = "b"$/
      @io.string.should match /^            h1\.$/
      @io.string.should match /^              a = "a"$/
      @io.string.should match /^              h2\.$/
      @io.string.should match /^                a = "b"$/
      @io.string.should match /^                h1\.$/
      @io.string.should match /^                  a = "a"$/
      @io.string.should match /^                  h2\.$/
      @io.string.should match /^                    a = "b"$/
      @io.string.should match /^                    h1\.$/
      @io.string.should match /^                      a = "a"$/
      @io.string.should match /^                      h2\.$/
      @io.string.should match /^                        \(recursion limit reached\)$/
    end

    it "creates nested objects via subclass" do
      RecursiveOpenStructSubClass = Class.new(RecursiveOpenStruct)

      rossc = RecursiveOpenStructSubClass.new({ :one => [{:two => :three}] }, recurse_over_arrays: true)

      rossc.one.first.class.should == RecursiveOpenStructSubClass
    end
  end # additionnel features

end # describe RecursiveOpenStruct
