require 'rubygems'
require 'rake'
require 'rake/clean'

CLOBBER << 'pkg'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "money"
    gem.summary = "Money and currency exchange support library"
    gem.description = "Money and currency exchange support library."
    gem.email = "hongli@phusion.nl"
    gem.homepage = "http://money.rubyforge.org/"
    gem.authors = ["Tobias Luetke", "Hongli Lai", "Jeremy McNevin", "Shane Emmons", "Simone Carletti"]
    gem.rubyforge_project = "money"
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "hanna", ">= 0.1.12"
  end
  Jeweler::GemcutterTasks.new
  Jeweler::RubyforgeTasks.new do |gem|
    gem.remote_doc_path = ""
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = Dir['spec/**/*_spec.rb']
  spec.spec_opts << '--format specdoc'
  spec.spec_opts << '--color'
end

task :spec => :check_dependencies

task :default => :spec

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
