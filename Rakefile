# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "recursive-open-struct"
  gem.homepage = "http://github.com/aetherknight/recursive-open-struct"
  gem.license = "MIT"
  gem.summary = %Q{OpenStruct subclass that returns nested hash attributes as RecursiveOpenStructs}
  gem.description = <<EOF
RecursiveOpenStruct is a subclass of OpenStruct. It differs from
OpenStruct in that it allows nested hashes to be treated in a recursive
fashion. For example:

    ros = RecursiveOpenStruct.new({ :a => { :b => 'c' } })
    ros.a.b # 'c'

Also, nested hashes can still be accessed as hashes:

    ros.a_as_a_hash # { :b => 'c' }
EOF
  gem.email = "aetherknight@gmail.com"
  gem.authors = ["William (B.J.) Snow Orvis"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "recursive-open-struct #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
