# frozen_string_literal: true

module API
  # Root API class
  class Root < Grape::API
    format :json

    rescue_from :all do |e|
      error!({ error: 'Server error', exception: { message: e.message, backtrace: Backtrace.clean(e.backtrace) } }, 500)
    end

    include API::V1::Root

    get '/(*:url)' do
      error!({ error: 'Not Found' }, 404)
    end
  end
end
