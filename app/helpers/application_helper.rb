# frozen_string_literal: true

# Helper methods for all application controllers
module ApplicationHelper
  def stock_path(stock)
    "/stocks/#{CGI.escape(stock.symbol)}"
  end

  def back_url
    'javascript:history.back()'
  end

  def delta_class(number)
    number = number.to_s
    if number.blank? || number !~ /[1-9]/i
      'text-muted'
    elsif /-/i.match?(number)
      'text-danger'
    else
      'text-success'
    end
  end

  def change_icon(number)
    number = number.to_s
    if number.blank? || number !~ /[1-9]/i
      nil
    elsif /-/i.match?(number)
      content_tag(:i, { class: 'fas fa-caret-down text-danger' }) { nil }
    else
      content_tag(:i, { class: 'fas fa-caret-up text-success' }) { nil }
    end
  end

  def delta_number(number)
    number = number.to_s
    if number.present? && number =~ /[1-9]/i && number !~ /-/i
      "+#{number}"
    else
      number
    end
  end

  def nav_menu_link(menu_item, name, url, options = {})
    content_tag :li, class: @page_menu_item == menu_item ? 'nav-item active' : 'nav-item' do
      link_to(name, url, { class: 'nav-link' }.merge(options))
    end
  end

  def json(object)
    JSON.generate(object).html_safe
  end

  def multiline_text_to_html(value)
    (value || '').to_s.split("\n").map { |line| h line }.join('<br>').html_safe
  end

  def default_columns
    @columns.select { |column| column[:default] }.map { |column| column[:index] }.to_json
  end
end
