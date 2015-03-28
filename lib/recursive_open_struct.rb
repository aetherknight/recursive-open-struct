require 'ostruct'
require 'recursive_open_struct/version'

require 'recursive_open_struct/debug_inspect'
require 'recursive_open_struct/deep_dup'

class RecursiveOpenStruct < OpenStruct
  include DebugInspect

  def initialize(hash=nil, args={})
    @recurse_over_arrays = args.fetch(:recurse_over_arrays, false)
    mutate_input_hash = args.fetch(:mutate_input_hash, false)

    unless mutate_input_hash
      hash = DeepDup.new(recurse_over_arrays: @recurse_over_arrays).call(hash)
    end

    super(hash)

    if mutate_input_hash && hash
      hash.clear
      @table.each { |k,v| hash[k] = v }
      @table = hash
    end

    @sub_elements = {}
  end

  def initialize_copy(orig)
    super
    # deep copy the table to separate the two objects
    @table = DeepDup.new(recurse_over_arrays: @recurse_over_arrays).call(orig.instance_variable_get(:@table))
    # Forget any memoized sub-elements
    @sub_elements = {}
  end

  def to_h
    DeepDup.new(recurse_over_arrays: @recurse_over_arrays).call(@table)
  end

  alias_method :to_hash, :to_h

  def [](name)
    send name
  end

  def new_ostruct_member(name)
    name = name.to_sym
    unless self.respond_to?(name)
      class << self; self; end.class_eval do
        define_method(name) do
          v = @table[name]
          if v.is_a?(Hash)
            @sub_elements[name] ||= self.class.new(v,
                                      :recurse_over_arrays => @recurse_over_arrays,
                                      :mutate_input_hash => true)
          elsif v.is_a?(Array) and @recurse_over_arrays
            @sub_elements[name] ||= recurse_over_array(v)
          else
            v
          end
        end
        define_method("#{name}=") { |x| modifiable[name] = x }
        define_method("#{name}_as_a_hash") { @table[name] }
      end
    end
    name
  end

  # TODO: Make me private if/when we do an API-breaking change release
  def recurse_over_array(array)
    array.map do |a|
      if a.is_a? Hash
        self.class.new(a, :recurse_over_arrays => true, :mutate_input_hash => true)
      elsif a.is_a? Array
        recurse_over_array a
      else
        a
      end
    end
  end
end

