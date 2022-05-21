# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/a-kushnir/#{repo}" }

ruby '2.7.5'

gem 'bootsnap', '>= 1.4.2', require: false
gem 'honeybadger', '~> 4.0'
gem 'importmap-rails', '~> 1.0'
gem 'net-http'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '>= 5.6.2'
gem 'rails', '>= 7.0.2.2'
gem 'sprockets-rails', '~> 3.4'
gem 'stimulus-rails', '~> 1.0'
gem 'turbo-rails', '~> 1.0'
gem 'view_component', '>= 2.50'

group :development do
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
  gem 'scrutinizer-ocular', require: false, github: 'ocular.rb'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'caxlsx', '>= 3.1.0'
gem 'devise'
gem 'inline_svg'
gem 'nokogiri'
gem 'pagy'

gem 'grape'
gem 'grape-entity'
gem 'grape-swagger'
gem 'grape-swagger-entity'
gem 'grape-swagger-representable'

gem 'swagger_ui_engine', github: 'swagger_ui_engine'
