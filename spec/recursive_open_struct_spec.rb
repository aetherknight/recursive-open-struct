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
      before(:each) do
        @ros = RecursiveOpenStruct.new
        @ros.blah = "John Smith"
      end

      describe "#respond?" do
        it { @ros.should respond_to :blah }
        it { @ros.should respond_to :blah= }
        it { @ros.should_not respond_to :asdf }
        it { @ros.should_not respond_to :asdf= }
      end # describe #respond?

      describe "#methods" do
        it { @ros.methods.map(&:to_sym).should include :blah }
        it { @ros.methods.map(&:to_sym).should include :blah= }
        it { @ros.methods.map(&:to_sym).should_not include :asdf }
        it { @ros.methods.map(&:to_sym).should_not include :asdf= }
      end # describe #methods
    end # describe handling of arbitrary attributes
  end # describe behavior it inherits from OpenStruct

  describe "recursive behavior" do
    before(:each) do
      h = { :blah => { :another => 'value' } }
      @ros = RecursiveOpenStruct.new(h)
    end

    it "returns accessed hashes as RecursiveOpenStructs instead of hashes" do
      @ros.blah.another.should == 'value'
    end

    it "uses #key_as_a_hash to return key as a Hash" do
      @ros.blah_as_a_hash.should == { :another => 'value' }
    end

    describe "handling loops in the origin Hashes" do
      before(:each) do
        h1 = { :a => 'a'}
        h2 = { :a => 'b', :h1 => h1 }
        h1[:h2] = h2
        @ros = RecursiveOpenStruct.new(h2)
      end

      it { @ros.h1.a.should == 'a' }
      it { @ros.h1.h2.a.should == 'b' }
      it { @ros.h1.h2.h1.a.should == 'a' }
      it { @ros.h1.h2.h1.h2.a.should == 'b' }
      it { @ros.h1.should == @ros.h1.h2.h1 }
      it { @ros.h1.should_not == @ros.h1.h2 }
    end # describe handling loops in the origin Hashes

    describe 'recursing over arrays' do
      let(:blah_list) { [ { :foo => '1' }, { :foo => '2' }, 'baz' ] }
      let(:h) { { :blah => blah_list } }

      context "when recursing over arrays is enabled" do
        before(:each) do
          @ros = RecursiveOpenStruct.new(h, :recurse_over_arrays => true)
        end

        it { @ros.blah.length.should == 3 }
        it { @ros.blah[0].foo.should == '1' }
        it { @ros.blah[1].foo.should == '2' }
        it { @ros.blah_as_a_hash.should == blah_list }
        it { @ros.blah[2].should == 'baz' }
      end # when recursing over arrays is enabled

      context "when recursing over arrays is disabled" do
        before(:each) do
          @ros = RecursiveOpenStruct.new(h)
        end

        it { @ros.blah.length.should == 3 }
        it { @ros.blah[0].should == { :foo => '1' } }
        it { @ros.blah[0][:foo].should == '1' }
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
  end # additionnel features

end # describe RecursiveOpenStruct
