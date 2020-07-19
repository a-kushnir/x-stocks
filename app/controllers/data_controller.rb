class DataController < ApplicationController

  skip_before_action :verify_authenticity_token

  def refresh
    Etl::Refresh::Finnhub.new.hourly_all_stocks ||
    Etl::Refresh::Yahoo.new.daily_all_stocks ||
    Etl::Refresh::Finnhub.new.daily_all_stocks ||
    Etl::Refresh::Iexapis.new.weekly_all_stocks ||
    Etl::Refresh::Dividend.new.weekly_all_stocks
    render json: {result: 'success'}
  end

end
