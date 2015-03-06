# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new do |t|
    t.options << '--config=./.hound.yml'
  end
rescue LoadError
  puts "Unable to load rubocop. Who will enforce your styles now?"
end

types = begin
  dirs = Dir['./app/**/*.rb'].map { |f| f.sub(%r{^\./(app/\w+)/.*}, '\\1') }.uniq.select { |f| File.directory?(f) }
  Hash[dirs.map { |d| [d.split('/').last, d] }]
end
if defined?(RSpec)
  namespace :spec do
    desc "Run all specs"
    RSpec::Core::RakeTask.new(all: 'sipity:rebuild_interfaces') do
      ENV['COVERAGE'] = 'true'
    end

    namespace :coverage do
      desc "Run all non-feature specs"
      RSpec::Core::RakeTask.new(:without_features) do |t|
        ENV['COVERAGE'] = 'true'
        t.exclude_pattern = './spec/features/**/*_spec.rb'
      end

      types.each do |name, _dir|
        desc "Run, with code coverage, the examples in spec/#{name.downcase}"
        RSpec::Core::RakeTask.new(name) do |t|
          ENV['COVERAGE'] = 'true'
          ENV['COV_PROFILE'] = name.downcase
          t.pattern = "./spec/#{name}/**/*_spec.rb"
        end
      end
    end

    desc 'Run the Travis CI specs'
    task travis: [:rubocop] do
      ENV['SPEC_OPTS'] ||= "--profile 5"
      Rake::Task['spec:all'].invoke
    end

    desc "Run all features with accessibility checks"
    RSpec::Core::RakeTask.new(:accessible) do |t|
      ENV['ACCESSIBLE'] = 'true'
      t.pattern = './spec/features/**/*_spec.rb'
    end

  end

  Rake::Task["default"].clear
  task default: ['db:schema:load', 'rubocop', 'spec:all']
  task stats: ['sipity:stats_setup']
end

if Rails.env.development? || Rails.env.test?
  desc 'Drop and create a new database with proper seed data'
  task bootstrap: ['db:drop', 'db:create', 'db:schema:load', 'db:seed', 'sipity:environment_bootstrapper']
end
