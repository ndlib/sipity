source 'https://rubygems.org'
# Free 20% RAM by not loading ALL mime-types
gem 'mime-types', '~> 2.6.1', require: 'mime/types/columnar'
gem 'rails', '~> 4.2'

gem 'airbrake', '~> 4.2' # Until we update Errbit, I don't want to move to 5.x
gem 'autoprefixer-rails'
gem 'bootstrap-sass'
gem 'coffee-rails', '~> 4.0'
gem 'devise'
gem 'devise_cas_authenticatable'
gem 'devise-token_authenticatable'
gem 'dragonfly', github: 'jeremyf/dragonfly', branch: 'updating-dragonfly-to_file'
gem 'draper'
gem 'execjs'
gem 'ezid-client', github: 'duke-libraries/ezid-client'
gem 'figaro'
gem 'hesburgh-lib', github: 'ndlib/hesburgh-lib'
gem 'high_voltage'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'loofah', '~> 2.0.3' # Related to hesburgh-lib's dependency
gem 'noids_client', git: 'git://github.com/ndlib/noids_client'
gem 'rdiscount'
gem 'responders', '~> 2.0'
gem 'sanitize'
gem 'sass-rails'
gem 'simple_form'
gem 'turbolinks'
gem 'uglifier'
gem 'hydra-validations', github: 'projecthydra-labs/hydra-validations', branch: 'master', ref: 'bd9a84a8fd5acc607ad5c36984b7d09e4b3fc4d0'
gem 'power_converter'
gem 'curly-templates', github: 'jeremyf/curly', branch: 'sipity-hack'
gem 'kaminari'
gem 'locabulary', github: 'ndlib/locabulary', branch: 'master'
gem 'data_migrator', github: 'jeremyf/data-migrator'
gem 'dry-validation'
gem 'whenever', require: false

group :doc do
  gem 'inch', require: false
  gem 'railroady', require: false, github: 'jeremyf/railroady', branch: 'allowing-namespaced-models'
  gem 'yard', require: false
  gem 'yard-activerecord', require: false
  gem 'flay', require: false
  gem 'flog', require: false
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller', platforms: [:mri_21]
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
  # Paired with Chrome the RailsPanel plugin, you can see request information
  # https://github.com/dejan/rails_panel
  gem 'meta_request'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'quiet_assets'
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
  gem 'faker'
  gem 'pry-rescue', require: false
  gem 'pry-stack_explorer', require: false
  gem 'rspec-its'
  gem 'rspec', '~>3.4.0'
  gem 'rspec-rails', '~>3.4.0'
  gem 'commitment'
  gem 'jshintrb', github: 'ndlib/jshintrb', ref: 'f8cb0bd86ed9379acd50de871b3af9f8d251b977'
  gem 'rubocop'
end

group :test do
  gem 'capybara'
  gem 'capybara-accessible', require: false
  gem 'codeclimate-test-reporter', require: nil
  gem 'database_cleaner'
  gem 'launchy'
  gem 'poltergeist'
  gem 'rspec-given'
  gem 'rspec-html-matchers', '~>0.6'
  gem 'shoulda-callback-matchers'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 3.0.1'
  gem 'site_prism'
  gem 'sqlite3'
end

group :production, :pre_production, :staging do
  gem 'dragonfly-s3_data_store'
  gem 'rack-cache', require: 'rack/cache'
  gem 'rb-readline'
end
source 'https://rails-assets.org' do
  gem 'rails-assets-readmore'
end

group :production, :pre_production, :staging, :development do
  gem 'mysql2'
end

# Removing until I have a non-pro license
# group :production, :pre_production, :staging, :development do
#   gem 'newrelic_rpm'
# end
