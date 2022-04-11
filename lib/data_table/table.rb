# frozen_string_literal: true

module DataTable
  # Represent a data table
  class Table
    include Pagy::Backend

    DEFAULT_PAGINATION_OPTIONS = [['10', 10], ['20', 20], ['50', 50], ['100', 100]].freeze

    attr_reader :columns, :rows, :footers, :params, :pages, :pagination_options

    def initialize(params, pagination_options = DEFAULT_PAGINATION_OPTIONS)
      @params = params
      @pagination_options = pagination_options
      @columns = []
      @rows = []
      @footers = []
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

    def sort
      yield sort_column, sort_direction
    end

    def filter
      yield params[:q] if params[:q].present?
    end

    def paginate(records)
      @pages, records = pagy(records, items: pagy_items)
      records
    end

    private

    def sort_column
      columns.detect { |column| column.code == params[:sort] }&.sorting ||
        columns.map(&:sorting).compact.first
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end

    def pagy_items
      default = pagination_options.first.last
      items = params.fetch(:items, default).to_i
      items = default unless pagination_options.map(&:last).include?(items)
      items = nil unless items.positive?
      items
    end
  end
end
