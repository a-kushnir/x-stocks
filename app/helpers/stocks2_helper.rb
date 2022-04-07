# frozen_string_literal: true

module Stocks2Helper
  def sort_link_to(name, column, **options)
    direction = if params[:sort] == column.to_s
                  params[:direction] == 'asc' ? 'desc' : 'asc'
                else
                  'asc'
                end

    link_to name, request.params.merge(sort: column, direction: direction), **options
  end
end
