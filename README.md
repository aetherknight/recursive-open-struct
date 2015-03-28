# recursive-open-struct

OpenStruct subclass that returns nested hash attributes as
RecursiveOpenStructs.

It allows for hashes within hashes to be called in a chain of methods:

    ros = RecursiveOpenStruct.new( { :fooa => { :foob => 'fooc' } } )

    ros.fooa.foob # => 'fooc'

Also, if needed, nested hashes can still be accessed as hashes:

    ros.fooa_as_a_hash # { :foob => 'fooc' }

RecursiveOpenStruct can also optionally recurse across arrays, although you
have to explicitly enable it:

    h = { :somearr => [ { :name => 'a'}, { :name => 'b' } ] }

    ros = RecursiveOpenStruct.new(h, :recurse_over_arrays => true )

    ros.somarr[0].name # => 'a'
    ros.somarr[1].name # => 'b'

## Installation

Available as a gem in rubygems, the default gem repository.

If you use bundler, just throw that in your gemfile :

    gem 'recursive-open-struct'

You may also install the gem manually :

    gem install recursive-open-struct

## Contributing
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for your new or changed functionality. Make sure the tests you add
  provide clean and clear explanation of the feature.
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2009-2015 William (B.J.) Snow Orvis. See LICENSE for details.
