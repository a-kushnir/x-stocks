# frozen_string_literal: true

module DataTable
  # Represent a data table column
  class Column
    FORMATS = DataTable::Formats
              .constants
              .map { |const| DataTable::Formats.const_get(const) }
              .map { |const| [const.name.demodulize.underscore, const.new] }
              .to_h.freeze

    attr_reader :code, :label, :align, :sorting, :default, :formatter, :visible

    delegate :format, to: :formatter

    def initialize(code:, label:, formatter:, align: 'text-right', sorting: false, default: false)
      @code = code
      @label = label
      @align = align
      @sorting = sorting
      @default = default
      @formatter = FORMATS[formatter.to_s]
      raise "Unknown formatter '#{formatter}'" unless @formatter
    end
  end
end
