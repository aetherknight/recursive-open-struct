# Contributing to recursive-open-struct

Thanks for wanting to contribute a bug or code to recursive-open-struct!

To help you out with understanding the direction and philosophy of this project
with regards to to new features/how it should behave (and whether to file a bug
report), please review the following contribution guidelines.

## ROS Feature Philosophy

Recursive-open-struct tries to be a minimal extension to the Ruby stdlib's
`ostruct`/OpenStruct that allows for a nested set of Hashes (and Arrays) to
initialize similarly structured OpenStruct-like objects. This has the benefit
of creating arbitrary objects whose values can be accessed with accessor
methods, similar to JavaScript Objects' dot-notation.

To phrase it another way, RecursiveOpenStruct tries to behave as closely as
possible to OpenStruct, except for the recursive functionality that it adds.

If Recursive-open-struct were to add additional features (particularly methods)
that are not implemented by OpenStruct, then those method names would not be
available for use for accessing fields with the dot-notation that OpenStruct
and RecursiveOpenStruct provide.

For example, OpenStruct is not (at the time this is written) a
subclass/specialization of Hash, so several methods implemented by Hash do not
work with OpenStruct (and thus Recursive OpenStruct), such as `#fetch`.

If you want to add features into RecursiveOpenStruct that would "pollute" the
method namespace more than OpenStruct already does, consider creating your own
subclass instead of submitting a code change to RecursiveOpenStruct itself.


## Filing/Fixing Bugs and Requesting/Proposing New Features

For simple bug fixes, feel free to provide a pull request. This includes bugs
in stated features of RecursiveOpenStruct, as well as features added to
OpenStruct in a newer version of Ruby that RecursiveOpenStruct needs custom
support to handle.

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
