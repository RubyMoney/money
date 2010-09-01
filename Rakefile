require 'rubygems'
require 'rake/clean'

CLOBBER.include('doc', '.yardoc', '*.gem')

begin
  require 'spec/rake/spectask'
  Spec::Rake::SpecTask.new
rescue LoadError
  task(:spec){abort "`gem install rspec` to run specs"}
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.options << "--files" << "CHANGELOG,LICENSE"
  end
rescue LoadError
  task(:yardoc){abort "`gem install yard` to generate documentation"}
end
