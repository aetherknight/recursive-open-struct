# encoding: utf-8

require 'rubygems'
require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end
namespace :spec do
  if RUBY_VERSION =~ /^1\.8/
    desc "Rspec code coverage (1.8.7)"
    RSpec::Core::RakeTask.new(:coverage) do |spec|
      spec.pattern = 'spec/**/*_spec.rb'
      spec.rcov = true
    end
  else
    desc "Rspec code coverage (1.9+)"
    task :coverage do
      ENV['COVERAGE'] = 'true'
      Rake::Task["spec"].execute
    end
  end
end

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "recursive-open-struct #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :default => :spec

task :fix_permissions do
  File.umask 0022
  filelist = `git ls-files`.split("\n")
  FileUtils.chmod 0644, filelist, :verbose => true
  FileUtils.chmod 0755, ['lib','spec'], :verbose => true
end

desc "Update the AUTHORS.txt file"
task :update_authors do
  authors = `git log --format="%aN <%aE>"|sort -f|uniq`
  File.open('AUTHORS.txt', 'w') do |f|
    f.write("Recursive-open-struct was written by these fine people:\n\n")
    f.write(authors.split("\n").map { |a| "* #{a}" }.join( "\n" ))
    f.write("\n")
  end
end

task :build => [:update_authors, :fix_permissions]

desc "Run an interactive pry shell with ros required"
task :pry do
  sh "pry -I lib -r recursive-open-struct"
end
