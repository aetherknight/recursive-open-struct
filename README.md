# recursive-open-struct

OpenStruct subclass that returns nested hash attributes as
RecursiveOpenStructs.


## Usage

It allows for hashes within hashes to be called in a chain of methods:

```ruby
ros = RecursiveOpenStruct.new( { wha: { tagoo: 'siam' } } )

ros.wha.tagoo # => 'siam'
```

Also, if needed, nested hashes can still be accessed as hashes:

```ruby
ros.wha_as_a_hash # { tagoo: 'siam' }
```


### Optional: Recurse Over Arrays

RecursiveOpenStruct can also optionally recurse across arrays, although you
have to explicitly enable it.

Default behavior:
```ruby
h = { :somearr => [ { name: 'a'}, { name: 'b' } ] }

ros = RecursiveOpenStruct.new(h)
ros.somearr # => [ { name: 'a'}, { name: 'b' } ]
```

Enabling `recurse_over_arrays`:

```ruby
ros = RecursiveOpenStruct.new(h, recurse_over_arrays: true )

ros.somearr[0].name # => 'a'
ros.somearr[1].name # => 'b'
```


### Optional: Preserve Original Keys

Also, by default it will turn all hash keys into symbols internally:

```ruby
h = { 'fear' => 'is', 'the' => 'mindkiller' } }
ros = RecursiveOpenStruct.new(h)
ros.to_h # => { fear: 'is', the: 'mindkiller' }
```

You can preserve the original keys by enabling `:preserve_original_keys`:

```ruby
h = { 'fear' => 'is', 'the' => 'mindkiller' } }
ros = RecursiveOpenStruct.new(h, preserve_original_keys: true)
ros.to_h # => { 'fear' => 'is', 'the' => 'mindkiller' }
```


## Installation

Available as a gem in rubygems, the default gem repository.

If you use bundler, just add recursive-open-struct to your gemfile :

```ruby
gem 'recursive-open-struct'
```

You may also install the gem manually:

    gem install recursive-open-struct


## Contributing

If you would like to file or fix a bug, or propose a new feature, please review
[CONTRIBUTING](CONTRIBUTING.md) first.


## Supported Ruby Versions

Recursive-open-struct attempts to support just the versions of Ruby that are
still actively maintained. Once a given major/minor version of Ruby no longer
receives patches, they will no longer be supported (but recursive-open-struct
may still work). I usually update the travis.yml file to reflect this when
preparing for a new release or do some other work on recursive-open-struct.

I also try to update recursive-open-struct to support new features in
OpenStruct itself as new versions of Ruby are released. However, I don't
actively monitor the status of this, so a newer feature might not work. If you
encounter such a feature, please file a bug or a PR to fix it, and I will try
to cut a new release of recursive-open-struct quickly.


## SemVer Compliance

Rescursive-open-struct follows [SemVer
2.0](https://semver.org/spec/v2.0.0.html) for its versioning.


## Copyright

Copyright (c) 2009-2018, The Recursive-open-struct developers (given in the
file AUTHORS.txt). See LICENSE.txt for details.
