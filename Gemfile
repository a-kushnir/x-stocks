# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/a-kushnir/#{repo}" }

ruby '2.7.5'

gem 'importmap-rails'
gem 'rails', '>= 7.0.2.2'
gem 'sass-rails', require: false
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'turbo-rails'

gem 'bootsnap', '>= 1.4.2', require: false
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '>= 5.6.2'

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

gem 'bootstrap', '~> 4.6.1'
gem 'bootstrap_form'
gem 'bootstrap-select-rails'
gem 'caxlsx', '>= 3.1.0'
gem 'devise'
gem 'inline_svg'
gem 'jquery-datatables'
gem 'jquery-rails'
gem 'nokogiri', '>= 1.13.3'

gem 'grape'
gem 'grape-entity'
gem 'grape-swagger'
gem 'grape-swagger-entity'
gem 'grape-swagger-representable'

gem 'swagger_ui_engine', github: 'swagger_ui_engine'
