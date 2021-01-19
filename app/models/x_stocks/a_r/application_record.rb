# frozen_string_literal: true

module XStocks
  module AR
    # Base Active Record model
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
