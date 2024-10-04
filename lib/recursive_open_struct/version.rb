# Necessary since the top-level class/module is a class that inherits from
# OpenStruct.
require 'ostruct'

class RecursiveOpenStruct < OpenStruct
  VERSION = "2.0.0"
end
