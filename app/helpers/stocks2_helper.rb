# frozen_string_literal: true

require 'pagy'

module Stocks2Helper
  include Pagy::Frontend

  def sort_link_to(name, column, **options)
    direction = if params[:sort] == column.to_s
                  params[:direction] == 'asc' ? 'desc' : 'asc'
                else
                  'asc'
                end

    link_to name, request.params.merge(sort: column, direction: direction), **options
  end
end
