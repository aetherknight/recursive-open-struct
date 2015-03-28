# -*- encoding: utf-8 -*-

require './lib/recursive_open_struct/version'

Gem::Specification.new do |s|
  s.name = "recursive-open-struct"
  s.version = RecursiveOpenStruct::VERSION
  s.authors = ["William (B.J.) Snow Orvis"]
  s.email = "aetherknight@gmail.com"
  s.date = Time.now.utc.strftime("%Y-%m-%d")
  s.homepage = "http://github.com/aetherknight/recursive-open-struct"
  s.licenses = ["MIT"]

  s.summary = "OpenStruct subclass that returns nested hash attributes as RecursiveOpenStructs"
  s.description = <<-QUOTE .gsub(/^    /,'')
    RecursiveOpenStruct is a subclass of OpenStruct. It differs from
    OpenStruct in that it allows nested hashes to be treated in a recursive
    fashion. For example:

        ros = RecursiveOpenStruct.new({ :a => { :b => 'c' } })
        ros.a.b # 'c'

    Also, nested hashes can still be accessed as hashes:

        ros.a_as_a_hash # { :b => 'c' }
    QUOTE

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files spec`.split("\n")
  s.require_paths = ["lib"]
  s.extra_rdoc_files = [
    "CHANGELOG.md",
    "LICENSE.txt",
    "README.md"
  ]

  s.add_development_dependency('rspec', "~> 3.2")
  s.add_development_dependency(%q<bundler>, [">= 0"])
  s.add_development_dependency(%q<rdoc>, [">= 0"])
  s.add_development_dependency(%q<rake>, [">= 0"])
end

