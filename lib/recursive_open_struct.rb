require 'ostruct'
require 'recursive_open_struct/version'

require 'recursive_open_struct/debug_inspect'
require 'recursive_open_struct/deep_dup'

class RecursiveOpenStruct < OpenStruct
  include DebugInspect

  def initialize(hash={}, args={})
    @recurse_over_arrays = args.fetch(:recurse_over_arrays, false)
    @deep_dup = DeepDup.new(recurse_over_arrays: @recurse_over_arrays)

    @table = args.fetch(:mutate_input_hash, false) ? hash : @deep_dup.call(hash)
    @table && @table.each_key { |k| new_ostruct_member(k) }

    @sub_elements = {}
  end

  def initialize_copy(orig)
    super

    # Apply fix if necessary:
    #   https://github.com/ruby/ruby/commit/2d952c6d16ffe06a28bb1007e2cd1410c3db2d58
    @table.each_key{|key| new_ostruct_member(key)} if RUBY_VERSION =~ /^1.9/

    # deep copy the table to separate the two objects
    @table = @deep_dup.call(orig.instance_variable_get(:@table))
    # Forget any memoized sub-elements
    @sub_elements = {}
  end

  def to_h
    @deep_dup.call(@table)
  end

  alias_method :to_hash, :to_h

  def [](name)
    send name
  end

  def []=(name, value)
    modifiable[new_ostruct_member(name)] = value
  end if RUBY_VERSION =~ /^1.9/

  def new_ostruct_member(name)
    key_name = _get_key_from_table_ name
    unless self.respond_to?(name)
      class << self; self; end.class_eval do
        define_method(name) do
          v = @table[key_name]
          if v.is_a?(Hash)
            @sub_elements[key_name] ||= self.class.new(v,
                                      :recurse_over_arrays => @recurse_over_arrays,
                                      :mutate_input_hash => true)
          elsif v.is_a?(Array) and @recurse_over_arrays
            @sub_elements[key_name] ||= recurse_over_array(v)
          else
            v
          end
        end
        define_method("#{name}=") do |x|
          @sub_elements.delete(key_name)
          modifiable[key_name] = x
        end
        define_method("#{name}_as_a_hash") { @table[key_name] }
      end
    end
    key_name
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

  def delete_field(name)
    sym = _get_key_from_table_(name)
    singleton_class.__send__(:remove_method, sym, "#{sym}=")
    @sub_elements.delete sym
    @table.delete sym
  end

  def eql?(other)
    return false unless other.kind_of?(OpenStruct)
    @table.eql?(other.table)
  end if RUBY_VERSION =~ /^1.9/

  def hash
    @table.hash
  end if RUBY_VERSION =~ /^1.9/

  def each_pair
    return to_enum(:each_pair) { @table.size } unless block_given?
    @table.each_pair{|p| yield p}
  end if RUBY_VERSION =~ /^1.9/

  private

  def _get_key_from_table_(name)
    return name.to_s if @table.has_key?(name.to_s)
    return name.to_sym if @table.has_key?(name.to_sym)
    name
  end

end

