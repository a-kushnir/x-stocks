# frozen_string_literal: true

# Provides easy access to Server-Sent Events browser feature
class EventStream
  # Requires "include ActionController::Live" in controller
  def self.run(response)
    instance = nil
    begin
      instance = EventStream.new(response)
      yield instance
    rescue ActionController::Live::ClientDisconnected
      # Connection closed by client
    rescue Exception => e
      instance&.write({ message: e.message, backtrace: Backtrace.clean(e.backtrace) }, event: 'exception')
    ensure
      instance&.close
    end
  end

  def initialize(response)
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Last-Modified'] = Time.now.httpdate # Disables eTag middleware buffering
    response.headers['X-Accel-Buffering'] = 'no' # Turn off buffering in nginx
    @sse = ActionController::Live::SSE.new(response.stream, event: 'message')
  end

  def write(object, options = {})
    object = { message: object } unless object.is_a?(Hash)
    @sse.write(object, options)
  end

  def redirect_to(location)
    @sse.write(location, event: 'redirect')
  end

  def close
    @sse.close
  end
end
