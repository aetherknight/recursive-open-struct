# recursive-open-struct

OpenStruct subclass that returns nested hash attributes as
RecursiveOpenStructs.

It allows for hashes within hashes to be called in a chain of methods:

    ros = RecursiveOpenStruct.new( { fooa: { foob: 'fooc' } } )

    ros.fooa.foob # => 'fooc'

Also, if needed, nested hashes can still be accessed as hashes:

    ros.fooa_as_a_hash # { foob: 'fooc' }

RecursiveOpenStruct can also optionally recurse across arrays, although you
have to explicitly enable it:

    h = { :somearr => [ { name: 'a'}, { name: 'b' } ] }
    ros = RecursiveOpenStruct.new(h, recurse_over_arrays: true )

    ros.somearr[0].name # => 'a'
    ros.somearr[1].name # => 'b'

Also, by default it will turn all hash keys into symbols internally:

    h = { 'fear' => 'is', 'the' => 'mindkiller' } }
    ros = RecursiveOpenStruct.new(h)
    ros.to_h # => { fear: 'is', the: 'mindkiller' }

You can preserve the original keys by enabling `:preserve_original_keys`:

    h = { 'fear' => 'is', 'the' => 'mindkiller' } }
    ros = RecursiveOpenStruct.new(h, preserve_original_keys: true)
    ros.to_h # => { 'fear' => 'is', 'the' => 'mindkiller' }

## Installation

Available as a gem in rubygems, the default gem repository.

If you use bundler, just throw that in your gemfile :

    gem 'recursive-open-struct'

You may also install the gem manually :

    gem install recursive-open-struct

## Contributing

For simple bug fixes, feel free to provide a pull request.

For anything else (new features, bugs that you want to report, and bugs that
are difficult to fix), I recommend opening an issue first to discuss the
feature or bug. I am fairly cautious about adding new features that might cause
RecursiveOpenStruct's API to deviate radically from OpenStruct's (since it
might introduce new reserved method names), and it is useful to discuss the
best way to solve a problem when there are tradeoffs or imperfect solutions.

When contributing code that changes behavior or fixes bugs, please include unit
tests to cover the new behavior or to provide regression testing for bugs.
Also, treat the unit tests as documentation --- make sure they are clean,
clear, and concise, and well organized.

## Copyright

Copyright (c) 2009-2017, The Recursive-open-struct developers (given in the
file AUTHORS.txt). See LICENSE.txt for details.
