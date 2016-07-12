require_relative '../spec_helper'
require 'recursive_open_struct'
require 'yaml'

describe RecursiveOpenStruct do

  describe "load from ymal" do

    it "can be dump and load" do
      h = {:asdf => 'John Smith', :foo => [{:bar => {}}, {:baz => nil}]}
      ros = RecursiveOpenStruct.new(h)

      yml = YAML.dump(ros)
      other = YAML.load(yml)

      expect(ros.to_h).to eq other.to_h

    end
  end

end
