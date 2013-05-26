require 'ostruct'

class RecursiveOpenStruct < OpenStruct
  VERSION = "0.4.0"

  def initialize(h=nil, args={})
    @recurse_over_arrays = args.fetch(:recurse_over_arrays,false)
    super(h)
  end

  def to_h
    @table.dup
  end

  def new_ostruct_member(name)
    name = name.to_sym
    unless self.respond_to?(name)
      class << self; self; end.class_eval do
        define_method(name) do
          v = @table[name]
          if v.is_a?(Hash)
            RecursiveOpenStruct.new(v)
          elsif v.is_a?(Array) and @recurse_over_arrays
            v.map { |a| (a.is_a? Hash) ? RecursiveOpenStruct.new(a, :recurse_over_arrays => true) : a }
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

  def debug_inspect(io = STDOUT, indent_level = 0, recursion_limit = 12)
    display_recursive_open_struct(io, @table, indent_level, recursion_limit)
  end

  def display_recursive_open_struct(io, ostrct_or_hash, indent_level, recursion_limit)

    if recursion_limit <= 0 then
      # protection against recursive structure (like in the tests)
      io.puts '  '*indent_level + '(recursion limit reached)'
    else
      #puts ostrct_or_hash.inspect
      if ostrct_or_hash.is_a?(RecursiveOpenStruct) then
        ostrct_or_hash = ostrct_or_hash.marshal_dump
      end

      # We'll display the key values like this :    key =  value
      # to align display, we look for the maximum key length of the data that will be displayed
      # (everything except hashes)
      data_indent = ostrct_or_hash \
        .reject { |k, v| v.is_a?(RecursiveOpenStruct) || v.is_a?(Hash) } \
          .max {|a,b| a[0].to_s.length <=> b[0].to_s.length}[0].to_s.length
      # puts "max length = #{data_indent}"

      ostrct_or_hash.each do |key, value|
        if (value.is_a?(RecursiveOpenStruct) || value.is_a?(Hash)) then
          io.puts '  '*indent_level + key.to_s + '.'
          display_recursive_open_struct(io, value, indent_level + 1, recursion_limit - 1)
        else
          io.puts '  '*indent_level + key.to_s + ' '*(data_indent - key.to_s.length) + ' = ' + value.inspect
        end
      end
    end

    true
  end

end