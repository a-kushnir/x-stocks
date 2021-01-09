# frozen_string_literal: true

class EventStream
  # Requires "include ActionController::Live" in controller
  def self.run(response)
    instance = nil
    begin
      instance = EventStream.new(response)
      yield instance
    rescue ActionController::Live::ClientDisconnected
      # Connection closed by client
    rescue Exception => ex
      instance&.write({ message: ex.message, backtrace: Backtrace.clean(ex.backtrace) }, event: 'exception')
    ensure
      instance&.close
    end
  end

  def initialize(response)
    response.headers['Content-Type'] = 'text/event-stream'
    @sse = ActionController::Live::SSE.new(response.stream, event: 'message')
  end

  def write(object, options = {})
    object = { message: object } unless object.is_a?(Hash)
    @sse.write(object, options)
  end

  def close
    @sse.close
  end
end
