require 'ostruct'
require 'recursive_open_struct/version'

require 'recursive_open_struct/debug_inspect'
require 'recursive_open_struct/deep_dup'
require 'recursive_open_struct/ruby_19_backport'
require 'recursive_open_struct/dig'

# TODO: When we care less about Rubies before 2.4.0, match OpenStruct's method
# names instead of doing things like aliasing `new_ostruct_member` to
# `new_ostruct_member!`

class RecursiveOpenStruct < OpenStruct
  include Ruby19Backport if RUBY_VERSION =~ /\A1.9/
  include Dig if OpenStruct.public_instance_methods.include? :dig
  include DebugInspect

  def initialize(hash=nil, args={})
    hash ||= {}
    @recurse_over_arrays = args.fetch(:recurse_over_arrays, false)
    @preserve_original_keys = args.fetch(:preserve_original_keys, false)
    @deep_dup = DeepDup.new(
      recurse_over_arrays: @recurse_over_arrays,
      preserve_original_keys: @preserve_original_keys
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
    key_name = _get_key_from_table_(name)
    v = @table[key_name]
    if v.is_a?(Hash)
      @sub_elements[key_name] ||= self.class.new(
        v,
        recurse_over_arrays: @recurse_over_arrays,
        preserve_original_keys: @preserve_original_keys,
        mutate_input_hash: true
      )
    elsif v.is_a?(Array) and @recurse_over_arrays
      @sub_elements[key_name] ||= recurse_over_array(v)
      @sub_elements[key_name] = recurse_over_array(@sub_elements[key_name])
    else
      v
    end
  end

  # Makes sure ROS responds as expected on #respond_to? and #method requests
  def respond_to_missing?(mid, include_private = false)
    mname = _get_key_from_table_(mid.to_s.chomp('=').chomp('_as_a_hash'))
    @table.key?(mname) || super
  end

  # Adapted implementation of method_missing to accommodate the differences between ROS and OS.
  #
  # TODO: Use modifiable? instead of modifiable, and new_ostruct_member!
  # instead of new_ostruct_member once we care less about Rubies before 2.4.0.
  def method_missing(mid, *args)
    len = args.length
    if mid =~ /^(.*)=$/
      if len != 1
        raise ArgumentError, "wrong number of arguments (#{len} for 1)", caller(1)
      end
      modifiable[new_ostruct_member!($1.to_sym)] = args[0]
    elsif len == 0
      key = mid
      key = $1 if key =~ /^(.*)_as_a_hash$/
      if @table.key?(_get_key_from_table_(key))
        new_ostruct_member!(key)
        send(mid)
      end
    else
      err = NoMethodError.new "undefined method `#{mid}' for #{self}", mid, args
      err.set_backtrace caller(1)
      raise err
    end
  end

  # TODO: Rename to new_ostruct_member! once we care less about Rubies before
  # 2.4.0.
  def new_ostruct_member(name)
    key_name = _get_key_from_table_(name)
    unless self.singleton_class.method_defined?(name.to_sym)
      class << self; self; end.class_eval do
        define_method(name) do
          self[key_name]
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

  # Support Ruby 2.4.0+'s changes in a way that doesn't require dynamically
  # modifying ROS.
  #
  # TODO: Once we care less about Rubies before 2.4.0, reverse this sot hat
  # new_ostruct_member points to our version and not OpenStruct's.
  alias new_ostruct_member! new_ostruct_member
  # new_ostruct_member! is private, but new_ostruct_member is not on OpenStruct in 2.4.0-rc1?!
  private :new_ostruct_member!

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
    array.each_with_index do |a, i|
      if a.is_a? Hash
        array[i] = self.class.new(a, :recurse_over_arrays => true,
          :mutate_input_hash => true, :preserve_original_keys => @preserve_original_keys)
      elsif a.is_a? Array
        array[i] = recurse_over_array a
      end
    end
    array
  end

end
