require 'ostruct'

class RecursiveOpenStruct < OpenStruct
  def new_ostruct_member(name)
    name = name.to_sym
    unless self.respond_to?(name)
      class << self; self; end.class_eval do
        define_method(name) {
          v = @table[name]
          v.is_a?(Hash) ? RecursiveOpenStruct.new(v) : v
        }
        define_method("#{name}=") { |x| modifiable[name] = x }
        define_method("#{name}_as_a_hash") { @table[name] }
      end
    end
    name
  end
end
