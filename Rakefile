require "rubygems"
require "bundler/gem_tasks"
require "rake/clean"
require "rspec/core/rake_task"

CLOBBER.include('doc', '.yardoc')

require "yard"

YARD::Rake::YardocTask.new do |t|
  t.options << "--files" << "CHANGELOG.md,LICENSE"
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.fail_on_error = false
end

