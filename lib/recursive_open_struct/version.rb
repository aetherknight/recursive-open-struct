# Necessary since the top-level class/module is a class that inherits from
# OpenStruct.
require 'ostruct'

class RecursiveOpenStruct < OpenStruct
  VERSION = "1.2.2"
end
