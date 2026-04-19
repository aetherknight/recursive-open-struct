# frozen_string_literal: true

name = 'recursive-open-struct'
version = File.foreach(File.join(__dir__, 'lib', 'recursive_open_struct', 'version.rb')) do |line|
  /^\s*VERSION\s*=\s*'(.*)'/ =~ line and break Regexp.last_match(1)
end

Gem::Specification.new do |s|
  s.name = name
  s.version = version
  s.authors = ['William (B.J.) Snow Orvis']
  s.email = 'aetherknight@gmail.com'
  s.date = Time.now.utc.strftime('%Y-%m-%d')
  s.homepage = 'https://github.com/aetherknight/recursive-open-struct'
  s.licenses = ['MIT']

  s.summary = 'OpenStruct subclass that returns nested hash attributes as RecursiveOpenStructs'
  s.description = <<-QUOTE.gsub(/^    /, '')
    RecursiveOpenStruct is a subclass of OpenStruct. It differs from
    OpenStruct in that it allows nested hashes to be treated in a recursive
    fashion. For example:

        ros = RecursiveOpenStruct.new({ :a => { :b => 'c' } })
        ros.a.b # 'c'

    Also, nested hashes can still be accessed as hashes:

        ros.a_as_a_hash # { :b => 'c' }
  QUOTE

  s.files = `git ls-files lib`.split("\n") + ['AUTHORS.txt', 'CHANGELOG.md', 'LICENSE.txt', 'README.md']
  s.require_paths = ['lib']
  s.extra_rdoc_files = [
    'CHANGELOG.md',
    'LICENSE.txt',
    'README.md'
  ]

  s.add_development_dependency('bundler', ['>= 2'])
  s.add_development_dependency('pry', ['>= 0'])
  s.add_development_dependency('rake', ['~>13.4'])
  s.add_development_dependency('rdoc', ['~>7.2'])
  s.add_development_dependency('rspec', '~> 3.13')
  s.add_development_dependency('rubocop', ['~>1.86'])
  s.add_development_dependency('rubocop-rake', ['~>0.7'])
  s.add_development_dependency('rubocop-rspec', ['~>3.9'])
  s.add_development_dependency('simplecov', ['>= 0'])

  s.add_dependency('ostruct')
end
