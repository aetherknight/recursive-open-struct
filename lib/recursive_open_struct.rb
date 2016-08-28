require 'ostruct'
require 'recursive_open_struct/version'

require 'recursive_open_struct/debug_inspect'
require 'recursive_open_struct/deep_dup'
require 'recursive_open_struct/ruby_19_backport'

class RecursiveOpenStruct < OpenStruct
  include Ruby19Backport if RUBY_VERSION =~ /\A1.9/
  include DebugInspect

  def initialize(hash=nil, args={})
    hash ||= {}
    @recurse_over_arrays = args.fetch(:recurse_over_arrays, false)
    @preserve_original_keys = args.fetch(:preserve_original_keys, false)
    @recursive_ostruct_class = args.fetch(:recursive_ostruct_class, false)
    @deep_dup = DeepDup.new(
      recurse_over_arrays: @recurse_over_arrays,
      preserve_original_keys: @preserve_original_keys,
      recursive_ostruct_class: @recursive_ostruct_class
    )

    @table = args.fetch(:mutate_input_hash, false) ? hash : @deep_dup.call(hash)

    @sub_elements = {}
  end

  def initialize_copy(orig)
    super

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
    public_send(name)
  end

  # Makes sure ROS responds as expected on #respond_to? and #method requests
  def respond_to_missing?(mid, include_private = false)
    mname = _get_key_from_table_(mid.to_s.chomp('=').chomp('_as_a_hash'))
    @table.key?(mname) || super
  end

  # Adapted implementation of method_missing to accomodate the differences between ROS and OS.
  def method_missing(mid, *args)
    len = args.length
    if mid =~ /^(.*)=$/
      if len != 1
        raise ArgumentError, "wrong number of arguments (#{len} for 1)", caller(1)
      end
      modifiable[new_ostruct_member($1.to_sym)] = args[0]
    elsif len == 0
      key = mid
      key = $1 if key =~ /^(.*)_as_a_hash$/
      if @table.key?(_get_key_from_table_(key))
        new_ostruct_member(key)
        send(mid)
      end
    else
      err = NoMethodError.new "undefined method `#{mid}' for #{self}", mid, args
      err.set_backtrace caller(1)
      raise err
    end
  end

  def new_ostruct_member(name)
    key_name = _get_key_from_table_ name
    unless self.methods.include?(name.to_sym)
      class << self; self; end.class_eval do
        define_method(name) do
          v = @table[key_name]
          if v.is_a?(Hash)
            klass = @recursive_ostruct_class ? RecursiveOpenStruct : self.class
            @sub_elements[key_name] ||= klass.new(
              v,
              recurse_over_arrays: @recurse_over_arrays,
              preserve_original_keys: @preserve_original_keys,
              recursive_ostruct_class: @recursive_ostruct_class,
              mutate_input_hash: true
            )
          elsif v.is_a?(Array) and @recurse_over_arrays
            @sub_elements[key_name] ||= recurse_over_array(v)
            @sub_elements[key_name] = recurse_over_array(@sub_elements[key_name])
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

  def delete_field(name)
    sym = _get_key_from_table_(name)
    singleton_class.__send__(:remove_method, sym, "#{sym}=") rescue NoMethodError # ignore if methods not yet generated.
    @sub_elements.delete sym
    @table.delete sym
  end

  private

  def _get_key_from_table_(name)
    return name.to_s if @table.has_key?(name.to_s)
    return name.to_sym if @table.has_key?(name.to_sym)
    name
  end

  def recurse_over_array(array)
    array.map do |a|
      if a.is_a? Hash
        klass = @recursive_ostruct_class ? RecursiveOpenStruct : self.class
        klass.new(a, :recurse_over_arrays => true, :recursive_ostruct_class => @recursive_ostruct_class, :mutate_input_hash => true)
      elsif a.is_a? Array
        recurse_over_array a
      else
        a
      end
    end
  end

end
