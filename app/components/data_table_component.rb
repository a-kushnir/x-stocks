# frozen_string_literal: true

require 'pagy'
require 'pagy/frontend/override'

# Component class to render a Data Table
class DataTableComponent < ::ViewComponent::Base
  include Pagy::Frontend
  include Pagy::Frontend::Override
  include Turbo::FramesHelper

  # TODO: refactor summary_row
  def initialize(name:, table:, summary_row: nil, turbo_frame_id:, top_right_block: nil, bottom_left_block: nil)
    super
    @name = name
    @table = table
    @summary_row = summary_row
    @turbo_frame_id = turbo_frame_id
    @form_id = "#{turbo_frame_id}_form"
    @top_right_block = top_right_block
    @bottom_left_block = bottom_left_block
  end

  private

  def sort_direction(column)
    if params[:sort] == column.to_s
      params[:direction] == 'asc' ? 'desc' : 'asc'
    else
      'asc'
    end
  end

  def sort_link_to(name, column, **options)
    link_to name, request.params.merge(sort: column, direction: sort_direction(column)), **options
  end

  def request_path(params = {})
    uri = URI(request.path)
    params = Hash[URI.decode_www_form(uri.query || '')].merge(params)
    uri.query = URI.encode_www_form(params)
    uri.to_s
  end
end
