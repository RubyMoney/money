require "rubygems"
require "bundler/gem_tasks"
require "rake/clean"

CLOBBER.include('doc', '.yardoc')

require "yard"

YARD::Rake::YardocTask.new do |t|
  t.options << "--files" << "CHANGELOG.md,LICENSE"
end
