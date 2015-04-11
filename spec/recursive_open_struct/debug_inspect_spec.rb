require_relative '../spec_helper'
require 'recursive_open_struct'

describe RecursiveOpenStruct do
  describe "#debug_inspect" do
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
      expect(@io.string).to match /^a = "b"$/
      expect(@io.string).to match /^h1\.$/
      expect(@io.string).to match /^  a = "a"$/
      expect(@io.string).to match /^  h2\.$/
      expect(@io.string).to match /^    a = "b"$/
      expect(@io.string).to match /^    h1\.$/
      expect(@io.string).to match /^      a = "a"$/
      expect(@io.string).to match /^      h2\.$/
      expect(@io.string).to match /^        a = "b"$/
      expect(@io.string).to match /^        h1\.$/
      expect(@io.string).to match /^          a = "a"$/
      expect(@io.string).to match /^          h2\.$/
      expect(@io.string).to match /^            a = "b"$/
      expect(@io.string).to match /^            h1\.$/
      expect(@io.string).to match /^              a = "a"$/
      expect(@io.string).to match /^              h2\.$/
      expect(@io.string).to match /^                a = "b"$/
      expect(@io.string).to match /^                h1\.$/
      expect(@io.string).to match /^                  a = "a"$/
      expect(@io.string).to match /^                  h2\.$/
      expect(@io.string).to match /^                    a = "b"$/
      expect(@io.string).to match /^                    h1\.$/
      expect(@io.string).to match /^                      a = "a"$/
      expect(@io.string).to match /^                      h2\.$/
      expect(@io.string).to match /^                        \(recursion limit reached\)$/
    end
  end
end
