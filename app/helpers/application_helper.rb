module ApplicationHelper

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

end
