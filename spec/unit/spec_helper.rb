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

def mock_model(attributes = {})
  model = attributes.dup

  def model.method_missing(method, *args)
    if method.to_s.end_with?('=')
      # Assign attributes
      method = method[0...-1]
      self[method.to_sym] = args.first

    elsif key?(method)
      # Return attributes
      self[method]

    else
      # Store method calls
      self[method] = args
    end
  end

  def model.respond_to_missing?(*_)
    nil
  end

  model
end
