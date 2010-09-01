require 'rubygems'
require 'rake'
require 'rake/clean'

CLOBBER << '*.gem'

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:test) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = Dir['spec/**/*_spec.rb']
  spec.spec_opts << '--color'
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
