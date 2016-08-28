require 'recursive_open_struct'

class SubclassWithInitCheck < RecursiveOpenStruct
    def initialize(*args)
        super
        raise 'hash key :one required' unless self.one
    end
end

