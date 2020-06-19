1.1.1 / 2020/03/10
==================

* FIX [#64](https://github.com/aetherknight/recursive-open-struct/pull/64):
  Pirate Praveen: Support Ruby 2.7.0. `OpenStruct#modifiable` support was
  finally dropped, and has to be replaced with `OpenStruct#modifiable?`.
* Made some additional changes to continue supporting pre-2.4.x Rubies,
  including the current stable JRuby (9.1.x.x, which tracks Ruby 2.3.x for
  features)

1.1.0 / 2018-02-03
==================

* NEW/FIX [#56](https://github.com/aetherknight/recursive-open-struct/issues/56):
  Add better support for Ruby 2.3+'s `#dig` method (when it exists for the
  current version of Ruby), so that nested Hashes are properly converted to
  RecursiveOpenStructs. `OpenStruct#dig`'s implementation was returning Hashes
  and does not handle `recurse_over_arrays` so ROS needs special support.
  Thanks to maxp-edcast for reporting the issue.
* FIX [#55](https://github.com/aetherknight/recursive-open-struct/pull/55):
  EdwardBetts: Fixed a typo in the documentation/comment for `#method_missing`

1.0.5 / 2017-06-21
==================

* FIX [#54](https://github.com/aetherknight/recursive-open-struct/pull/54):
  Beni Cherniavsky-Paskin: Improve performance of `new_ostruct_member` by using
  `self.singleton_class.method_defined?` instead of `self.methods.include?`

1.0.4 / 2017-04-29
==================

* FIX [#52](https://github.com/aetherknight/recursive-open-struct/pull/52): Joe
  Rafaniello: Improve performance of DeepDup by using Set instead of an Array
  to track visited nodes.

1.0.3 / 2017-04-10
==================

* No longer officially supporting Ruby 2.0.0 and Ruby 2.1.x. They are still
  tested against but are permitted to fail within the Travis configuration.
* FIX: Fix subscript notation for keys that collide with existing public
  methods. Related to
  [#51](https://github.com/aetherknight/recursive-open-struct/issues/51).
* FIX [#49](https://github.com/aetherknight/recursive-open-struct/issues/49):
  Ensure test suite passes with Ruby 2.4.0-rc1.

1.0.2 / 2016-12-20
==================

* FIX [#46](https://github.com/aetherknight/recursive-open-struct/issues/46):
  Pedro Sena: fix issues with mutating arrays within an ROS that has
  `recurse_over_arrays: true`

1.0.1 / 2016-01-18
==================

* FIX [#42](https://github.com/aetherknight/recursive-open-struct/issues/42):
  `[]` tried to call private methods if they existed instead of triggering the
  `method_missing` code path. Thanks to @SaltwaterC for reporting.

1.0.0 / 2015-12-11
==================

* API-Breaking Change: Frederico Aloi: Change `to_h` to always return symbol
  keys. This is more consistent with OpenStruct.
* API-Breaking Change: No longer officially supporting Ruby 1.9.3.
* NEW/FIX: Kris Dekeyser: Ensure that ROS continues to work with the new
  version of OpenStruct included in dev versions of Ruby 2.2.x and Ruby 2.3. It
  now implements lazy attribute creation, which broke ROS.
* NEW: Added `preserve_original_keys` option to revert to the 0.x behavior. Set
  it to true if you want methods like `to_h` to return strings and perhaps
  other non-symbols.
* NEW: Ensuring support for Ruby 2.0.0+ including the upcoming 2.3 release and
  JRuby 9000.
* FIX: Peter Yeremenko: Fix a mistake in one of the examples in the README

0.6.5 / 2015-06-30
==================

* FIX: Fix ROS when initialized with nil instead of a hash.

0.6.4 / 2015-05-20
==================

* FIX: Kris Dekeyser: Fix indifferent subscript access (string or symbol). Also
  backported several ostruct methods for Ruby 1.9.x.
* FIX: Partial fix for allowing an array in a RecursiveOpenStruct tree to be
  modified. However, methods such as to_hash are still broken.

0.6.3 / 2015-04-11
==================

* FIX: Thiago Guimaraes: Restore being able to create an ROS from a hash that
  contains strings for keys instead of symbols for keys.

0.6.2 / 2015-04-07
==================

* FIX: fervic: Address a bug in the Ruby 1.9's version of OpenStruct's `dup`
* FIX: Victor Guzman: Reset memoized values on assignment in order to force the
  implementation to re-memoize them.
* MAINT: fervic: Simplified `initialize`

0.6.1 / 2015-03-28
==================

* FIX: Actually ensure that the internal @table is properly dependent or
  independent of the input hash tree. I mistakenly refactored away an important
  piece of code that fervic added.
* FIX: Actually ensure that `#dup` works.
* Also refactored how `#to_h` is implemented to use newer plumbing.

0.6.0 / 2015-03-28
==================

* NEW: fervic: Make subscript notation be recursive like dot-method notation
* NEW: fervic: Added a new option, `:mutate_input_hash`, that allows the caller
  to determine whether the original hash is mutated or not when a nested value
  in the ROS tree is modified. If false (the default), the ROS will not modify
  the original hash tree. If tree, changes within the ROS tree will also be
  reflected in the hash tree.
* FIX: fervic: Setting/updating a value nested deep in an ROS tree is kept
  when the top-level ROS object is duped.
* MAINT: Extracted `#deep_dup` added by fervic into its own class. This makes it
  possibly easier to use/copy for others, and it cleans up the main class file.
* MAINT: Moved `#debug_inspect` out to its own module. This cleans up the main
  class file a bit. It is also something I may remove if I ever have a major
  version bump.
* MAINT: Adding MRI 2.2 to Travis-CI

0.5.0 / 2014-06-14
==================

* NEW: Tom Chapin: Added a `#to_hash` alias for `#to_h`
* MAINT: Added Travis-CI support. Testing against MRI 1.9.3, MRI 2.0, MRI 2.1,
  and JRuby in 1.9 mode. Not aiming to support 1.8.7 since it has been nearly a
  year since it has officially been retired.

0.4.5 / 2013-10-23
==================

* FIX: Matt Culpepper: Allow ROS subclasses to use their own type when creating
  nested objects in the tree.

0.4.4 / 2013-08-28
==================

* FIX: Ensure proper file permissions when building the gem archive

0.4.3 / 2013-05-30
==================

* FIX: Sebastian Gaul: Make `recurse_over_arrays` option work on more
  deeply-nested hashes.

0.4.2 / 2013-05-29
==================

* FIX: Setting a value on a nested element, then getting that value should show
  the updated value
* FIX: Calling `#to_h` on the top-level ROS object also reflects changed nested
  elements.

0.4.1 / 2013-05-28
==================

* FIX: Fixing the `spec:coverage` Rake task

0.4.0 / 2013-05-26
==================

* NEW: Added `#to_h`
* MAINT: Stopped using jeweler for gem development/packaging

0.3.1 / 2012-10-23
==================

* FIX: Cédric Felizard: Fix to make it work with MRI 1.8.7 again
* MAINT: More spec fixups to improve spec runs on MRI 1.9.3

0.3.0 / 2013-10-23
==================

* NEW: Matthew O'Riordan: Add support for recursion working over Arrays
* NEW: Made recursion over Arrays optional with `recurse_over_arrays` option.
* NEW: Improving `#debug_inspect` so that it can use any IO object, not just
  STDOUT.
* MAINT: Much cleanup of development dependencies, README file, etc.

0.2.1 / 2011-05-31
==================

* FIX: Offirmo: Slight improvement for `#debug_inspect`

0.2.0 / 2011-05-25
==================

* NEW: Offirmo: Added `debug_inspect`
* MAINT: Offirmo: Worked the development files so that it can be built as a gem

0.1.0 / 2010-01-12
==================

* Initial release
