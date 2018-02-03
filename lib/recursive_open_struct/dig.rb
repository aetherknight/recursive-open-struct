class RecursiveOpenStruct < OpenStruct
  module Dig

    # Replaces +OpenStruct#dig+ to properly support treating nested values as
    # RecursiveOpenStructs instead of returning the nested Hashes.
    def dig(name, *names)
      begin
        name = name.to_sym
      rescue NoMethodError
        raise TypeError, "#{name} is not a symbol nor a string"
      end

      name_val = self[name]

      if names.length > 0 && name_val.respond_to?(:dig)
        name_val.dig(*names)
      else
        name_val
      end
    end
  end
end
