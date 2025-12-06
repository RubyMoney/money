# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/clean"

CLOBBER.include('doc', '.yardoc')

require "yard"

gemspec = Gem::Specification.load('money.gemspec')

YARD::Rake::YardocTask.new do |t|
  t.options << "--title" << gemspec.description
  t.options << "--files" << "CHANGELOG.md,LICENSE"
  t.options << "--markup" << "markdown"
  t.options << "--markup-provider" << "redcarpet"
end

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.fail_on_error = false
  t.ruby_opts = "-w"
end

task default: :spec
