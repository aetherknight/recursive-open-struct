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

    describe "handling of the arbitrary attributes" do
      describe "#respond?" do
        it "responds to an existing key" do
          ros = RecursiveOpenStruct.new
          ros.blah = "John Smith"
          ros.should respond_to :blah
          ros.should respond_to :blah=
        end
        it "does not respond to a nonexistant key" do
          ros = RecursiveOpenStruct.new
          ros.should_not respond_to :blah
          ros.should_not respond_to :blah=
        end
      end
      describe "#methods" do
      it "includes an existing key" do
          ros = RecursiveOpenStruct.new
          ros.blah = "John Smith"
          ros.methods.should be_include "blah"
          ros.methods.should be_include "blah="
      end
      end
    end
  end

  describe "recursive behavior" do
    it "returns accessed hashes as RecursiveOpenStructs instead of hashes" do
      h = { :blah => { :another => 'value' } }
      ros = RecursiveOpenStruct.new(h)
      ros.blah.another.should == 'value'
    end

    it "uses #key_as_a_hash to return key as a Hash" do
      h = { :blah => { :another => 'value' } }
      ros = RecursiveOpenStruct.new(h)
      ros.blah_as_a_hash.should == { :another => 'value' }
    end

  end
end
