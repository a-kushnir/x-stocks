module ApplicationHelper

  def back_url
    'javascript:history.back()'
  end

  def delta_class(number)
    number = number.to_s
    if number.blank? || !(number =~ /[1-9]/i)
      'text-muted'
    elsif number =~ /-/i
      'text-danger'
    else
      'text-success'
    end
  end

  def delta_number(number)
    number = number.to_s
    if number.present? && number =~ /[1-9]/i && !(number =~ /-/i)
      "+#{number}"
    else
      number
    end
  end

  def nav_menu_link(menu_item, name, url, options = {})
    content_tag :li, class: @page_menu_item == menu_item ? 'nav-item active' : 'nav-item' do
      link_to(name, url, {class: 'nav-link'}.merge(options))
    end
  end

  def json(object)
    JSON.generate(object).html_safe
  end

end
