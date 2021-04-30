# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/a-kushnir/#{repo}" }

ruby '2.6.6'

gem 'bootsnap', '>= 1.4.2', require: false
gem 'jbuilder', '~> 2.7'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.1'
gem 'rack', '<2.2'
gem 'rails', '~> 6.1.3', '>= 6.1.3.1'
gem 'sass-rails', '>= 6'
gem 'turbolinks', '~> 5'
gem 'webpacker', '~> 4.0'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem 'rubocop', require: false
  gem 'rubocop-flexport', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'rspec', require: false
  gem 'rspec-rails', require: false
  gem 'scrutinizer-ocular', require: false, github: 'ocular.rb'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'bootstrap', '~> 4.5.0'
gem 'bootstrap_form'
gem 'bootstrap-select-rails'
gem 'caxlsx', '>= 3.1.0'
gem 'devise'
gem 'font_awesome5_rails'
gem 'jquery-datatables'
gem 'jquery-rails'
gem 'nokogiri', '>= 1.11.0.rc4'

gem 'grape'
gem 'grape-entity'
gem 'grape-swagger'
gem 'grape-swagger-entity'
gem 'grape-swagger-representable'

gem 'sprockets-rails', '2.3.3'
gem 'swagger_ui_engine', github: 'swagger_ui_engine'
