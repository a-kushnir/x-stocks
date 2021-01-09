# frozen_string_literal: true

require 'rubygems'
require 'rack/test'

require 'bundler'
Bundler.require :default, :test

RSpec.configure do |config|
  config.mock_with :rspec
  config.expect_with :rspec
  config.raise_errors_for_deprecations!
end
