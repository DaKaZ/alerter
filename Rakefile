require 'rubygems'
require 'bundler/setup'

require "bundler/gem_tasks"

Bundler::GemHelper.install_tasks

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'
require "rspec/core/rake_task"

require 'appraisal'
require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :default => :spec

