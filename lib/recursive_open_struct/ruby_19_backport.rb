module RecursiveOpenStruct::Ruby19Backport
  # Apply fix if necessary:
  #   https://github.com/ruby/ruby/commit/2d952c6d16ffe06a28bb1007e2cd1410c3db2d58
  def initialize_copy(orig)
    super
    @table.each_key{|key| new_ostruct_member(key)}
  end

  def []=(name, value)
    modifiable[new_ostruct_member(name)] = value
  end

  def eql?(other)
    return false unless other.kind_of?(OpenStruct)
    @table.eql?(other.table)
  end

  def hash
    @table.hash
  end

  def each_pair
    return to_enum(:each_pair) { @table.size } unless block_given?
    @table.each_pair{|p| yield p}
  end
end

