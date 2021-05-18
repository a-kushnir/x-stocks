# frozen_string_literal: true

module AR
  # Allows to assign decimals with commas like 12,345.67 to AR fields
  module Numerical
    def self.included(base)
      base.class_eval do
        def self.numerical(*attributes)
          attributes.each do |attribute|
            define_method("#{attribute}=") do |value|
              self[attribute] = value.present? ? value.to_s.scan(/\b-?[\d.]+/).join.to_d : nil
            end
          end
        end
      end
    end
  end
end
