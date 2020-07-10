class DataController < ApplicationController

  def refresh
    Etl::DataRefresh.new.all_financial_data
  end

end
