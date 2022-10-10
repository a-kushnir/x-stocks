# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}" }

ruby '3.1.2'

gem 'bootsnap', '>= 1.4.2', require: false
gem 'caxlsx', '>= 3.1.0'
gem 'devise'
gem 'dotenv'
gem 'grape', '>= 1.6.2'
gem 'grape-entity'
gem 'grape-swagger'
gem 'grape-swagger-entity'
gem 'grape-swagger-representable'
gem 'hashid-rails'
gem 'honeybadger', '~> 4.0'
gem 'importmap-rails', '~> 1.0'
gem 'inline_svg'
gem 'net-http'
gem 'nokogiri'
gem 'pagy'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '>= 5.6.2'
gem 'rails', '>= 7.0.3'
gem 'sidekiq', '~> 6.5'
gem 'sidekiq-cron', '~> 1.8', require: false
gem 'sprockets-rails', '~> 3.4'
gem 'stimulus-rails', '~> 1.0'
gem 'swagger_ui_engine', github: 'a-kushnir/swagger_ui_engine'
gem 'turbo-rails', '~> 1.0'
gem 'tzinfo-data'
gem 'validates_serialized'
gem 'view_component', '>= 2.50'

# NOTE: FFI is a required pre-requisite for Windows or posix_spawn support in the ChildProcess gem. Ensure the `ffi` gem is installed
gem 'ffi' if RUBY_PLATFORM.match?(/x64-mingw32/i)

group :development do
  gem 'capistrano', '~> 3.17', require: false
  gem 'capistrano3-puma', github: 'seuros/capistrano-puma'
  gem 'capistrano-rails', require: false
  gem 'capistrano-rvm', require: false
  gem 'css_class_duplicates', require: false
  gem 'foreman'
  gem 'letter_opener'
  gem 'rubocop', require: false
  gem 'rubocop-flexport', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'rspec', require: false
  gem 'rspec-rails', require: false
  gem 'scrutinizer-ocular', require: false, github: 'a-kushnir/ocular.rb'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'webdrivers'
end
