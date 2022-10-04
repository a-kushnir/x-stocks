# frozen_string_literal: true

module DataTable
  # Represent a data table column
  class Column
    ALIGNS = %w[left center right].freeze
    # rubocop:disable Style/MapToHash
    FORMATS = DataTable::Formats
              .constants
              .map { |const| DataTable::Formats.const_get(const) }
              .to_h { |const| [const.name.demodulize.underscore, const.new] }
              .freeze
    # rubocop:enable Style/MapToHash

    attr_reader :code, :label, :align, :sorting, :default, :formatter, :visible

    delegate :format, :style, to: :formatter

    def initialize(code:, label:, formatter:, align: nil, sorting: nil, default: false)
      @code = code
      @label = label
      @sorting = sorting
      @default = default
      self.formatter = formatter
      self.align = align
    end

    private

    def align=(value)
      return unless value

      value = value.to_s
      raise "Unknown align '#{value}'" if value.present? && !ALIGNS.include?(value)

      value = nil if value.blank? || value == 'left'
      @align = value
    end

    def formatter=(value)
      formatter = FORMATS[value.to_s]
      raise "Unknown formatter '#{value}'" unless formatter

      @formatter = formatter
      self.align = formatter.align
    end
  end
end
