require 'rubygems'
require 'rake/clean'

CLOBBER.include('*.gem')

begin
  require 'spec/rake/spectask'
  Spec::Rake::SpecTask.new
rescue LoadError
  task(:spec){abort "`gem install rspec` to run specs"}
end

require 'hanna/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.main = 'README.rdoc'
  rdoc.title = "money #{version}"
  rdoc.rdoc_files.include('README.rdoc', 'LICENSE', 'CHANGELOG.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.options << '-U'
end
