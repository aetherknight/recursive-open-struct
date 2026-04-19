# frozen_string_literal: true

require_relative '../spec_helper'
require 'recursive_open_struct'

describe RecursiveOpenStruct do
  describe 'subclassing RecursiveOpenStruct' do
    subject(:rossc) { subclass.new({ one: [{ two: :three }] }, recurse_over_arrays: true) }

    let(:subclass) { Class.new(described_class) }

    specify 'nested objects use the subclass of the parent' do
      expect(rossc.one.first.class).to eq subclass
    end
  end
end
