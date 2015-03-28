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
