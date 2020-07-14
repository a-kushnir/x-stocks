class DataController < ApplicationController

  def refresh
    Etl::Refresh.Finnhub.new.hourly_all_stocks
    Etl::Refresh.Yahoo.new.daily_all_stocks
    Etl::Refresh.Finnhub.new.daily_all_stocks
    Etl::Refresh.Iexapis.new.weekly_all_stocks
  end

end
