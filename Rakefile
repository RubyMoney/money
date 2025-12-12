# frozen_string_literal: true

# Clean
#
#   rake clean
#   rake clobber

require "rake/clean"

CLOBBER.include("doc", ".yardoc")

# Bundler
#
#   rake build
#   rake release

require "bundler/gem_tasks"

gemspec = Gem::Specification.load("money.gemspec")

# RuboCop
#
#   rake rubocop

require "rubocop/rake_task"

RuboCop::RakeTask.new

# Yard
#
#   rake yard

require "yard"

YARD::Rake::YardocTask.new do |t|
  t.options << "--title" << gemspec.description
  t.options << "--files" << "CHANGELOG.md,LICENSE"
  t.options << "--markup" << "markdown"
  t.options << "--markup-provider" << "redcarpet" unless RUBY_PLATFORM == "java"
end

# RSpec
#
#   rake spec

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |t|
  t.fail_on_error = false
  t.ruby_opts = "-w"
end

# File permissions
#
#   rake check_permissions

desc "Check file permissions"
task :check_permissions do
  files = Dir.glob("**/*.rb")
  files.each do |file|
    dir = File.dirname(file)
    unless File.new(dir).lstat.mode.to_s(8) == "40755"
      raise "Please check permissions for dir #{dir.inspect}"
    end

    unless File.new(file).lstat.mode.to_s(8) == "100644"
      raise "Please check permission for file #{file.inspect}"
    end
  end
end

# rubocop:disable Rake/Desc
task release: :check_permissions
task spec: :check_permissions
# rubocop:enable Rake/Desc

# Default task
#
#    rake

task default: [:rubocop, :spec]
