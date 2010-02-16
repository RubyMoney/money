require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "money"
    gem.summary = "Money and currency exchange support library"
    gem.description = "Money and currency exchange support library."
    gem.email = "hongli@phusion.nl"
    gem.homepage = "http://money.rubyforge.org/"
    gem.authors = ["Tobias Luetke", "Hongli Lai", "Jeremy McNevin", "Shane Emmons"]
    gem.rubyforge_project = "money"
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "hanna", ">= 0.1.12"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'test'
  spec.spec_files = FileList['test/**/*_spec.rb']
  spec.spec_opts << '--format specdoc'
end

task :spec => :check_dependencies

task :default => :spec

require 'hanna/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.main = 'README.rdoc'
  rdoc.title = "money #{version}"
  rdoc.rdoc_files.include('README.rdoc', 'LICENSE')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.options << '-U'
end
