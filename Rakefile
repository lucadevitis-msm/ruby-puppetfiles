require 'bundler/gem_tasks'
require 'yard'
require 'rake/clean'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

# Tells which files to remove on clean task.
CLEAN.include(['.yardoc', 'doc', 'coverage'])

RuboCop::RakeTask.new

YARD::Rake::YardocTask.new

RSpec::Core::RakeTask.new

# Tasks to run if rake command is called without arguments.
# task spec: [:rubocop, :yard]
task build: [:clean, :spec]
