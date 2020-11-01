class HomeController < ApplicationController

  def index
    @page_title = 'Home'
    @page_menu_item = :home
    @fear_n_greed_image_url = Etl::Refresh::FearNGreed.new.image_url
  end

  include ActionController::Live

  def demo
    response.headers['Content-Type'] = 'text/event-stream'
    60.times {
      response.stream.write "hello world\n"
      puts "response.stream.write"
      sleep 1
    }
  rescue Exception => ex
    puts "Exception: #{ex.message}"
  ensure
    response.stream.close
  end

end
