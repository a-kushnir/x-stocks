module API
  class Root < Grape::API
    format :json

    rescue_from :all do |e|
      error!({error: 'Server error', exception: {message: e.message, backtrace: Backtrace.clean(e.backtrace)}}, 500)
    end

    mount API::V1::Exchanges
    mount API::V1::Stocks
    mount API::V1::Positions

    get '/(*:url)' do
      error!({error: 'Not Found'}, 404)
    end
  end
end
