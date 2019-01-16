source 'https://rubygems.org'

# Ensure that all github access points are via https
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Free 20% RAM by not loading ALL mime-types
gem 'mime-types', '~> 2.6', require: 'mime/types/columnar'
gem 'rails', '~> 4.2'

gem 'sentry-raven', '~> 2.7'
gem 'autoprefixer-rails'
gem 'bigdecimal'
gem 'bootstrap-sass'
gem 'coffee-rails', '~> 4.0'
gem 'devise'
gem 'devise_cas_authenticatable'
gem 'dragonfly', github: 'jeremyf/dragonfly', branch: 'updating-dragonfly-to_file'
gem 'draper'
gem 'execjs'
gem 'figaro'
gem 'hesburgh-lib', github: 'ndlib/hesburgh-lib'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'listen', '~> 3.0.7' # Frozen for Ruby 2.2.2; Release once updated
gem 'loofah' # Related to hesburgh-lib's dependency
gem 'noids_client', github: 'ndlib/noids_client'
gem 'rdiscount'
gem 'responders', '~> 2.0'
gem 'sanitize'
gem 'sass-rails'
gem 'simple_form'
gem 'therubyracer'
gem 'uglifier'
gem 'power_converter'
gem 'curly-templates', github: 'jeremyf/curly', branch: 'sipity-hack'
gem 'kaminari'
gem 'locabulary', github: 'ndlib/locabulary', branch: 'master'
gem 'data_migrator', github: 'jeremyf/data-migrator'
gem 'dry-validation', '~> 0.8.0'
gem 'dry-types', '~> 0.8.0'
gem 'dry-logic', '~> 0.3.0'
gem 'dry-monads', '~> 0.3.0'
gem 'whenever', require: false
gem 'rof', github: 'ndlib/rof'
gem 'rdf-aggregate-repo', '~> 2.0.0'
gem 'rdf-rdfa', '~> 2.0.1'
gem 'rdf-isomorphic', '~> 2.0.0' # Required by 2.1
gem 'nokogiri'

group :doc do
  gem 'inch', require: false
  gem 'railroady', require: false, github: 'jeremyf/railroady', branch: 'allowing-namespaced-models'
  gem 'yard', require: false
  gem 'yard-activerecord', require: false
  gem 'flay', require: false
  gem 'flog', require: false
  gem 'bumbler', require: false
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller', platforms: [:mri_21]
  gem 'byebug', '9.0.6', require: false
  gem 'capistrano', '~> 3.1'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rails-console'
  gem 'capistrano-rvm', '~> 0.1.1'
  gem 'guard-bundler'
  gem 'guard-jshintrb'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'guard-scss-lint', github: 'ndlib/guard-scss-lint'
  gem 'i18n-debug'
  gem 'letter_opener'
  gem 'pry-byebug', '~> 3.4.0', require: false
  gem 'pry-rails', require: false
  gem 'rails_layout'
  gem 'rb-fchange', require: false
  gem 'rb-fsevent', require: false
  gem 'rb-inotify', '~> 0.9', require: false
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'terminal-notifier'
  gem 'terminal-notifier-guard', '~> 1.6.4'
end

group :development, :staging do
  gem 'seed_dump'
end

group :development, :test do
  gem 'pry-rescue', require: false
  gem 'pry-stack_explorer', require: false
  gem 'rspec-its', require: false
  gem 'rspec', '~>3.4.0'
  gem 'rspec-rails', '~>3.4.0'
  gem 'commitment'
  gem 'jshintrb', github: 'ndlib/jshintrb', ref: 'f8cb0bd86ed9379acd50de871b3af9f8d251b977'
  gem 'rubocop', '~> 0.49.0', require: false
end

group :test do
  gem 'capybara'
  gem 'codeclimate-test-reporter', require: nil
  gem 'database_cleaner'
  gem 'launchy'
  gem 'poltergeist'
  gem 'rspec-html-matchers', '~>0.6'
  gem 'shoulda-callback-matchers'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 3.0.1'
  gem 'site_prism', require: false
  gem 'sqlite3'
end

group :production, :pre_production, :staging do
  gem 'dragonfly-s3_data_store'
  gem 'rack-cache', require: 'rack/cache'
  gem 'rb-readline'
  gem 'irb'
end
source 'https://rails-assets.org' do
  gem 'rails-assets-readmore'
end

group :production, :pre_production, :staging, :development do
  gem 'mysql2', '0.4.8'
end

# Removing until I have a non-pro license
# group :production, :pre_production, :staging, :development do
#   gem 'newrelic_rpm'
# end
