# frozen_string_literal: true

require 'forwardable'

module XStocks
  # AR Forwarder Business Model
  class ARForwarder
    def self.delegate_methods(base, attr_name, ar_model)
      methods = %i[\[\] \[\]= attributes attributes= new_record? model_name to_key errors reload]

      columns = ar_model.columns.map(&:name)
      methods += columns
      methods += columns.map { |column| "#{column}=" }

      associations = ar_model.reflect_on_all_associations.collect(&:name)
      methods += associations
      methods += associations.map { |column| "#{column}=" }

      overrides = methods.select { |method| base.method_defined?(method) }
      raise "The methods override AR ones: #{overrides.join(', ')}" if overrides.any?

      base.extend Forwardable
      base.def_delegators attr_name, *methods
    end
  end
end
