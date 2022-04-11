# frozen_string_literal: true

module DataTable
  # Represent a data table
  class Table
    attr_reader :columns, :rows, :footer, :params

    def initialize(params)
      @params = params
      @columns = []
      @rows = []
    end

    def init_columns
      @columns = []

      yield columns

      columns.each do |column|
        visible = params[:columns] ? params[:columns].include?(column.code) : column.default
        column.instance_variable_set('@visible', visible)
      end

      duplicates = columns.group_by(&:code).map { |code, columns| code if columns.size > 1 }.compact
      raise "Columns have duplicated codes: #{duplicates}" if duplicates.any?

      self
    end

    def sort_column
      columns.detect { |column| column.code == params[:sort] }&.sorting ||
        columns.map(&:sorting).compact.first
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end

    def pagy_items
      items = params.fetch(:items, 10)
      items = nil if items.to_i <= 1
      items
    end
  end
end
