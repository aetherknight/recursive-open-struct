# frozen_string_literal: true

class RecursiveOpenStruct < OpenStruct
  # Replaces +OpenStruct#dig+ to properly support treating nested values as
  # RecursiveOpenStructs instead of returning the nested Hashes.
  #
  # This module is only added in when +OpenStruct#dig+ exists (the OpenStruct
  # included in older Ruby versions didn't implement it)
  module Dig
    def dig(name, *names)
      begin
        name = name.to_sym
      rescue NoMethodError
        raise TypeError, "#{name} is not a symbol nor a string"
      end

      name_val = self[name]

      if !names.empty? && name_val.respond_to?(:dig)
        name_val.dig(*names)
      else
        name_val
      end
    end
  end
end
