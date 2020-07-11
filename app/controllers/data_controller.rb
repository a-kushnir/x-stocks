class DataController < ApplicationController

  def refresh
    Etl::DataRefresh.new.all_financial_data
    Etl::DataRefresh.new.all_yahoo_data
  end

end
