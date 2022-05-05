source 'https://rubygems.org'

# Ensure that all github access points are via https
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'activerecord-session_store'
gem 'autoprefixer-rails'
gem 'bigdecimal'
gem 'bootstrap-sass'
gem 'bundler', "~> 1.17"
gem 'coffee-rails'
gem 'curly-templates', github: 'ndlib/curly', branch: 'updated-sipity-hacks'
gem 'data_migrator', github: 'ndlib/data-migrator'
gem 'devise_cas_authenticatable'
gem 'devise'
gem 'dragonfly', github: 'ndlib/dragonfly', branch: 'updating-dragonfly-to_file'
gem 'draper'
gem 'dry-schema'
gem 'execjs'
gem 'figaro'
gem 'hesburgh-lib', github: 'ndlib/hesburgh-lib'
gem 'jbuilder'
gem 'jquery-rails'
gem 'kaminari'
gem 'listen'
gem 'locabulary', github: 'ndlib/locabulary', ref: '9ff3ec48eb37c6bd047f7d0e47438a30060efdcc'
gem 'loofah' # Related to hesburgh-lib's dependency
gem 'mime-types', '~> 2.6', require: 'mime/types/columnar' # Free 20% RAM by not loading ALL mime-types
gem 'mysql2', '0.4.8'
gem 'noids_client', github: 'ndlib/noids_client', ref: '27c2d72166acd4ae726a60beff438c4c7d08fc88'
gem 'nokogiri'
gem 'omniauth-oktaoauth'
gem 'power_converter'
gem 'rails', '~> 5.2.0'
gem 'rdf-rdfa'
gem 'rdiscount'
gem 'responders'
gem 'rof', github: 'ndlib/rof'
gem 'sanitize'
gem 'sass-rails'
gem 'sentry-ruby'
gem 'simple_form'
gem 'mini_racer'
gem 'uglifier'
gem 'whenever', require: false
gem 'rack-mini-profiler'
gem 'flamegraph'
gem 'stackprof'
gem 'memory_profiler'

group :doc do
  gem 'bumbler', require: false
  gem 'flay', require: false
  gem 'flog', require: false
  gem 'inch', require: false
  gem 'railroady', require: false, github: 'ndlib/railroady', branch: 'allowing-namespaced-models'
  gem 'yard-activerecord', require: false
  gem 'yard', require: false
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller', platforms: [:mri_21]
  gem 'byebug'
  gem 'capistrano', '3.12.0'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rails-console'
  gem 'capistrano-rvm', '~> 0.1.1'
  gem 'guard-bundler'
  gem 'guard-jshintrb'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'guard-rubocop'
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
  gem 'commitment'
  gem 'brakeman', '< 5.1'
  gem 'jshintrb', github: 'ndlib/jshintrb', ref: 'f8cb0bd86ed9379acd50de871b3af9f8d251b977'
  gem 'pry-rescue', require: false
  gem 'pry-stack_explorer', require: false
  gem 'rspec-its', require: false
  gem 'rspec-rails', '~>3.4'
  gem 'rspec', '~>3.4'
  gem 'rubocop', '~> 0.49.0', require: false
end

group :test do
  gem 'capybara'
  gem 'codeclimate-test-reporter', require: nil
  gem 'database_cleaner'
  gem 'launchy'
  gem 'poltergeist'
  gem 'rails-controller-testing'
  gem 'rspec-html-matchers'
  gem 'selenium-webdriver'
  gem 'shoulda-callback-matchers'
  gem 'shoulda-matchers'
  gem 'site_prism', require: false
end

group :production, :prep do
  gem 'dragonfly-s3_data_store'
  gem 'irb'
  gem 'rack-cache', require: 'rack/cache'
  gem 'rb-readline'
end
