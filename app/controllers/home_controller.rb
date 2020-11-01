class HomeController < ApplicationController

  def index
    @page_title = 'Home'
    @page_menu_item = :home
    @fear_n_greed_image_url = Etl::Refresh::FearNGreed.new.image_url
  end

  include ActionController::Live

  def demo
    sse = SSE.new(response.stream)
    response.headers['Content-Type'] = 'text/event-stream'
    120.times do |i|
      sse.write({count: i}.to_json)
      sleep(1)
    end
  ensure
    sse.close
  end

end
