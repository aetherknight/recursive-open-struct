# Necessary since the top-level class/module is a class that inherits from
# OpenStruct.
require 'ostruct'

class RecursiveOpenStruct < OpenStruct
  VERSION = "1.3.1"
end
