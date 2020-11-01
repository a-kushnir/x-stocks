class HomeController < ApplicationController

  def index
    @page_title = 'Home'
    @page_menu_item = :home
    @fear_n_greed_image_url = Etl::Refresh::FearNGreed.new.image_url
  end

  def demo
    response.headers['Content-Type'] = 'text/event-stream'
    response.stream.write "="
    120.times do |i|
      sleep(1)
      response.stream.write 'x'
    end
    response.stream.write "="
    response.stream.close
  end

end
