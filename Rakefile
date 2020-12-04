# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

namespace :db do
  task prepare: :environment do
    abort("Run this only in test or development") unless Rails.env.test? || Rails.env.development?
    begin
      Rake::Task["db:drop"].invoke
    rescue
      $stdout.puts "Unable to drop database, moving on."
    end
    Rake::Task["db:create"].invoke
    Rake::Task['db:schema:load'].invoke
  end
end

types = begin
  dirs = Dir['./app/**/*.rb'].map { |f| f.sub(%r{^\./(app/\w+)/.*}, '\\1') }.uniq.select { |f| File.directory?(f) }
  Hash[dirs.map { |d| [d.split('/').last, d] }]
end
if defined?(RSpec)
  namespace :spec do
    desc "Run all specs"
    RSpec::Core::RakeTask.new(all: ['sipity:rebuild_interfaces', 'sipity:verify_i18n']) do
      ENV['COVERAGE'] = 'true'
    end

    namespace :coverage do
      desc "Run all non-feature specs"
      RSpec::Core::RakeTask.new(:without_features) do |t|
        ENV['COVERAGE'] = 'true'
        t.exclude_pattern = './spec/features/**/*_spec.rb'
        t.rspec_opts = '--profile 10'
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

    desc 'Run the CI specs'
    task :ci do
      ENV['SPEC_OPTS'] ||= "--profile 5"
      Rake::Task[:default].invoke
    end
  end

  # BEGIN `commitment:install` generator
  # This was added via commitment:install generator. You are free to change this.
  Rake::Task["default"].clear
  task(
    default: [
      'commitment:rubocop',
      'commitment:jshint',
      'commitment:scss_lint',
      'db:create',
      'db:schema:load',
      'commitment:configure_test_for_code_coverage',
      'spec:all',
      'commitment:code_coverage',
      'commitment:brakeman'
    ]
  )
  # END `commitment:install` generator
  task spec: ['sipity:rebuild_interfaces']
  task stats: ['sipity:stats_setup']
end

if Rails.env.development? || Rails.env.test?
  desc 'Drop and create a new database with proper seed data'
  task bootstrap: ['db:drop', 'db:create', 'db:schema:load', 'db:seed', 'sipity:environment_bootstrapper', 'db:data:migrate']
end
