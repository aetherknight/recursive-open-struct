class RecursiveOpenStruct::DeepDup
  def initialize(opts={})
    @recurse_over_arrays = opts.fetch(:recurse_over_arrays, false)
  end

  def call(obj)
    deep_dup(obj)
  end

  private

  def deep_dup(obj, visited=[])
    if obj.is_a?(Hash)
      obj.each_with_object({}) do |(key, value), h|
        h[key] = value_or_deep_dup(value, visited)
      end
    elsif obj.is_a?(Array) && @recurse_over_arrays
      obj.each_with_object([]) do |value, arr|
        arr << value_or_deep_dup(value, visited)
      end
    else
      obj
    end
  end

  def value_or_deep_dup(value, visited)
    obj_id = value.object_id
    visited.include?(obj_id) ? value : deep_dup(value, visited << obj_id)
  end
end
