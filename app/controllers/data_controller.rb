class DataController < ApplicationController

  def refresh
    Data::Refresh.new.all_financial_data!
  end

end
