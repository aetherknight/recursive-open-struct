require 'ostruct'
require 'recursive_open_struct/version'

require 'recursive_open_struct/debug_inspect'
require 'recursive_open_struct/deep_dup'
require 'recursive_open_struct/dig'

# TODO: When we care less about Rubies before 2.4.0, match OpenStruct's method
# names instead of doing things like aliasing `new_ostruct_member` to
# `new_ostruct_member!`
#
# TODO: `#*_as_a_hash` deprecated. Nested hashes can be referenced using
# `#to_h`.

class RecursiveOpenStruct < OpenStruct
  include Dig if OpenStruct.public_instance_methods.include? :dig

  # TODO: deprecated, possibly remove or make optional an runtime so that it
  # doesn't normally pollute the public method namespace
  include DebugInspect

  def self.default_options
    {
      mutate_input_hash: false,
      recurse_over_arrays: false,
      preserve_original_keys: false,
      raise_on_missing: false
    }
  end

  def initialize(hash=nil, passed_options={})
    hash ||= {}

    @options = self.class.default_options.merge!(passed_options).freeze

    @deep_dup = DeepDup.new(@options)

    @table = @options[:mutate_input_hash] ? hash : @deep_dup.call(hash)

    @sub_elements = {}
  end


  if OpenStruct.public_instance_methods.include?(:initialize_copy)
    def initialize_copy(orig)
      super

      # deep copy the table to separate the two objects
      @table = @deep_dup.call(@table)
      # Forget any memoized sub-elements
      @sub_elements = {}
    end
  end

  def to_h
    @deep_dup.call(@table)
  end

  # TODO: deprecated, unsupported by OpenStruct. OpenStruct does not consider
  # itself to be a "kind of" Hash.
  alias_method :to_hash, :to_h

  # Continue supporting older rubies -- JRuby 9.1.x.x is still considered
  # stable, but is based on Ruby
  # 2.3.x and so uses :modifiable instead of :modifiable?. Furthermore, if
  # :modifiable is private, then make :modifiable? private too.
  if !OpenStruct.private_instance_methods.include?(:modifiable?)
    if OpenStruct.private_instance_methods.include?(:modifiable)
      alias_method :modifiable?, :modifiable
    elsif OpenStruct.public_instance_methods.include?(:modifiable)
      alias_method :modifiable?, :modifiable
      private :modifiable?
    end
  end

  def [](name)
    key_name = _get_key_from_table_(name)
    v = @table[key_name]
    if v.is_a?(Hash)
      @sub_elements[key_name] ||= _create_sub_element_(v, mutate_input_hash: true)
    elsif v.is_a?(Array) and @options[:recurse_over_arrays]
      @sub_elements[key_name] ||= recurse_over_array(v)
      @sub_elements[key_name] = recurse_over_array(@sub_elements[key_name])
    else
      v
    end
  end

  if private_instance_methods.include?(:modifiable?) || public_instance_methods.include?(:modifiable?)
    def []=(name, value)
      key_name = _get_key_from_table_(name)
      tbl = modifiable?  # Ensure we are modifiable
      @sub_elements.delete(key_name)
      tbl[key_name] = value
    end
  else
    def []=(name, value)
      key_name = _get_key_from_table_(name)
      @table[key_name] = value # raises if self is frozen in Ruby 3.0
      @sub_elements.delete(key_name)
    end
  end

  # Makes sure ROS responds as expected on #respond_to? and #method requests
  def respond_to_missing?(mid, include_private = false)
    mname = _get_key_from_table_(mid.to_s.chomp('=').chomp('_as_a_hash'))
    @table.key?(mname) || super
  end

  # Adapted implementation of method_missing to accommodate the differences
  # between ROS and OS.
  def method_missing(mid, *args)
    len = args.length
    if mid =~ /^(.*)=$/
      if len != 1
        raise ArgumentError, "wrong number of arguments (#{len} for 1)", caller(1)
      end
      # self[$1.to_sym] = args[0]
      # modifiable?[new_ostruct_member!($1.to_sym)] = args[0]
      new_ostruct_member!($1.to_sym)
      public_send(mid, args[0])
    elsif len == 0
      key = mid
      key = $1 if key =~ /^(.*)_as_a_hash$/
      if @table.key?(_get_key_from_table_(key))
        new_ostruct_member!(key)
        public_send(mid)
      elsif @options[:raise_on_missing]
        err = NoMethodError.new "undefined method `#{mid}' for #{self}", mid, args
        err.set_backtrace caller(1)
        raise err
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
          self[key_name] = x
        end
        define_method("#{name}_as_a_hash") { @table[key_name] }
      end
    end
    key_name
  end

  # Support Ruby 2.4.0+'s changes in a way that doesn't require dynamically
  # modifying ROS.
  #
  # TODO: Once we care less about Rubies before 2.4.0, reverse this so that
  # new_ostruct_member points to our version and not OpenStruct's.
  alias new_ostruct_member! new_ostruct_member
  # new_ostruct_member! is private, but new_ostruct_member is not on OpenStruct in 2.4.0-rc1?!
  private :new_ostruct_member!

  def delete_field(name)
    sym = _get_key_from_table_(name)
    singleton_class.__send__(:remove_method, sym, "#{sym}=") rescue NoMethodError # ignore if methods not yet generated.
    @sub_elements.delete(sym)
    @table.delete(sym)
  end

  private

  unless OpenStruct.public_instance_methods.include?(:initialize_copy)
    def initialize_dup(orig)
      super
      # deep copy the table to separate the two objects
      @table = @deep_dup.call(@table)
      # Forget any memoized sub-elements
      @sub_elements = {}
    end
  end

  def _get_key_from_table_(name)
    return name.to_s if @table.has_key?(name.to_s)
    return name.to_sym if @table.has_key?(name.to_sym)
    name
  end

  def _create_sub_element_(hash, **overrides)
    self.class.new(hash, @options.merge(overrides))
  end

  def recurse_over_array(array)
    array.each_with_index do |a, i|
      if a.is_a? Hash
        array[i] = _create_sub_element_(a, mutate_input_hash: true, recurse_over_arrays: true)
      elsif a.is_a? Array
        array[i] = recurse_over_array a
      end
    end
    array
  end

end
