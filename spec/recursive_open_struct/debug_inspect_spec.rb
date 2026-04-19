# frozen_string_literal: true

require_relative '../spec_helper'
require 'recursive_open_struct'

describe RecursiveOpenStruct do
  describe '#debug_inspect' do
    subject(:ros) do
      h1 = { a: 'a' }
      h2 = { a: 'b', h1: h1 }
      h1[:h2] = h2

      described_class.new(h2)
    end

    it 'has a simple way of display' do
      io = StringIO.new
      ros.debug_inspect(io)
      expect(io.string).to match(/^a = "b"$/)
      expect(io.string).to match(/^h1\.$/)
      expect(io.string).to match(/^  a = "a"$/)
      expect(io.string).to match(/^  h2\.$/)
      expect(io.string).to match(/^    a = "b"$/)
      expect(io.string).to match(/^    h1\.$/)
      expect(io.string).to match(/^      a = "a"$/)
      expect(io.string).to match(/^      h2\.$/)
      expect(io.string).to match(/^        a = "b"$/)
      expect(io.string).to match(/^        h1\.$/)
      expect(io.string).to match(/^          a = "a"$/)
      expect(io.string).to match(/^          h2\.$/)
      expect(io.string).to match(/^            a = "b"$/)
      expect(io.string).to match(/^            h1\.$/)
      expect(io.string).to match(/^              a = "a"$/)
      expect(io.string).to match(/^              h2\.$/)
      expect(io.string).to match(/^                a = "b"$/)
      expect(io.string).to match(/^                h1\.$/)
      expect(io.string).to match(/^                  a = "a"$/)
      expect(io.string).to match(/^                  h2\.$/)
      expect(io.string).to match(/^                    a = "b"$/)
      expect(io.string).to match(/^                    h1\.$/)
      expect(io.string).to match(/^                      a = "a"$/)
      expect(io.string).to match(/^                      h2\.$/)
      expect(io.string).to match(/^                        \(recursion limit reached\)$/)
    end
  end
end
